/*
# Make the contact message throttle effective

1. Changes
- Recreates `throttle_portfolio_messages()` as SECURITY DEFINER so the recent-message count can be
  read. As SECURITY INVOKER the count always returned zero for anonymous senders (they hold no read
  policy on the table), which made the throttle a no-op.
- Revokes EXECUTE on the function from public, anon and authenticated, so it is reachable only as the
  trigger it is attached to.

2. Security
- The function takes no client input, performs no writes, and returns only NEW; it cannot be used to
  read message contents.
*/

CREATE OR REPLACE FUNCTION public.throttle_portfolio_messages()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
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

REVOKE ALL ON FUNCTION public.throttle_portfolio_messages() FROM public;
REVOKE ALL ON FUNCTION public.throttle_portfolio_messages() FROM anon;
REVOKE ALL ON FUNCTION public.throttle_portfolio_messages() FROM authenticated;
