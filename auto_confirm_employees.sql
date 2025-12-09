-- AUTO-CONFIRM EMPLOYEES CREATED BY HR
-- This script sets up a trigger to automatically confirm email addresses
-- for users created with the metadata { "is_hr_created": true }

-- 1. Create the function that will run on every new user creation
CREATE OR REPLACE FUNCTION public.auto_confirm_hr_created_users()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the user has the 'is_hr_created' metadata flag
  IF NEW.raw_user_meta_data->>'is_hr_created' = 'true' THEN
    -- Auto-confirm the email by setting the confirmed_at timestamp
    NEW.email_confirmed_at = now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create the trigger on the auth.users table
-- We check if trigger exists first to avoid errors (dropping if needed is safer)
DROP TRIGGER IF EXISTS on_auth_user_created_auto_confirm ON auth.users;

CREATE TRIGGER on_auth_user_created_auto_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_confirm_hr_created_users();

-- 3. Verify it works
-- This query helps you verify the trigger exists
SELECT tgname 
FROM pg_trigger
WHERE tgname = 'on_auth_user_created_auto_confirm';
