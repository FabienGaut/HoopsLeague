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
CREATE TABLE public.brackets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  league_id uuid NOT NULL,
  season text NOT NULL DEFAULT '2025-2026'::text,
  bracket_data jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_validated boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  validated_at timestamp with time zone,
  CONSTRAINT brackets_pkey PRIMARY KEY (id),
  CONSTRAINT brackets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usersdata(id) ON DELETE CASCADE,
  CONSTRAINT brackets_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.leagues(id) ON DELETE CASCADE,
  CONSTRAINT brackets_unique_user_league_season UNIQUE (user_id, league_id, season)
);