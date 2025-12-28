-- Creates a new profile for the authenticated user
-- Returns the created profile as JSON

create or replace function create_profile(
  p_id uuid,
  p_email text,
  p_first_name text,
  p_last_name text,
  p_birth_date date,
  p_gender text,
  p_interests text[]
) returns json
language plpgsql
security definer
as $$
declare
  v_result json;
begin
  insert into profiles (id, email, first_name, last_name, birth_date, gender, interests, version, created_at, updated_at)
  values (p_id, p_email, p_first_name, p_last_name, p_birth_date, p_gender, p_interests, 0, now(), now())
  returning json_build_object(
    'id', id,
    'email', email,
    'first_name', first_name,
    'last_name', last_name,
    'birth_date', birth_date,
    'gender', gender,
    'interests', interests,
    'version', version,
    'created_at', created_at,
    'updated_at', updated_at
  ) into v_result;
  
  return v_result;
end;
$$;
