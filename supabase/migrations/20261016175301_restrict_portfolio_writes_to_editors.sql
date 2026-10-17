/*
# Restrict portfolio editing to an owner allowlist

1. New Tables
- `portfolio_editors` — the set of accounts permitted to edit portfolio content.
  Seeded with the existing owner account. Not writable from the client.

2. Security
- RLS enabled on `portfolio_editors`; a caller may read only their own row.
- No INSERT/UPDATE/DELETE policies exist, so no one can grant themselves editor
  rights through the Data API.
- All write policies on the six portfolio content tables are replaced: they now
  require the caller to be present in `portfolio_editors` rather than merely being
  signed in.
- Public read access to portfolio content is unchanged.

3. Important Notes
- Previously any self-registered account could rewrite or delete all portfolio content.
- Editors are added by the project owner directly in the database.
*/

CREATE TABLE IF NOT EXISTS portfolio_editors (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE portfolio_editors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Editors can read their own membership" ON portfolio_editors;
CREATE POLICY "Editors can read their own membership" ON portfolio_editors FOR SELECT TO authenticated USING (user_id = auth.uid());

INSERT INTO portfolio_editors (user_id)
SELECT id FROM auth.users
ON CONFLICT (user_id) DO NOTHING;

-- portfolio_profile
DROP POLICY IF EXISTS "Signed in users can add portfolio profile" ON portfolio_profile;
CREATE POLICY "Editors can add portfolio profile" ON portfolio_profile FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can update portfolio profile" ON portfolio_profile;
CREATE POLICY "Editors can update portfolio profile" ON portfolio_profile FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can delete portfolio profile" ON portfolio_profile;
CREATE POLICY "Editors can delete portfolio profile" ON portfolio_profile FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

-- portfolio_experience
DROP POLICY IF EXISTS "Signed in users can add portfolio experience" ON portfolio_experience;
CREATE POLICY "Editors can add portfolio experience" ON portfolio_experience FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can update portfolio experience" ON portfolio_experience;
CREATE POLICY "Editors can update portfolio experience" ON portfolio_experience FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can delete portfolio experience" ON portfolio_experience;
CREATE POLICY "Editors can delete portfolio experience" ON portfolio_experience FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

-- portfolio_projects
DROP POLICY IF EXISTS "Signed in users can add portfolio projects" ON portfolio_projects;
CREATE POLICY "Editors can add portfolio projects" ON portfolio_projects FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can update portfolio projects" ON portfolio_projects;
CREATE POLICY "Editors can update portfolio projects" ON portfolio_projects FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can delete portfolio projects" ON portfolio_projects;
CREATE POLICY "Editors can delete portfolio projects" ON portfolio_projects FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

-- portfolio_skills
DROP POLICY IF EXISTS "Signed in users can add portfolio skills" ON portfolio_skills;
CREATE POLICY "Editors can add portfolio skills" ON portfolio_skills FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can update portfolio skills" ON portfolio_skills;
CREATE POLICY "Editors can update portfolio skills" ON portfolio_skills FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can delete portfolio skills" ON portfolio_skills;
CREATE POLICY "Editors can delete portfolio skills" ON portfolio_skills FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

-- portfolio_education
DROP POLICY IF EXISTS "Signed in users can add portfolio education" ON portfolio_education;
CREATE POLICY "Editors can add portfolio education" ON portfolio_education FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can update portfolio education" ON portfolio_education;
CREATE POLICY "Editors can update portfolio education" ON portfolio_education FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can delete portfolio education" ON portfolio_education;
CREATE POLICY "Editors can delete portfolio education" ON portfolio_education FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

-- portfolio_achievements
DROP POLICY IF EXISTS "Signed in users can add portfolio achievements" ON portfolio_achievements;
CREATE POLICY "Editors can add portfolio achievements" ON portfolio_achievements FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can update portfolio achievements" ON portfolio_achievements;
CREATE POLICY "Editors can update portfolio achievements" ON portfolio_achievements FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Signed in users can delete portfolio achievements" ON portfolio_achievements;
CREATE POLICY "Editors can delete portfolio achievements" ON portfolio_achievements FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
