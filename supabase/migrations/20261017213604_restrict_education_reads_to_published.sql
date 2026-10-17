/*
# Restrict education reads to published rows

1. Security
- Replaces the public SELECT policy on `portfolio_education`, previously `USING (true)`.
- Unpublished education entries are now readable only by registered portfolio editors.
- NULL `published` is treated as published so existing rows stay visible.
*/

DROP POLICY IF EXISTS "Public can read portfolio education" ON portfolio_education;

CREATE POLICY "Public can read portfolio education"
ON portfolio_education FOR SELECT
TO anon, authenticated
USING (
  coalesce(published, true) = true
  OR EXISTS (SELECT 1 FROM portfolio_editors WHERE portfolio_editors.user_id = auth.uid())
);
