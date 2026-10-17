/*
# Expand portfolio resume sections and content management

1. New Tables
- `portfolio_war_stories` stores operational case studies with environment, symptoms,
  investigation, root cause, resolution, impact, lessons learned, severity, tags,
  publication status, and display order.
- `portfolio_learning` stores learning-journal entries with source, date, notes, tags,
  publication status, and display order.
- `portfolio_social_links` stores editable public social/profile links and display order.

2. Modified Tables
- `portfolio_profile` gains phone, github_url, resume_url, and profile_image_url.
- `portfolio_experience` gains a technologies text array and published status.
- `portfolio_projects` gains slug, problem, architecture, responsibilities, outcomes,
  screenshots text array, github_url, demo_url, tags text array, and detail status fields.
- `portfolio_certifications` gains credential_id, issued_date, expiry_date, badge_url,
  and published status.
- `portfolio_education` gains source_url and published status.
- `portfolio_skills` gains icon and published status.

3. Security
- Row Level Security is enabled on each new table.
- Public visitors can read published portfolio content and public social links.
- Existing portfolio editors can create, update, and delete all new records.
- Existing public-read behavior is preserved for legacy rows.

4. Important Notes
- All additions are nullable or have safe defaults so existing portfolio rows remain valid.
- No existing user data is deleted or renamed.
- Credential IDs, verification URLs, and dates are left empty unless supplied by the resume
  or the owner through the editor; the seed content does not fabricate them.
*/

ALTER TABLE portfolio_profile ADD COLUMN IF NOT EXISTS phone text;
ALTER TABLE portfolio_profile ADD COLUMN IF NOT EXISTS github_url text;
ALTER TABLE portfolio_profile ADD COLUMN IF NOT EXISTS resume_url text;
ALTER TABLE portfolio_profile ADD COLUMN IF NOT EXISTS profile_image_url text;

ALTER TABLE portfolio_experience ADD COLUMN IF NOT EXISTS technologies text[] NOT NULL DEFAULT '{}';
ALTER TABLE portfolio_experience ADD COLUMN IF NOT EXISTS published boolean NOT NULL DEFAULT true;

ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS slug text;
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS problem text;
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS architecture text;
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS responsibilities text;
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS outcomes text;
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS screenshots text[] NOT NULL DEFAULT '{}';
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS github_url text;
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS demo_url text;
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS tags text[] NOT NULL DEFAULT '{}';
ALTER TABLE portfolio_projects ADD COLUMN IF NOT EXISTS draft boolean NOT NULL DEFAULT false;

ALTER TABLE portfolio_certifications ADD COLUMN IF NOT EXISTS credential_id text;
ALTER TABLE portfolio_certifications ADD COLUMN IF NOT EXISTS issued_date date;
ALTER TABLE portfolio_certifications ADD COLUMN IF NOT EXISTS expiry_date date;
ALTER TABLE portfolio_certifications ADD COLUMN IF NOT EXISTS badge_url text;
ALTER TABLE portfolio_certifications ADD COLUMN IF NOT EXISTS published boolean NOT NULL DEFAULT true;

ALTER TABLE portfolio_education ADD COLUMN IF NOT EXISTS source_url text;
ALTER TABLE portfolio_education ADD COLUMN IF NOT EXISTS published boolean NOT NULL DEFAULT true;
ALTER TABLE portfolio_skills ADD COLUMN IF NOT EXISTS icon text;
ALTER TABLE portfolio_skills ADD COLUMN IF NOT EXISTS published boolean NOT NULL DEFAULT true;

CREATE TABLE IF NOT EXISTS portfolio_war_stories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  environment text NOT NULL,
  symptoms text NOT NULL,
  investigation text NOT NULL,
  root_cause text NOT NULL,
  resolution text NOT NULL,
  impact text NOT NULL,
  lessons_learned text NOT NULL,
  severity text NOT NULL DEFAULT 'medium',
  tags text[] NOT NULL DEFAULT '{}',
  published boolean NOT NULL DEFAULT false,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS portfolio_learning (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  source text NOT NULL,
  learned_on date,
  notes text NOT NULL,
  tags text[] NOT NULL DEFAULT '{}',
  published boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS portfolio_social_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label text NOT NULL,
  url text NOT NULL,
  icon text,
  sort_order integer NOT NULL DEFAULT 0,
  published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE portfolio_war_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_learning ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_social_links ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read published war stories" ON portfolio_war_stories;
CREATE POLICY "Public can read published war stories" ON portfolio_war_stories FOR SELECT TO anon, authenticated USING (published = true);
DROP POLICY IF EXISTS "Editors can read all war stories" ON portfolio_war_stories;
CREATE POLICY "Editors can read all war stories" ON portfolio_war_stories FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can add war stories" ON portfolio_war_stories;
CREATE POLICY "Editors can add war stories" ON portfolio_war_stories FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can update war stories" ON portfolio_war_stories;
CREATE POLICY "Editors can update war stories" ON portfolio_war_stories FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can delete war stories" ON portfolio_war_stories;
CREATE POLICY "Editors can delete war stories" ON portfolio_war_stories FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "Public can read published learning" ON portfolio_learning;
CREATE POLICY "Public can read published learning" ON portfolio_learning FOR SELECT TO anon, authenticated USING (published = true);
DROP POLICY IF EXISTS "Editors can read all learning" ON portfolio_learning;
CREATE POLICY "Editors can read all learning" ON portfolio_learning FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can add learning" ON portfolio_learning;
CREATE POLICY "Editors can add learning" ON portfolio_learning FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can update learning" ON portfolio_learning;
CREATE POLICY "Editors can update learning" ON portfolio_learning FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can delete learning" ON portfolio_learning;
CREATE POLICY "Editors can delete learning" ON portfolio_learning FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "Public can read social links" ON portfolio_social_links;
CREATE POLICY "Public can read social links" ON portfolio_social_links FOR SELECT TO anon, authenticated USING (published = true);
DROP POLICY IF EXISTS "Editors can read all social links" ON portfolio_social_links;
CREATE POLICY "Editors can read all social links" ON portfolio_social_links FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can add social links" ON portfolio_social_links;
CREATE POLICY "Editors can add social links" ON portfolio_social_links FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can update social links" ON portfolio_social_links;
CREATE POLICY "Editors can update social links" ON portfolio_social_links FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can delete social links" ON portfolio_social_links;
CREATE POLICY "Editors can delete social links" ON portfolio_social_links FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

CREATE INDEX IF NOT EXISTS portfolio_war_stories_order_idx ON portfolio_war_stories(sort_order);
CREATE INDEX IF NOT EXISTS portfolio_learning_order_idx ON portfolio_learning(sort_order);
CREATE INDEX IF NOT EXISTS portfolio_social_links_order_idx ON portfolio_social_links(sort_order);
CREATE UNIQUE INDEX IF NOT EXISTS portfolio_projects_slug_idx ON portfolio_projects(slug) WHERE slug IS NOT NULL;
