-- Creates a trip for the authenticated user
-- Returns the complete trip as JSON

create or replace function create_trip(
  p_name text,
  p_start_date date,
  p_end_date date
) returns json
language plpgsql
security definer
as $$
declare
  v_result json;
begin
  insert into trips (user_id, name, start_date, end_date)
  values (auth.uid(), p_name, p_start_date, p_end_date)
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
