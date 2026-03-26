-- Table and RPC functions for playoff bracket persistence
-- Each user can have one bracket per league per season.
-- A bracket can be saved as draft, then validated once (locked).

-- ─── Table ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.brackets (
  id          uuid        NOT NULL DEFAULT gen_random_uuid(),
  user_id     uuid        NOT NULL,
  league_id   uuid        NOT NULL,
  season      text        NOT NULL DEFAULT '2025-2026',
  bracket_data jsonb      NOT NULL DEFAULT '{}'::jsonb,
  is_validated boolean    NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  validated_at timestamptz,
  CONSTRAINT brackets_pkey PRIMARY KEY (id),
  CONSTRAINT brackets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.usersdata(id) ON DELETE CASCADE,
  CONSTRAINT brackets_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.leagues(id) ON DELETE CASCADE,
  CONSTRAINT brackets_unique_user_league_season UNIQUE (user_id, league_id, season)
);

-- Enable RLS
ALTER TABLE public.brackets ENABLE ROW LEVEL SECURITY;

-- Users can read brackets from their own leagues
CREATE POLICY brackets_select ON public.brackets
  FOR SELECT USING (
    league_id IN (
      SELECT unnest(COALESCE(leagues, ARRAY[]::uuid[]))
      FROM public.usersdata WHERE id = auth.uid()
    )
  );

-- Users can insert/update their own brackets
CREATE POLICY brackets_insert ON public.brackets
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY brackets_update ON public.brackets
  FOR UPDATE USING (user_id = auth.uid());

-- ─── Save bracket (upsert draft) ────────────────────────
CREATE OR REPLACE FUNCTION save_bracket(
  p_league_id   uuid,
  p_bracket_data jsonb,
  p_season      text DEFAULT '2025-2026'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id uuid;
  existing        record;
BEGIN
  current_user_id := auth.uid();
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Check if bracket already exists
  SELECT id, is_validated INTO existing
  FROM public.brackets
  WHERE user_id = current_user_id
    AND league_id = p_league_id
    AND season = p_season;

  IF FOUND AND existing.is_validated THEN
    RAISE EXCEPTION 'Bracket already validated, cannot modify';
  END IF;

  -- Upsert
  INSERT INTO public.brackets (user_id, league_id, season, bracket_data, updated_at)
  VALUES (current_user_id, p_league_id, p_season, p_bracket_data, now())
  ON CONFLICT (user_id, league_id, season)
  DO UPDATE SET bracket_data = p_bracket_data, updated_at = now()
  WHERE public.brackets.is_validated = false;

  RETURN json_build_object('status', 'saved');
END;
$$;

GRANT EXECUTE ON FUNCTION save_bracket(uuid, jsonb, text) TO authenticated;

-- ─── Validate bracket (lock it) ─────────────────────────
CREATE OR REPLACE FUNCTION validate_bracket(
  p_league_id uuid,
  p_season    text DEFAULT '2025-2026'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id uuid;
  existing        record;
BEGIN
  current_user_id := auth.uid();
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT id, is_validated, bracket_data INTO existing
  FROM public.brackets
  WHERE user_id = current_user_id
    AND league_id = p_league_id
    AND season = p_season;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No bracket found to validate';
  END IF;

  IF existing.is_validated THEN
    RAISE EXCEPTION 'Bracket already validated';
  END IF;

  -- Check that bracket is complete (has a finals_winner)
  IF existing.bracket_data->>'finals_winner' IS NULL OR existing.bracket_data->>'finals_winner' = '' THEN
    RAISE EXCEPTION 'Bracket is incomplete, pick a champion first';
  END IF;

  UPDATE public.brackets
  SET is_validated = true, validated_at = now(), updated_at = now()
  WHERE id = existing.id;

  RETURN json_build_object('status', 'validated');
END;
$$;

GRANT EXECUTE ON FUNCTION validate_bracket(uuid, text) TO authenticated;

-- ─── Get league brackets (for comparison) ───────────────
CREATE OR REPLACE FUNCTION get_league_brackets(
  p_league_id uuid,
  p_season    text DEFAULT '2025-2026'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id uuid;
  result          json;
BEGIN
  current_user_id := auth.uid();
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Only return validated brackets from league members
  SELECT json_agg(row_to_json(t))
  INTO result
  FROM (
    SELECT
      b.user_id,
      u.user_name,
      b.bracket_data,
      b.validated_at
    FROM public.brackets b
    JOIN public.usersdata u ON u.id = b.user_id
    WHERE b.league_id = p_league_id
      AND b.season = p_season
      AND b.is_validated = true
    ORDER BY b.validated_at ASC
  ) t;

  RETURN COALESCE(result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION get_league_brackets(uuid, text) TO authenticated;

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
