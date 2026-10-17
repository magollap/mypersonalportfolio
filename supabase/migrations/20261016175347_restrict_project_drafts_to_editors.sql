/*
# Hide unpublished projects from non-editor accounts

1. Security
- The SELECT policy on `portfolio_projects` previously revealed unpublished drafts to
  every signed-in account via `auth.role() = 'authenticated'`. Drafts are now visible
  only to accounts present in `portfolio_editors`.
- Published projects remain readable by anonymous and signed-in visitors.
*/

DROP POLICY IF EXISTS "Public can read published projects" ON portfolio_projects;
CREATE POLICY "Public can read published projects" ON portfolio_projects FOR SELECT TO anon, authenticated USING (published = true OR EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
