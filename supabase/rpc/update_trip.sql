-- Updates a trip for the authenticated user
-- Returns the updated trip as JSON

create or replace function update_trip(
  p_trip_id bigint,
  p_name text
) returns json
language plpgsql
security definer
as $$
declare
  v_result json;
begin
  update trips
  set name = p_name,
      updated_at = now()
  where id = p_trip_id and user_id = auth.uid()
  returning json_build_object(
    'id', id,
    'user_id', user_id,
    'name', name,
    'start_date', start_date,
    'end_date', end_date,
    'created_at', created_at,
    'updated_at', updated_at
  ) into v_result;
  
  return v_result;
end;
$$;
