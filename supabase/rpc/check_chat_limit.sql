-- Checks and increments LLM chat usage, returns remaining count or -1 if limit exceeded
-- Only callable by service role

create or replace function check_llm_chat_limit(p_user_id uuid)
returns int
language plpgsql
security definer
as $$
declare
  v_today date := current_date;
  v_count int;
  v_limit int := 5;
begin
  insert into llm_chat_usage (user_id, request_date, request_count)
  values (p_user_id, v_today, 1)
  on conflict (user_id) do update
  set request_count = case 
      when llm_chat_usage.request_date < v_today then 1
      else llm_chat_usage.request_count + 1
    end,
    request_date = v_today
  where llm_chat_usage.request_count < v_limit or llm_chat_usage.request_date < v_today
  returning request_count into v_count;
  
  if v_count is null then
    return -1;
  end if;
  
  return v_limit - v_count;
end;
$$;

-- Restrict to service role only
revoke execute on function check_llm_chat_limit(uuid) from public;
revoke execute on function check_llm_chat_limit(uuid) from authenticated;
