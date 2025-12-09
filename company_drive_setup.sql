-- Company Drive Schema for Supabase
-- This creates a hierarchical file/folder structure with Supabase Storage integration

-- Create drive_items table
CREATE TABLE IF NOT EXISTS drive_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  is_folder BOOLEAN NOT NULL DEFAULT false,
  parent_id UUID REFERENCES drive_items(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id),
  
  -- For files only
  file_size BIGINT,
  mime_type TEXT,
  storage_path TEXT, -- Path in Supabase Storage
  
  CONSTRAINT valid_folder CHECK (
    (is_folder = true AND file_size IS NULL AND mime_type IS NULL AND storage_path IS NULL)
    OR
    (is_folder = false AND file_size IS NOT NULL)
  )
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_drive_items_parent ON drive_items(parent_id);
CREATE INDEX IF NOT EXISTS idx_drive_items_created_by ON drive_items(created_by);
CREATE INDEX IF NOT EXISTS idx_drive_items_name ON drive_items(name);
CREATE INDEX IF NOT EXISTS idx_drive_items_is_folder ON drive_items(is_folder);

-- Enable RLS
ALTER TABLE drive_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "HR can view all drive items" ON drive_items;
DROP POLICY IF EXISTS "HR can insert drive items" ON drive_items;
DROP POLICY IF EXISTS "HR can update drive items" ON drive_items;
DROP POLICY IF EXISTS "HR can delete drive items" ON drive_items;

-- Policies: Only HR can access Company Drive

-- HR can view all items
CREATE POLICY "HR can view all drive items"
  ON drive_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can insert items
CREATE POLICY "HR can insert drive items"
  ON drive_items
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can update items
CREATE POLICY "HR can update drive items"
  ON drive_items
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can delete items
CREATE POLICY "HR can delete drive items"
  ON drive_items
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Grant permissions
GRANT ALL ON drive_items TO authenticated;

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE drive_items;

-- Create storage bucket for company drive files
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-drive', 'company-drive', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for company-drive bucket
-- Drop existing policies
DROP POLICY IF EXISTS "HR can upload files" ON storage.objects;
DROP POLICY IF EXISTS "HR can view files" ON storage.objects;
DROP POLICY IF EXISTS "HR can update files" ON storage.objects;
DROP POLICY IF EXISTS "HR can delete files" ON storage.objects;

-- HR can upload files to company-drive bucket
CREATE POLICY "HR can upload files"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'company-drive'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can view files in company-drive bucket
CREATE POLICY "HR can view files"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'company-drive'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can update files in company-drive bucket
CREATE POLICY "HR can update files"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'company-drive'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can delete files from company-drive bucket
CREATE POLICY "HR can delete files"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'company-drive'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_drive_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS drive_items_updated_at ON drive_items;
CREATE TRIGGER drive_items_updated_at
  BEFORE UPDATE ON drive_items
  FOR EACH ROW
  EXECUTE FUNCTION update_drive_items_updated_at();
