-- 在 Supabase 控制台 → SQL Editor 里整段运行一次即可

create table if not exists public.wishes (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  name text not null default '匿名访客',
  text text not null,
  constraint wishes_name_len check (char_length(name) <= 16),
  constraint wishes_text_len check (char_length(text) between 1 and 120)
);

create index if not exists wishes_created_at_idx on public.wishes (created_at desc);

alter table public.wishes enable row level security;

-- 所有人都能看
drop policy if exists "wishes_public_read" on public.wishes;
create policy "wishes_public_read"
  on public.wishes for select
  to anon, authenticated
  using (true);

-- 所有人都能写，但长度受限
drop policy if exists "wishes_public_insert" on public.wishes;
create policy "wishes_public_insert"
  on public.wishes for insert
  to anon, authenticated
  with check (char_length(text) between 1 and 120 and char_length(name) <= 16);

-- 默认不允许改和删（没有 update/delete 策略，anon 就动不了）
