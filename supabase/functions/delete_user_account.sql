-- RPC function to delete user account
-- This function deletes all user data and the auth user
-- No parameters needed - uses auth.uid() to get the current user

CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id uuid;
BEGIN
  -- Get the current authenticated user's ID
  current_user_id := auth.uid();

  -- Check if user is authenticated
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Delete user bets
  DELETE FROM public.bets WHERE user_id = current_user_id;

  -- Delete user data
  DELETE FROM public.usersdata WHERE id = current_user_id;

  -- Delete user from leagues (if you have a leagues table with user associations)
  -- DELETE FROM public.league_members WHERE user_id = current_user_id;

  -- Finally, delete the auth user
  -- This will automatically sign out the user
  DELETE FROM auth.users WHERE id = current_user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_user_account() TO authenticated;

-- Add comment
COMMENT ON FUNCTION delete_user_account() IS 'Deletes all user data and auth account for the current user';
