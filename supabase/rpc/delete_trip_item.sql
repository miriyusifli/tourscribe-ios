-- Deletes a trip item and recalculates trip start_date and end_date
-- Returns the number of deleted rows

create or replace function delete_trip_item(
  p_item_id bigint
) returns int
language plpgsql
security definer
as $$
declare
  v_trip_id bigint;
  v_deleted int;
begin
  select trip_id into v_trip_id from trip_items where id = p_item_id;
  
  delete from trip_items where id = p_item_id;
  get diagnostics v_deleted = row_count;
  
  update trips set
    start_date = (select min(start_datetime)::date from trip_items where trip_id = v_trip_id),
    end_date = (select max(end_datetime)::date from trip_items where trip_id = v_trip_id)
  where id = v_trip_id;
  
  return v_deleted;
end;
$$;
