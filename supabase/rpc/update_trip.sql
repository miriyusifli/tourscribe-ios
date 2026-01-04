-- Updates a trip for the authenticated user with optimistic locking
-- Returns the updated trip as JSON, raises exception on version conflict

create or replace function update_trip(
  p_trip_id bigint,
  p_name text,
  p_version int,
  p_img_url text
) returns json
language plpgsql
security definer
as $$
declare
  v_result json;
begin
  update trips
  set name = p_name,
      img_url = p_img_url,
      version = version + 1,
      updated_at = now()
  where id = p_trip_id and user_id = auth.uid() and version = p_version
  returning json_build_object(
    'id', id,
    'user_id', user_id,
    'name', name,
    'img_url', img_url,
    'start_date', start_date,
    'end_date', end_date,
    'version', version,
    'created_at', created_at,
    'updated_at', updated_at
  ) into v_result;
  
  if v_result is null then
    raise exception 'VERSION_CONFLICT';
  end if;
  
  return v_result;
end;
$$;
