-- ==============================================================================
-- ROBUST EMPLOYEE CREATION FUNCTION (FINAL VERSION)
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
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_exists BOOLEAN;
BEGIN
    -- 1. VERIFY THE AUTH USER EXISTS
    SELECT EXISTS (
        SELECT 1 FROM auth.users WHERE id = p_auth_user_id
    ) INTO v_user_exists;

    IF NOT v_user_exists THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', 'Auth user not found. User may have been deleted or not fully created. Try deleting from Dashboard and recreating.'
        );
    END IF;

    -- 2. VALIDATE HR PERMISSION
    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE id = p_hr_id AND role = 'hr') THEN
        RETURN jsonb_build_object('success', false, 'error', 'Unauthorized: Only HR can create employees');
    END IF;

    -- 3. INSERT ROLE (Bypassing RLS)
    -- Delete existing first to avoid conflicts
    DELETE FROM public.user_roles WHERE id = p_auth_user_id;
    
    INSERT INTO public.user_roles (id, role, email)
    VALUES (p_auth_user_id, 'employee', p_email);

    -- 4. INSERT PROFILE (Bypassing RLS)
    -- Delete existing first to avoid conflicts
    DELETE FROM public.employee_profiles WHERE auth_user_id = p_auth_user_id OR employee_id = p_employee_id;
    
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
    );

    -- 5. AUTO CONFIRM EMAIL (Fix Login Issue)
    UPDATE auth.users
    SET email_confirmed_at = COALESCE(email_confirmed_at, now())
    WHERE id = p_auth_user_id;

    RETURN jsonb_build_object('success', true);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- Grant execution permission
GRANT EXECUTE ON FUNCTION public.setup_employee_data TO authenticated;
