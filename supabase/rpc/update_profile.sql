-- Updates the profile for the authenticated user

create or replace function update_profile(
  p_first_name text,
  p_last_name text,
  p_birth_date date,
  p_gender text
) returns void
language plpgsql
security definer
as $$
begin
  update profiles
  set first_name = p_first_name,
      last_name = p_last_name,
      birth_date = p_birth_date,
      gender = p_gender,
      updated_at = now()
  where id = auth.uid();
end;
$$;
