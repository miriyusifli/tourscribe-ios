-- Updates a trip item and its locations atomically with optimistic locking
-- Returns the complete trip item with locations as JSON
-- Raises exception on version conflict

create or replace function update_trip_item(
  p_item_id bigint,
  p_name text,
  p_start_datetime timestamptz,
  p_end_datetime timestamptz,
  p_metadata jsonb,
  p_locations jsonb,
  p_version int
) returns json
language plpgsql
security definer
as $$
declare
  v_result json;
  v_updated_count int;
begin
  update trip_items
  set name = p_name,
      start_datetime = p_start_datetime,
      end_datetime = p_end_datetime,
      metadata = p_metadata,
      version = version + 1,
      updated_at = now()
  where id = p_item_id and version = p_version;
  
  get diagnostics v_updated_count = row_count;
  if v_updated_count = 0 then
    raise exception 'VERSION_CONFLICT';
  end if;
  
  update trips set
    start_date = least(start_date, p_start_datetime::date),
    end_date = greatest(end_date, p_end_datetime::date)
  where id = (select trip_id from trip_items where id = p_item_id);
  
  -- Delete locations not in the new list
  delete from trip_item_locations 
  where trip_item_id = p_item_id 
    and sequence not in (select (value->>'sequence')::int from jsonb_array_elements(p_locations));
  
  -- Upsert locations
  insert into trip_item_locations (trip_item_id, sequence, name, address, city, country, latitude, longitude)
  select 
    p_item_id,
    (value->>'sequence')::int,
    value->>'name',
    value->>'address',
    value->>'city',
    value->>'country',
    (value->>'latitude')::double precision,
    (value->>'longitude')::double precision
  from jsonb_array_elements(p_locations)
  on conflict (trip_item_id, sequence) 
  do update set 
    name = excluded.name,
    address = excluded.address,
    city = excluded.city,
    country = excluded.country,
    latitude = excluded.latitude,
    longitude = excluded.longitude;
  
  select json_build_object(
    'id', ti.id,
    'trip_id', ti.trip_id,
    'name', ti.name,
    'item_type', ti.item_type,
    'start_datetime', ti.start_datetime,
    'end_datetime', ti.end_datetime,
    'metadata', ti.metadata,
    'version', ti.version,
    'created_at', ti.created_at,
    'updated_at', ti.updated_at,
    'trip_item_locations', coalesce(
      (select json_agg(row_to_json(til)) from trip_item_locations til where til.trip_item_id = ti.id),
      '[]'::json
    )
  ) into v_result
  from trip_items ti
  where ti.id = p_item_id;
  
  return v_result;
end;
$$;
