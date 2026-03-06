-- RPC function to request joining a league
-- Accepts a league ID and either auto-joins the user (for the HoopsLeague public league)
-- or adds them to the pending_users list for admin approval.
-- Returns a JSON object with a "status" field: "joined" or "pending".

CREATE OR REPLACE FUNCTION request_join_league(p_league_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id uuid;
  league_record   record;
  league_users    uuid[];
  league_pending  uuid[];
  user_leagues    uuid[];
BEGIN
  -- Get the current authenticated user's ID
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Fetch the target league
  SELECT id, name, users_id, pending_users
    INTO league_record
    FROM public.leagues
   WHERE id = p_league_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'League not found';
  END IF;

  league_users   := COALESCE(league_record.users_id, ARRAY[]::uuid[]);
  league_pending := COALESCE(league_record.pending_users, ARRAY[]::uuid[]);

  -- Guard: already a full member
  IF current_user_id = ANY(league_users) THEN
    RAISE EXCEPTION 'Already a member';
  END IF;

  -- Guard: already waiting for approval
  IF current_user_id = ANY(league_pending) THEN
    RAISE EXCEPTION 'Already pending';
  END IF;

  -- Auto-join for the public "HoopsLeague" league (case-insensitive)
  IF lower(league_record.name) = 'hoopsleague' THEN

    -- Add user to the league's members list
    UPDATE public.leagues
       SET users_id = array_append(users_id, current_user_id)
     WHERE id = p_league_id;

    -- Add the league to the user's leagues array in usersdata (avoid duplicates)
    SELECT leagues INTO user_leagues
      FROM public.usersdata
     WHERE id = current_user_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'User data not found';
    END IF;

    user_leagues := COALESCE(user_leagues, ARRAY[]::uuid[]);

    IF NOT (p_league_id = ANY(user_leagues)) THEN
      UPDATE public.usersdata
         SET leagues = array_append(user_leagues, p_league_id)
       WHERE id = current_user_id;
    END IF;

    RETURN json_build_object('status', 'joined');

  ELSE

    -- Add user to the league's pending list for admin approval
    UPDATE public.leagues
       SET pending_users = array_append(COALESCE(pending_users, ARRAY[]::uuid[]), current_user_id)
     WHERE id = p_league_id;

    RETURN json_build_object('status', 'pending');

  END IF;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION request_join_league(uuid) TO authenticated;

-- Add comment
COMMENT ON FUNCTION request_join_league(uuid) IS
  'Requests to join a league. Auto-joins for the public HoopsLeague league; '
  'adds to pending_users for all other leagues. Returns JSON {status: "joined"|"pending"}.';
