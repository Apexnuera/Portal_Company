# Fix Permission Denied on Application Submission

## Problem
Users (both authenticated and anonymous) receive a `permission denied for table users` error when submitting job/internship applications.
This is caused by RLS policies on `job_applications` and `internship_applications` that try to `SELECT email FROM auth.users`, which is restricted.

## Solution
Update the RLS policies to use `auth.jwt() ->> 'email'` to retrieve the current user's email from their session token. This avoids querying the restricted `auth.users` table directly.

## Proposed Changes

### Database (SQL)
#### [MODIFY] [SUPABASE_FIX_APPLICATIONS.sql](new)
- Drop existing policies for "Applicant can read own..."
- Create new policies using `auth.jwt() ->> 'email'`.
- Ensure `is_hr_user` function is robust (though not the primary cause of *this* error, it's good to verify).

### Application Code (Dart)
#### [MODIFY] [lib/data/application_store.dart]
- Update `addJobApplication` and `addInternshipApplication`:
    - Catch the exception if `.select().single()` fails (which might happen for Anonymous users who can INSERT but NOT SELECT their own row due to RLS).
    - If it fails but the insert likely worked (or we assume success if no error on insert step), we might need to handle it.
    - better yet, separate `insert` and `select`? No, `.insert().select()` is atomic in the SDK.
    - If insertion worked but selection returned 0 rows (RLS), it throws.
    - For now, the primary fix is the SQL. If anon users still fail (with a different error), we will patch the Dart code.

## Verification Plan
### Automated Tests
- None available for SQL policies.
### Manual Verification
1.  **Run SQL Script**: Execute the new migration.
2.  **Test Job Application**:
    - As **Employee**: Apply for a job. Should succeed.
    - As **Anon** (Incognito): Apply for a job. Should succeed (or at least not say "permission denied").
3.  **Test Internship Application**:
    - As **Employee**: Apply for an internship. Should succeed.
    - As **Anon**: Apply for an internship. Should succeed.
4.  **Verify HR Dashboard**:
    - Login as HR.
    - Check "Applications" tab.
    - Ensure the new applications appear.
