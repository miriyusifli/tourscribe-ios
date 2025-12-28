-- LLM chat usage tracking for rate limiting (5 requests/day per user)
-- Table only accessible by service role (admin/edge functions)

create table llm_chat_usage (
  user_id uuid references auth.users(id) on delete cascade primary key,
  request_date date not null default current_date,
  request_count int not null default 0,
  constraint request_count_non_negative check (request_count >= 0)
);

-- No RLS enabled = only service role can access
