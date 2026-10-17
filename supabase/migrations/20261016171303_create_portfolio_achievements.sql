/*
# Add portfolio achievements table

1. New Tables
- `portfolio_achievements` — career milestones, awards, certifications, and notable accomplishments.
  Columns: id, title, description, category, date, sort_order, created_at.

2. Security
- Row Level Security enabled.
- Public visitors can read achievements.
- Signed-in editors can create, update, and delete achievements.

3. Important Notes
- Achievements are displayed in a dedicated section on the portfolio page.
- Category groups them (e.g., Leadership, Certifications, Milestones).
*/

CREATE TABLE IF NOT EXISTS portfolio_achievements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  category text,
  date text,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE portfolio_achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read portfolio achievements" ON portfolio_achievements;
CREATE POLICY "Public can read portfolio achievements" ON portfolio_achievements FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Signed in users can add portfolio achievements" ON portfolio_achievements;
CREATE POLICY "Signed in users can add portfolio achievements" ON portfolio_achievements FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can update portfolio achievements" ON portfolio_achievements;
CREATE POLICY "Signed in users can update portfolio achievements" ON portfolio_achievements FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Signed in users can delete portfolio achievements" ON portfolio_achievements;
CREATE POLICY "Signed in users can delete portfolio achievements" ON portfolio_achievements FOR DELETE TO authenticated USING (true);

CREATE INDEX IF NOT EXISTS portfolio_achievements_sort_idx ON portfolio_achievements(sort_order);
