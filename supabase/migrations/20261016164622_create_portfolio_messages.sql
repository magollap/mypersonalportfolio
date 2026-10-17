/*
# Add portfolio contact inbox

1. New Tables
- `portfolio_messages` — visitor name, email, message, and creation timestamp for contact form submissions.

2. Security
- Row Level Security is enabled.
- Anonymous and authenticated visitors may submit messages.
- Only signed-in editors may read or delete messages.

3. Important Notes
- The contact form writes directly to the shared portfolio inbox.
- The email field is stored as submitted so the owner can reply.
*/

CREATE TABLE IF NOT EXISTS portfolio_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  message text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE portfolio_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Visitors can submit portfolio messages" ON portfolio_messages;
CREATE POLICY "Visitors can submit portfolio messages" ON portfolio_messages FOR INSERT TO anon, authenticated WITH CHECK (char_length(name) BETWEEN 1 AND 120 AND char_length(email) BETWEEN 3 AND 320 AND char_length(message) BETWEEN 1 AND 5000);
DROP POLICY IF EXISTS "Signed in editors can read portfolio messages" ON portfolio_messages;
CREATE POLICY "Signed in editors can read portfolio messages" ON portfolio_messages FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Signed in editors can delete portfolio messages" ON portfolio_messages;
CREATE POLICY "Signed in editors can delete portfolio messages" ON portfolio_messages FOR DELETE TO authenticated USING (true);
