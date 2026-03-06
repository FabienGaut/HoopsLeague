# Supabase Setup Instructions

## Security: Timezone Validation

To prevent users from betting on games that have already started by manipulating their device's timezone, we need to validate bet timestamps using the server's clock.

### Step 1: Create the `get_current_timestamp` function

This function returns the current UTC timestamp from the Supabase server, ensuring that all time comparisons are based on a secure, non-manipulable time source.

#### How to deploy:

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the contents of `supabase/functions/get_current_timestamp.sql`
5. Click **Run** to execute the SQL

#### What it does:

- Returns the current server timestamp in UTC
- Accessible by authenticated users only
- Used by the client app to validate that games haven't started before accepting bets

### Step 2: Verify the function works

Run this query in the SQL Editor:

```sql
SELECT * FROM get_current_timestamp();
```

Expected result:
```json
{
  "now": "2024-01-15T10:30:45.123456+00:00"
}
```

### Step 3: Create the `request_join_league` function

This function handles league membership requests. It either auto-joins the user (for the
public "HoopsLeague" league) or places them in a pending queue for admin approval.

#### How to deploy:

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the contents of `supabase/functions/request_join_league.sql`
5. Click **Run** to execute the SQL

#### What it does:

- Checks that the caller is authenticated via `auth.uid()`
- Raises `Already a member` if the user is already in the league
- Raises `Already pending` if the user has a pending request
- Auto-joins the user (adds to `leagues.users_id` **and** `usersdata.leagues`) when the
  league name is `hoopsleague` (case-insensitive)
- Otherwise adds the user to `leagues.pending_users` for admin review
- Returns `{"status": "joined"}` or `{"status": "pending"}`

#### Verify it works:

```sql
-- Should return {"status": "pending"} for a normal league
SELECT request_join_league('<your-league-uuid-here>');
```

> **Note:** PostgREST caches the database schema. After deploying this function, call
> `NOTIFY pgrst, 'reload schema'` in the SQL Editor (or restart the PostgREST service) so
> that the endpoint `/rest/v1/rpc/request_join_league` becomes available immediately.

## Additional Security Recommendations

### Optional: Add a database trigger (Server-side validation)

For maximum security, you can also add a PostgreSQL trigger that validates game start times when bets are inserted:

```sql
-- Create a function to validate bet timing
CREATE OR REPLACE FUNCTION validate_bet_timing()
RETURNS TRIGGER AS $$
DECLARE
  game_start_time timestamptz;
  current_time timestamptz;
BEGIN
  -- Get current server time
  current_time := now() AT TIME ZONE 'UTC';

  -- Check each game in the bet
  FOR game_start_time IN
    SELECT start_time
    FROM upcoming_scheduled_games
    WHERE id = ANY(NEW.games_id)
  LOOP
    IF game_start_time <= current_time THEN
      RAISE EXCEPTION 'Cannot bet on game that has already started';
    END IF;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER check_bet_timing
  BEFORE INSERT ON bets
  FOR EACH ROW
  EXECUTE FUNCTION validate_bet_timing();
```

This adds an extra layer of protection at the database level, ensuring that even if someone bypasses the client validation, they cannot insert bets on games that have already started.

## Testing

To test that the security works:

1. Try betting on a game through the app normally (should work)
2. Change your device's time to the future
3. Try betting again (should be rejected with error message)

The validation compares:
- Server time (from `get_current_timestamp()`)
- Game start time (from database)
- If game start time <= server time, the bet is rejected
