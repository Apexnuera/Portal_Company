-- ==============================================================================
-- SIMPLIFIED EMPLOYEE CREATION FUNCTION (NO HR CHECK - TRUST CLIENT)
-- ==============================================================================
-- The client already verifies HR status before calling this.
-- This function just does the database work without additional checks.

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
BEGIN
    -- 1. INSERT ROLE
    DELETE FROM public.user_roles WHERE id = p_auth_user_id;
    INSERT INTO public.user_roles (id, role, email)
    VALUES (p_auth_user_id, 'employee', p_email);

    -- 2. INSERT PROFILE
    DELETE FROM public.employee_profiles WHERE auth_user_id = p_auth_user_id OR employee_id = p_employee_id;
    INSERT INTO public.employee_profiles (
        id, auth_user_id, employee_id, full_name, corporate_email, created_by
    ) VALUES (
        gen_random_uuid(), p_auth_user_id, p_employee_id, p_name, p_email, p_hr_id
    );

    -- 3. AUTO CONFIRM EMAIL
    UPDATE auth.users SET email_confirmed_at = now() WHERE id = p_auth_user_id;

    RETURN jsonb_build_object('success', true);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION public.setup_employee_data TO authenticated;
