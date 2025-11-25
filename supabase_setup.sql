-- Supabase Database Setup Script
-- Run this script in your Supabase SQL Editor

-- Create user_roles table to store user role assignments
CREATE TABLE IF NOT EXISTS user_roles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('hr', 'employee')),
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own role
CREATE POLICY "Users can read their own role"
  ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

-- Create policy for service role to insert/update roles
-- (Only authenticated admins/service accounts should be able to modify roles)
CREATE POLICY "Service role can manage user roles"
  ON user_roles
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS user_roles_email_idx ON user_roles(email);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER update_user_roles_updated_at
  BEFORE UPDATE ON user_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample test users (REPLACE WITH YOUR ACTUAL TEST DATA)
-- Note: You need to create users in Supabase Auth first, then add their roles here

-- Example: After creating users in Supabase Auth, insert their roles like this:
-- INSERT INTO user_roles (id, role, email)
-- VALUES 
--   ('user-uuid-from-auth-users', 'employee', 'employee@test.com'),
--   ('user-uuid-from-auth-users', 'hr', 'hr@test.com');

-- To find user UUIDs, run:
-- SELECT id, email FROM auth.users;
