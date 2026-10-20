/*
# Simplify the contact message throttle trigger

1. Changes
- Removes the `NEW.id := COALESCE(...)` line from `throttle_portfolio_messages()`. The column
  default already assigns the id, and an unqualified `gen_random_uuid()` call would fail under the
  function's empty search_path if it were ever reached.
- `NEW.created_at := now()` is kept: it is what makes the rate limit unforgeable.

2. Security
- No change in exposure; this removes a latent error path introduced by the previous migration.
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
  NEW.created_at := now();

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
