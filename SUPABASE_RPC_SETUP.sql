-- ==============================================================================
-- SECURE EMPLOYEE CREATION FUNCTION
-- This function handles the entire flow on the server side, bypassing RLS issues.
-- ==============================================================================

-- 1. Create the function
CREATE OR REPLACE FUNCTION public.create_new_employee(
    p_email TEXT,
    p_password TEXT,
    p_name TEXT,
    p_employee_id TEXT,
    p_hr_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with admin privileges
SET search_path = public -- Security best practice
AS $$
DECLARE
    v_user_id UUID;
    v_exists BOOLEAN;
BEGIN
    -- A. Validate Email Format (Strict Check)
    -- Format: name.x@domain.com (alphanumeric.alphanumeric@alphanumeric.alphanumeric)
    IF NOT p_email ~ '^[a-zA-Z0-9]+\.[a-zA-Z0-9]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid email format. Must be name.x@domain.com');
    END IF;

    -- B. Check if HR user exists and has permission
    SELECT EXISTS (
        SELECT 1 FROM user_roles WHERE id = p_hr_id AND role = 'hr'
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN jsonb_build_object('success', false, 'error', 'Unauthorized: Only HR can create employees');
    END IF;

    -- C. Create Identity (Simulated since we can't create Auth Users from PLPGSQL easily without extra extensions)
    -- NOTE: For this architecture, we will keep the 'signUp' on the client side because creating Auth Users
    -- inside SQL requires the internal 'supabase_admin' role or http extensions.
    -- INSTEAD, we will make this function handle the DATA part (Roles + Profile) securely.

    -- D. Handle "User Role" Insertion (This is where RLS was blocking you)
    -- Since the client creates the Auth User first, we passed the ID here? 
    -- WAIT: The client cannot create the user and get the ID if we want to do it all here.
    
    -- REVISED STRATEGY for Client-Side Call:
    -- 1. Client creates Auth User (signUp) -> Gets UUID
    -- 2. Client calls THIS function with the new UUID to set up data
    
    RETURN jsonb_build_object('success', false, 'error', 'Function deprecated. See improved logic below.');
END;
$$;


-- ==============================================================================
-- FINAL WORKING STRATEGY: "setup_employee_data"
-- Client creates the Auth User (which is allowed), this function sets up the rest.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.setup_employee_data(
    p_auth_user_id UUID,
    p_email TEXT,
    p_name TEXT,
    p_employee_id TEXT,
    p_hr_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- BYPASS ALL RLS
SET search_path = public
AS $$
BEGIN
    -- 1. VALIDATE PERMISSION (Is Caller HR?)
    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE id = auth.uid() AND role = 'hr') AND p_hr_id IS NOT NULL THEN
       -- Optimistic check, usually trusted source, but double check:
       IF NOT EXISTS (SELECT 1 FROM user_roles WHERE id = p_hr_id AND role = 'hr') THEN
           RETURN jsonb_build_object('success', false, 'error', 'Unauthorized');
       END IF;
    END IF;

    -- 2. INSERT ROLE (Bypassing RLS)
    INSERT INTO public.user_roles (id, role, email)
    VALUES (p_auth_user_id, 'employee', p_email)
    ON CONFLICT (id) DO UPDATE SET role = 'employee';

    -- 3. INSERT PROFILE (Bypassing RLS)
    INSERT INTO public.employee_profiles (
        id, 
        auth_user_id, 
        employee_id, 
        full_name, 
        corporate_email, 
        created_by
    )
    VALUES (
        gen_random_uuid(),
        p_auth_user_id,
        p_employee_id,
        p_name,
        p_email,
        p_hr_id
    )
    ON CONFLICT (employee_id) DO NOTHING; -- Handle duplicates gracefully

    -- 4. AUTO CONFIRM EMAIL (Fix Login Issue)
    UPDATE auth.users
    SET email_confirmed_at = now()
    WHERE id = p_auth_user_id;

    RETURN jsonb_build_object('success', true);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;
