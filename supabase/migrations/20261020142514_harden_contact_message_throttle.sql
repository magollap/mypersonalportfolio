/*
# Make the contact message throttle unforgeable

1. Changes
- `throttle_portfolio_messages()` now overwrites `NEW.created_at` with `now()` before counting
  recent messages, so a caller cannot backdate a row out of the rate-limit window.
- Table-wide INSERT on `portfolio_messages` is replaced with column-level INSERT on
  `(name, email, message)` for anon and authenticated.

2. Security
- Previously anon held INSERT on every column including `created_at`; sending an old timestamp made
  the 20-per-hour throttle count zero rows and the owner's inbox could be flooded.

3. Notes
1. The app only inserts name, email and message, so the narrowed grant breaks no existing query.
2. `id` and `created_at` keep their defaults and are now server-assigned.
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
  NEW.id := COALESCE(NEW.id, gen_random_uuid());

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

REVOKE INSERT ON public.portfolio_messages FROM anon;
REVOKE INSERT ON public.portfolio_messages FROM authenticated;

GRANT INSERT (name, email, message) ON public.portfolio_messages TO anon;
GRANT INSERT (name, email, message) ON public.portfolio_messages TO authenticated;
