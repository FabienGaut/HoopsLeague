-- Scalability indexes for HoopsLeague
-- Run these in the Supabase SQL editor (Dashboard > SQL Editor) or via the Supabase CLI.
-- All statements use IF NOT EXISTS so they are safe to re-run.

-- ─── bets ────────────────────────────────────────────────────────────────────
-- Most queries filter bets by user_id (passed-bets page, win-sync, etc.)
CREATE INDEX IF NOT EXISTS idx_bets_user_id
  ON public.bets (user_id);

-- Win-sync query filters on all three columns at once:
--   .eq('user_id', …).eq('status', 'won').eq('reward_given', false)
CREATE INDEX IF NOT EXISTS idx_bets_user_status_reward
  ON public.bets (user_id, status, reward_given);

-- Passed-bets page orders results by timestamp descending
CREATE INDEX IF NOT EXISTS idx_bets_timestamp_desc
  ON public.bets (timestamp DESC);

-- ─── leagues ─────────────────────────────────────────────────────────────────
-- leagues_page.dart uses .contains('users_id', [uid]) — requires a GIN index
CREATE INDEX IF NOT EXISTS idx_leagues_users_id_gin
  ON public.leagues USING GIN (users_id);

-- pending-user approval also filters on the pending_users array
CREATE INDEX IF NOT EXISTS idx_leagues_pending_users_gin
  ON public.leagues USING GIN (pending_users);

-- ─── usersdata ───────────────────────────────────────────────────────────────
-- ranking_page.dart may use array-contains on usersdata.leagues
CREATE INDEX IF NOT EXISTS idx_usersdata_leagues_gin
  ON public.usersdata USING GIN (leagues);

-- ─── gamesdata ───────────────────────────────────────────────────────────────
-- Filtering completed / upcoming games by status
CREATE INDEX IF NOT EXISTS idx_gamesdata_status
  ON public.gamesdata (status);

-- Sorting / filtering games by start_time (used by the upcoming_scheduled_games view)
CREATE INDEX IF NOT EXISTS idx_gamesdata_start_time
  ON public.gamesdata (start_time);

-- ─── teams ───────────────────────────────────────────────────────────────────
-- games_page.dart and game_stats_card.dart look up teams by name
CREATE INDEX IF NOT EXISTS idx_teams_name
  ON public.teams (name);
