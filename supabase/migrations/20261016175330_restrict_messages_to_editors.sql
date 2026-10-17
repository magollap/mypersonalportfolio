/*
# Restrict the contact inbox to portfolio editors

1. Security
- The SELECT and DELETE policies on `portfolio_messages` previously allowed any
  signed-in account to read and delete every visitor message. They now require the
  caller to be present in `portfolio_editors`.
- The anonymous INSERT policy and its length validation are unchanged, so the public
  contact form continues to work for visitors.

2. Important Notes
- Visitor names, email addresses, and message text are private to the owner.
*/

DROP POLICY IF EXISTS "Signed in editors can read portfolio messages" ON portfolio_messages;
CREATE POLICY "Editors can read portfolio messages" ON portfolio_messages FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "Signed in editors can delete portfolio messages" ON portfolio_messages;
CREATE POLICY "Editors can delete portfolio messages" ON portfolio_messages FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM portfolio_editors WHERE user_id = auth.uid()));
