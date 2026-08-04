-- ========================================================
-- Góc Phim — Supabase Database Schema & RLS Policies
-- ========================================================

-- 1. Table: profiles
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  avatar_url text,
  created_at timestamptz default now()
);

-- RLS Policies for profiles
alter table profiles enable row level security;

create policy "Users can view own profile" 
  on profiles for select 
  using (auth.uid() = id);

create policy "Users can update own profile" 
  on profiles for update 
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on profiles for insert
  with check (auth.uid() = id);


-- 2. Table: watchlist
create table if not exists watchlist (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  movie_id integer not null,
  movie_title text not null,
  poster_path text,
  watched boolean default false,
  added_at timestamptz default now(),
  unique(user_id, movie_id)
);

-- RLS Policies for watchlist
alter table watchlist enable row level security;

create policy "Users manage own watchlist" 
  on watchlist for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- 3. Table: reviews
create table if not exists reviews (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  movie_id integer not null,
  rating numeric(3,1) check (rating >= 1 and rating <= 10),
  content text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, movie_id)
);

-- RLS Policies for reviews
alter table reviews enable row level security;

create policy "Anyone can read reviews" 
  on reviews for select 
  using (true);

create policy "Users manage own reviews" 
  on reviews for all 
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
