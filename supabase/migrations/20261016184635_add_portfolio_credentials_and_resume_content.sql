/*
# Add credentials and enrich resume content

1. New Tables
- `portfolio_certifications` stores credential or professional-development entries.
- `id` is the generated identifier.
- `name` is the credential or program name.
- `issuer` is the awarding or teaching organization.
- `date` stores the completion or validity label.
- `credential_url` optionally links to verification details.
- `description` explains the focus of the credential.
- `sort_order` controls display order.

2. Modified Content
- Existing experience and project records are enriched with clearer organizational roles,
  responsibilities, and outcomes when matching records are present.
- A postgraduate AI and machine-learning program is added as professional development only
  when it is not already represented in the credentials table.

3. Security
- Row Level Security is enabled on `portfolio_certifications`.
- Public visitors may read credential entries.
- Only existing members of `portfolio_editors` may create, update, or delete them.

4. Important Notes
- No certification is fabricated. The existing postgraduate AI/ML program is labeled as
  professional development, not as a certification.
- Existing rows are updated in place; no portfolio data is deleted.
*/

CREATE TABLE IF NOT EXISTS portfolio_certifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  issuer text NOT NULL,
  date text,
  credential_url text,
  description text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE portfolio_certifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read portfolio certifications" ON portfolio_certifications;
CREATE POLICY "Public can read portfolio certifications" ON portfolio_certifications FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Editors can add portfolio certifications" ON portfolio_certifications;
CREATE POLICY "Editors can add portfolio certifications" ON portfolio_certifications FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can update portfolio certifications" ON portfolio_certifications;
CREATE POLICY "Editors can update portfolio certifications" ON portfolio_certifications FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Editors can delete portfolio certifications" ON portfolio_certifications;
CREATE POLICY "Editors can delete portfolio certifications" ON portfolio_certifications FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

CREATE INDEX IF NOT EXISTS portfolio_certifications_sort_idx ON portfolio_certifications(sort_order);

UPDATE portfolio_experience
SET description = CASE
  WHEN company = 'Ericsson' THEN 'Lead technical delivery for resilient enterprise platforms, translating operational requirements into dependable Linux, virtualization, and high-availability solutions. Coordinate across teams, guide incident response, and create the clarity engineers need to deliver safely under pressure.'
  WHEN company = 'IBM' THEN 'Served as the Linux subject-matter expert for IBM’s Telstra engagement, supporting enterprise Linux and Solaris environments, resolving complex platform issues, and helping teams operate critical services with discipline and confidence.'
  WHEN company = 'CMS Computers Ltd' THEN 'Led a 40-member engineering team, combining hands-on Linux expertise with people leadership, technical direction, mentoring, and structured support for customer environments.'
  ELSE description
END
WHERE company IN ('Ericsson', 'IBM', 'CMS Computers Ltd');

UPDATE portfolio_projects
SET summary = CASE
  WHEN title = 'High availability operations' THEN 'Designed and strengthened the operating practices behind highly available enterprise platforms. The work brought together Linux administration, cluster management, incident leadership, and clear runbooks so teams could protect service continuity and recover with confidence.'
  WHEN title = 'Virtualization management' THEN 'Created a more structured approach to virtualization and infrastructure operations, balancing platform stability, capacity, change discipline, and practical automation. The focus was not only on the technology, but on helping teams support it consistently.'
  ELSE summary
END
WHERE title IN ('High availability operations', 'Virtualization management');

INSERT INTO portfolio_certifications (name, issuer, date, description, sort_order)
SELECT 'Postgraduate Program — Artificial Intelligence and Machine Learning', 'Texas McCombs School of Business', 'Professional development', 'Advanced study that extends a systems and operations background into artificial intelligence, machine learning, and the practical use of emerging technology.', 1
WHERE NOT EXISTS (
  SELECT 1 FROM portfolio_certifications
  WHERE name = 'Postgraduate Program — Artificial Intelligence and Machine Learning'
);
