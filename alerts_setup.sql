-- Drop existing table if you want to recreate (CAREFUL: This deletes data!)
-- DROP TABLE IF EXISTS alerts CASCADE;

-- Create alerts table
CREATE TABLE IF NOT EXISTS alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Everyone can view active alerts" ON alerts;
DROP POLICY IF EXISTS "HR can view all alerts" ON alerts;
DROP POLICY IF EXISTS "HR can insert alerts" ON alerts;
DROP POLICY IF EXISTS "HR can update alerts" ON alerts;
DROP POLICY IF EXISTS "HR can delete alerts" ON alerts;

-- Policies (using PERMISSIVE which is OR logic by default)

-- Combined SELECT policy: HR can see all, others can see only active
CREATE POLICY "View alerts policy"
  ON alerts
  FOR SELECT
  USING (
    -- Either the alert is active (everyone can see)
    is_active = true
    OR
    -- Or the user is HR (can see all)
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can insert alerts
CREATE POLICY "HR can insert alerts"
  ON alerts
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can update alerts
CREATE POLICY "HR can update alerts"
  ON alerts
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can delete alerts
CREATE POLICY "HR can delete alerts"
  ON alerts
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Grant permissions
GRANT SELECT ON alerts TO anon;
GRANT ALL ON alerts TO authenticated;

-- Enable realtime for alerts table
ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
