-- Creates a trip item with its locations atomically
-- Returns the complete trip item with locations as JSON

create or replace function create_trip_item(
  p_trip_id bigint,
  p_name text,
  p_item_type text,
  p_start_time timestamptz,
  p_end_time timestamptz,
  p_metadata jsonb,
  p_locations jsonb
) returns json
language plpgsql
security definer
as $$
declare
  v_item_id bigint;
  v_loc jsonb;
  v_result json;
begin
  insert into trip_items (trip_id, name, item_type, start_time, end_time, metadata)
  values (p_trip_id, p_name, p_item_type, p_start_time, p_end_time, p_metadata)
  returning id into v_item_id;
  
  for v_loc in select * from jsonb_array_elements(p_locations)
  loop
    insert into trip_item_locations (trip_item_id, sequence, name, address, latitude, longitude)
    values (
      v_item_id,
      (v_loc->>'sequence')::int,
      v_loc->>'name',
      v_loc->>'address',
      (v_loc->>'latitude')::double precision,
      (v_loc->>'longitude')::double precision
    );
  end loop;
  
  select json_build_object(
    'id', ti.id,
    'trip_id', ti.trip_id,
    'name', ti.name,
    'item_type', ti.item_type,
    'start_time', ti.start_time,
    'end_time', ti.end_time,
    'metadata', ti.metadata,
    'created_at', ti.created_at,
    'updated_at', ti.updated_at,
    'trip_item_locations', coalesce(
      (select json_agg(row_to_json(til)) from trip_item_locations til where til.trip_item_id = ti.id),
      '[]'::json
    )
  ) into v_result
  from trip_items ti
  where ti.id = v_item_id;
  
  return v_result;
end;
$$;
