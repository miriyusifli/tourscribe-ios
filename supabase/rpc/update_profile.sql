-- Updates the profile for the authenticated user with optimistic locking
-- Raises exception on version conflict

create or replace function update_profile(
  p_first_name text,
  p_last_name text,
  p_birth_date date,
  p_gender text,
  p_version int
) returns void
language plpgsql
security definer
as $$
declare
  v_updated_count int;
begin
  update profiles
  set first_name = p_first_name,
      last_name = p_last_name,
      birth_date = p_birth_date,
      gender = p_gender,
      version = version + 1,
      updated_at = now()
  where id = auth.uid() and version = p_version;
  
  get diagnostics v_updated_count = row_count;
  if v_updated_count = 0 then
    raise exception 'VERSION_CONFLICT';
  end if;
end;
$$;
