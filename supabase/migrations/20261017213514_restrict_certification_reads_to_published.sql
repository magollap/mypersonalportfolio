/*
# Restrict certification reads to published rows

1. Security
- Replaces the public SELECT policy on `portfolio_certifications`, which previously used `USING (true)`
  and therefore exposed unpublished draft certifications through the Data API.
- New predicate: a row is visible to anon/authenticated callers when it is published (NULL treated as
  published so existing rows stay visible), or when the caller is a registered portfolio editor.

2. Notes
1. No data is modified; only the read policy changes.
2. Editors keep full visibility of drafts.
*/

DROP POLICY IF EXISTS "Public can read portfolio certifications" ON portfolio_certifications;

CREATE POLICY "Public can read portfolio certifications"
ON portfolio_certifications FOR SELECT
TO anon, authenticated
USING (
  coalesce(published, true) = true
  OR EXISTS (SELECT 1 FROM portfolio_editors WHERE portfolio_editors.user_id = auth.uid())
);
