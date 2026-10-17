/*
# Throttle contact form submissions

1. Changes
- Adds `throttle_portfolio_messages()`, a BEFORE INSERT trigger function on `portfolio_messages`
  that rejects a new message when more than 20 messages were already stored in the previous hour.
- Adds an index on `created_at` so the count stays cheap.

2. Security
- Prevents an anonymous caller from flooding the owner's inbox through the public Data API.
- The function is SECURITY INVOKER with a fixed empty search_path and grants no new privileges.

3. Notes
1. Normal visitor traffic is far below the threshold, so legitimate submissions are unaffected.
2. Reads and deletes on messages remain restricted to portfolio editors.
*/

CREATE INDEX IF NOT EXISTS portfolio_messages_created_at_idx ON portfolio_messages (created_at DESC);

CREATE OR REPLACE FUNCTION public.throttle_portfolio_messages()
RETURNS trigger
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  recent_count integer;
BEGIN
  SELECT count(*) INTO recent_count
  FROM public.portfolio_messages
  WHERE created_at > now() - interval '1 hour';

  IF recent_count >= 20 THEN
    RAISE EXCEPTION 'Too many messages submitted recently. Please try again later.';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS throttle_portfolio_messages_trigger ON portfolio_messages;

CREATE TRIGGER throttle_portfolio_messages_trigger
BEFORE INSERT ON portfolio_messages
FOR EACH ROW EXECUTE FUNCTION public.throttle_portfolio_messages();
