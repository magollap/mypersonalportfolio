/*
# Create portfolio content system

1. New Tables
- `portfolio_profile` — the public headline, bio, contact links, and availability message.
- `portfolio_experience` — career history entries with role, company, dates, and description.
- `portfolio_projects` — portfolio work with summary, skills, links, and display order.
- `portfolio_skills` — named capabilities grouped by category.
- `portfolio_education` — education records with institution, program, and dates.

2. Security
- Row Level Security is enabled on every table.
- Public visitors can read published portfolio content.
- Signed-in users can create, update, and delete content through the editor.
- The editor uses Supabase email/password authentication in the application.

3. Important Notes
- This is a single-portfolio site, so content is intentionally shared publicly.
- Content ordering is controlled by `sort_order` columns.
- Only published projects and profile records are shown on the public page.
*/

CREATE TABLE IF NOT EXISTS portfolio_profile (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  headline text NOT NULL,
  location text,
  bio text NOT NULL,
  email text,
  linkedin_url text,
  website_url text,
  availability text,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS portfolio_experience (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company text NOT NULL,
  role text NOT NULL,
  start_date text NOT NULL,
  end_date text,
  location text,
  description text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS portfolio_projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  summary text NOT NULL,
  category text,
  technologies text[] NOT NULL DEFAULT '{}',
  project_url text,
  featured boolean NOT NULL DEFAULT false,
  published boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS portfolio_skills (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  proficiency text,
  sort_order integer NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS portfolio_education (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  institution text NOT NULL,
  program text NOT NULL,
  dates text,
  detail text,
  sort_order integer NOT NULL DEFAULT 0
);

ALTER TABLE portfolio_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_education ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read portfolio profile" ON portfolio_profile;
CREATE POLICY "Public can read portfolio profile" ON portfolio_profile FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Signed in users can add portfolio profile" ON portfolio_profile;
CREATE POLICY "Signed in users can add portfolio profile" ON portfolio_profile FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can update portfolio profile" ON portfolio_profile;
CREATE POLICY "Signed in users can update portfolio profile" ON portfolio_profile FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can delete portfolio profile" ON portfolio_profile;
CREATE POLICY "Signed in users can delete portfolio profile" ON portfolio_profile FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read portfolio experience" ON portfolio_experience;
CREATE POLICY "Public can read portfolio experience" ON portfolio_experience FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Signed in users can add portfolio experience" ON portfolio_experience;
CREATE POLICY "Signed in users can add portfolio experience" ON portfolio_experience FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can update portfolio experience" ON portfolio_experience;
CREATE POLICY "Signed in users can update portfolio experience" ON portfolio_experience FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can delete portfolio experience" ON portfolio_experience;
CREATE POLICY "Signed in users can delete portfolio experience" ON portfolio_experience FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read published projects" ON portfolio_projects;
CREATE POLICY "Public can read published projects" ON portfolio_projects FOR SELECT TO anon, authenticated USING (published = true OR auth.role() = 'authenticated');
DROP POLICY IF EXISTS "Signed in users can add portfolio projects" ON portfolio_projects;
CREATE POLICY "Signed in users can add portfolio projects" ON portfolio_projects FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can update portfolio projects" ON portfolio_projects;
CREATE POLICY "Signed in users can update portfolio projects" ON portfolio_projects FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can delete portfolio projects" ON portfolio_projects;
CREATE POLICY "Signed in users can delete portfolio projects" ON portfolio_projects FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read portfolio skills" ON portfolio_skills;
CREATE POLICY "Public can read portfolio skills" ON portfolio_skills FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Signed in users can add portfolio skills" ON portfolio_skills;
CREATE POLICY "Signed in users can add portfolio skills" ON portfolio_skills FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can update portfolio skills" ON portfolio_skills;
CREATE POLICY "Signed in users can update portfolio skills" ON portfolio_skills FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can delete portfolio skills" ON portfolio_skills;
CREATE POLICY "Signed in users can delete portfolio skills" ON portfolio_skills FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read portfolio education" ON portfolio_education;
CREATE POLICY "Public can read portfolio education" ON portfolio_education FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Signed in users can add portfolio education" ON portfolio_education;
CREATE POLICY "Signed in users can add portfolio education" ON portfolio_education FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can update portfolio education" ON portfolio_education;
CREATE POLICY "Signed in users can update portfolio education" ON portfolio_education FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can delete portfolio education" ON portfolio_education;
CREATE POLICY "Signed in users can delete portfolio education" ON portfolio_education FOR DELETE TO authenticated USING (true);

CREATE INDEX IF NOT EXISTS portfolio_experience_sort_idx ON portfolio_experience(sort_order);
CREATE INDEX IF NOT EXISTS portfolio_projects_sort_idx ON portfolio_projects(sort_order);
CREATE INDEX IF NOT EXISTS portfolio_skills_sort_idx ON portfolio_skills(sort_order);
CREATE INDEX IF NOT EXISTS portfolio_education_sort_idx ON portfolio_education(sort_order);
