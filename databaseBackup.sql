-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.bets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  games_id ARRAY NOT NULL,
  odd real NOT NULL,
  points_betted integer NOT NULL,
  selection ARRAY NOT NULL,
  status text DEFAULT 'pending'::text,
  timestamp timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  reward_given boolean DEFAULT false,
  CONSTRAINT bets_pkey PRIMARY KEY (id),
  CONSTRAINT bets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usersdata(id)
);
CREATE TABLE public.betstests (
  id text NOT NULL,
  games_id ARRAY NOT NULL,
  odd numeric NOT NULL,
  points_betted integer NOT NULL,
  selection ARRAY NOT NULL,
  status text DEFAULT 'pending'::text,
  timestamp timestamp with time zone NOT NULL,
  user_id text NOT NULL,
  inserted_at timestamp with time zone DEFAULT now(),
  CONSTRAINT betstests_pkey PRIMARY KEY (id)
);
CREATE TABLE public.bugs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  title text NOT NULL,
  description text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT bugs_pkey PRIMARY KEY (id)
);
CREATE TABLE public.gamesdata (
  id uuid NOT NULL,
  home_team text NOT NULL,
  home_team_short text NOT NULL,
  away_team text NOT NULL,
  away_team_short text NOT NULL,
  start_time timestamp with time zone NOT NULL,
  status text DEFAULT 'scheduled'::text,
  winner boolean,
  odd_home_team numeric,
  odd_away_team numeric,
  created_at timestamp with time zone DEFAULT now(),
  home_team_score smallint,
  away_team_score smallint,
  CONSTRAINT gamesdata_pkey PRIMARY KEY (id)
);
CREATE TABLE public.gamesdatatest (
  id text NOT NULL,
  home_team text NOT NULL,
  home_team_short text,
  away_team text NOT NULL,
  away_team_short text,
  start_time timestamp with time zone NOT NULL,
  status text DEFAULT 'scheduled'::text,
  winner boolean,
  odd_home_team numeric,
  odd_away_team numeric,
  home_team_score integer,
  away_team_score integer,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT gamesdatatest_pkey PRIMARY KEY (id)
);
CREATE TABLE public.leagues (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  users_id ARRAY DEFAULT '{}'::uuid[],
  created_at timestamp with time zone DEFAULT now(),
  pending_users ARRAY,
  CONSTRAINT leagues_pkey PRIMARY KEY (id)
);
CREATE TABLE public.usersdata (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_name text DEFAULT ''::text,
  points real,
  daily_points_used boolean DEFAULT false,
  timezone text DEFAULT 'Paris'::text,
  oddsformat text,
  language text,
  leagues ARRAY,
  CONSTRAINT usersdata_pkey PRIMARY KEY (id)
);

-- ─── Scalability indexes (see supabase/migrations/20260313000000_add_scalability_indexes.sql) ───
CREATE INDEX IF NOT EXISTS idx_bets_user_id ON public.bets (user_id);
CREATE INDEX IF NOT EXISTS idx_bets_user_status_reward ON public.bets (user_id, status, reward_given);
CREATE INDEX IF NOT EXISTS idx_bets_timestamp_desc ON public.bets (timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_leagues_users_id_gin ON public.leagues USING GIN (users_id);
CREATE INDEX IF NOT EXISTS idx_leagues_pending_users_gin ON public.leagues USING GIN (pending_users);
CREATE INDEX IF NOT EXISTS idx_usersdata_leagues_gin ON public.usersdata USING GIN (leagues);
CREATE INDEX IF NOT EXISTS idx_gamesdata_status ON public.gamesdata (status);
CREATE INDEX IF NOT EXISTS idx_gamesdata_start_time ON public.gamesdata (start_time);
CREATE INDEX IF NOT EXISTS idx_teams_name ON public.teams (name);