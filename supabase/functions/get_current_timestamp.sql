-- Function to get the current server timestamp
-- This prevents timezone manipulation by clients
-- Usage: SELECT * FROM get_current_timestamp();

CREATE OR REPLACE FUNCTION get_current_timestamp()
RETURNS TABLE (now timestamptz)
LANGUAGE sql
STABLE
AS $$
  SELECT now() AT TIME ZONE 'UTC';
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_current_timestamp() TO authenticated;

-- Example usage:
-- SELECT * FROM get_current_timestamp();
-- Result: { "now": "2024-01-15T10:30:45.123456+00:00" }
