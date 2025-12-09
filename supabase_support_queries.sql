-- Create support_queries table
CREATE TABLE IF NOT EXISTS support_queries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved')),
  resolved_at TIMESTAMPTZ,
  resolved_by TEXT,
  notes TEXT
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_support_queries_created_at ON support_queries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_queries_status ON support_queries(status);
CREATE INDEX IF NOT EXISTS idx_support_queries_email ON support_queries(email);

-- Enable Row Level Security
ALTER TABLE support_queries ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anyone to insert support queries (for public submission)
CREATE POLICY "Anyone can submit support queries"
  ON support_queries
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Policy: Only HR users can view all support queries
CREATE POLICY "HR can view all support queries"
  ON support_queries
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: Only HR users can update support queries (change status, add notes)
CREATE POLICY "HR can update support queries"
  ON support_queries
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: Only HR users can delete support queries
CREATE POLICY "HR can delete support queries"
  ON support_queries
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Grant permissions
GRANT SELECT, INSERT ON support_queries TO anon;
GRANT ALL ON support_queries TO authenticated;
