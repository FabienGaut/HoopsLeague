# Account Management - Supabase Setup

This document explains how to set up the account management features (logout and account deletion).

## Features

### 1. Logout
- Clears local cache
- Signs out from Supabase auth
- Redirects to homepage
- No special Supabase configuration needed

### 2. Delete Account
- Double confirmation dialogs for safety
- Deletes all user data (bets, user profile)
- Removes user from auth
- Automatically signs out
- Redirects to homepage

## Required Supabase Setup

### Deploy the `delete_user_account` RPC function

Run the following SQL in your Supabase SQL Editor:

```sql
-- RPC function to delete user account
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

  -- Delete user from leagues (if applicable)
  -- Uncomment if you have league memberships:
  -- DELETE FROM public.league_members WHERE user_id = current_user_id;

  -- Finally, delete the auth user
  DELETE FROM auth.users WHERE id = current_user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_user_account() TO authenticated;
```

## Security

- ✅ **SECURITY DEFINER**: Function runs with elevated privileges to access `auth.users`
- ✅ **auth.uid() check**: Only authenticated users can delete their own account
- ✅ **No parameters**: Uses `auth.uid()` to ensure users can only delete their own account
- ✅ **Double confirmation**: UI requires two confirmations before deletion
- ✅ **Client-side validation**: Checks user ID matches current session

## Testing

### Test Logout:
1. Go to **Settings** (Manage Account)
2. Click **Déconnexion** in the Security section
3. Confirm the dialog
4. ✅ You should be logged out and redirected to the homepage

### Test Account Deletion:
1. Create a test account
2. Place a few bets
3. Go to **Settings** → **Danger Zone**
4. Click **Supprimer le compte**
5. Confirm **twice** in the dialogs
6. ✅ Account should be deleted, all data removed, and you should be logged out

## What Gets Deleted

When a user deletes their account:

| Data | Action |
|------|--------|
| User profile (`usersdata`) | ❌ Deleted |
| All bets (`bets`) | ❌ Deleted |
| Points history | ❌ Deleted (local cache cleared) |
| Auth account (`auth.users`) | ❌ Deleted |
| League memberships | ❌ Deleted (if implemented) |

## Troubleshooting

### Error: "Not authenticated"
- User is not logged in
- Session has expired
- Solution: Log in again

### Error: "permission denied for function delete_user_account"
- The function doesn't exist or permissions aren't granted
- Solution: Run the SQL setup above

### User deleted but still appears in leagues
- If you have a leagues/memberships table, uncomment the line in the SQL function
- Re-run the SQL setup

## File Locations

- Flutter code: `lib/pages/manage_account_page.dart`
- SQL function: `supabase/functions/delete_user_account.sql`
- Translations: `lib/l10n/app_en.arb` and `lib/l10n/app_fr.arb`
