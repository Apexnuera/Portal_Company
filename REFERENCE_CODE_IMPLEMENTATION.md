# Reference Code Implementation Summary

## What Was Implemented

Added custom reference codes (like "JOB-2024-001") to jobs and internships while keeping UUID as the primary key in the database.

## Database Changes

### 1. Run Migration Script
Execute `supabase_add_reference_codes.sql` in your Supabase SQL Editor:

```sql
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS reference_code TEXT;
ALTER TABLE internships ADD COLUMN IF NOT EXISTS reference_code TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS jobs_reference_code_idx ON jobs(reference_code) WHERE reference_code IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS internships_reference_code_idx ON internships(reference_code) WHERE reference_code IS NOT NULL;
```

## Code Changes

### 1. Data Models (`lib/data/post_store.dart`)
- Added `referenceCode` field to `JobPost` and `InternshipPost`
- Updated `fromJson()` to deserialize `reference_code` from database
- Updated `toJson()` to serialize `reference_code` to database

### 2. HR Dashboard (`lib/pages/hr_dashboard_page.dart`)
- Added back "Job ID / Reference" field to the form
- Auto-generates reference like "JOB-1234567" for new jobs
- HR can customize the reference code
- When editing, the existing reference code is loaded
- Job listings show reference code instead of UUID

### 3. Public Jobs Page (`lib/jobs_listing_page.dart`)
- Updated to display reference code instead of UUID in job cards

## How It Works

### Creating a New Job:
1. HR opens the job creation form
2. Reference code is auto-generated: `JOB-1234567`
3. HR can edit it to something like `JOB-2024-SE-001`
4. On submit:
   - Supabase generates UUID for `id` (e.g., `abc-123-def-456`)
   - Reference code is stored in `reference_code` column
5. Job appears with the custom reference code

### Editing an Existing Job:
1. HR clicks "Edit" on a job
2. Form populates with existing data including reference code
3. HR can modify the reference code
4. On update, the reference code is updated in the database

### Display:
- **HR Dashboard**: Shows reference code (or UUID if no reference code)
- **Public Jobs Page**: Shows reference code (or UUID if no reference code)
- **Database**: Uses UUID as primary key for relationships

## Benefits

✅ **User-Friendly**: HR can use memorable codes like "JOB-2024-001"
✅ **Database-Safe**: UUID primary keys prevent conflicts
✅ **Flexible**: Reference code is optional
✅ **Unique**: Database enforces uniqueness on reference codes
✅ **Backward Compatible**: Falls back to UUID if no reference code

## Example

```dart
// Creating a job
JobPost(
  id: '',  // Supabase will generate: 'abc-123-def-456'
  referenceCode: 'JOB-2024-SE-001',  // HR-friendly reference
  title: 'Senior Engineer',
  ...
)

// In database:
// id: 'abc-123-def-456' (UUID, primary key)
// reference_code: 'JOB-2024-SE-001' (optional, unique)

// Displayed to users: "JOB-2024-SE-001"
```

## Testing

1. Run the migration script in Supabase
2. Create a new job in HR dashboard
3. Verify the auto-generated reference code appears
4. Customize it to something like "JOB-2024-001"
5. Submit and verify it appears in:
   - HR dashboard job list
   - Public jobs page
6. Edit the job and verify reference code can be updated
