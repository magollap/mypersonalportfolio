/*
# Restrict experience reads to published rows

1. Security
- Replaces the public SELECT policy on `portfolio_experience`, which previously used `USING (true)`.
- Unpublished experience entries are now visible only to registered portfolio editors.
- NULL `published` is treated as published so all existing rows remain publicly visible.
*/

DROP POLICY IF EXISTS "Public can read portfolio experience" ON portfolio_experience;

CREATE POLICY "Public can read portfolio experience"
ON portfolio_experience FOR SELECT
TO anon, authenticated
USING (
  coalesce(published, true) = true
  OR EXISTS (SELECT 1 FROM portfolio_editors WHERE portfolio_editors.user_id = auth.uid())
);
