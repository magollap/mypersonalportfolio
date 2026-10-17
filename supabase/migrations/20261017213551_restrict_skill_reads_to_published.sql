/*
# Restrict skill reads to published rows

1. Security
- Replaces the public SELECT policy on `portfolio_skills`, previously `USING (true)`.
- Unpublished skills are now readable only by registered portfolio editors.
- NULL `published` is treated as published so existing rows stay visible.
*/

DROP POLICY IF EXISTS "Public can read portfolio skills" ON portfolio_skills;

CREATE POLICY "Public can read portfolio skills"
ON portfolio_skills FOR SELECT
TO anon, authenticated
USING (
  coalesce(published, true) = true
  OR EXISTS (SELECT 1 FROM portfolio_editors WHERE portfolio_editors.user_id = auth.uid())
);
