# Supabase Jobs & Internships Integration

## Overview
This document describes the integration of Jobs, Internships, and Applications with Supabase for the Company Portal HR system.

## Database Schema

### Tables Created
Run the SQL script `supabase_jobs_schema.sql` in your Supabase SQL Editor to create:

1. **jobs** - Stores job postings
2. **internships** - Stores internship postings
3. **job_applications** - Stores applications for jobs
4. **internship_applications** - Stores applications for internships

### Row Level Security (RLS)
All tables have RLS enabled with the following policies:

- **Jobs & Internships:**
  - Public read access (anyone can view)
  - Only HR users can insert, update, and delete

- **Applications:**
  - Public insert access (anyone can apply)
  - HR users can read, update, and delete all applications
  - Applicants can read their own applications

## Implementation Details

### 1. Data Models (`lib/data/`)

#### `post_store.dart`
- **JobPost** and **InternshipPost** models with `fromJson()` and `toJson()` methods
- **PostStore** singleton with Supabase integration:
  - `fetchPosts()` - Loads all jobs and internships from Supabase
  - `addJob()` / `addInternship()` - Creates new postings
  - `updateJob()` / `updateInternship()` - Updates existing postings
  - `deleteJob()` / `deleteInternship()` - Deletes postings

#### `application_store.dart`
- **JobApplication** and **InternshipApplication** models with `fromJson()` and `toJson()` methods
- **ApplicationStore** singleton with Supabase integration:
  - `fetchApplications()` - Loads all applications from Supabase
  - `addJobApplication()` / `addInternshipApplication()` - Creates new applications
  - `updateJobApplicationStatus()` / `updateInternshipApplicationStatus()` - Updates application status
  - `deleteJobApplication()` / `deleteInternshipApplication()` - Deletes applications

### 2. HR Dashboard (`lib/pages/hr_dashboard_page.dart`)

#### Features Added:
- **Data Loading:** Automatically fetches posts and applications on page init
- **Job Management:**
  - Create new job postings with full details
  - Edit existing job postings (inline form)
  - Delete job postings
  - View all applications for jobs
- **Internship Management:**
  - Create new internship postings
  - Edit existing internship postings (inline form)
  - Delete internship postings
  - View all applications for internships
- **Application Management:**
  - View all job and internship applications
  - Download resumes (base64 encoded)
  - Update application status (In Progress, Selected, Rejected)
  - Delete applications

### 3. Public Job/Internship Pages

#### `jobs_listing_page.dart` & `internships_listing_page.dart`
- Automatically fetch and display posts from Supabase on page load
- Search functionality
- Responsive grid layout
- Click to view details

#### `job_application_form_page.dart`
- Updated to capture resume file data (base64 encoded)
- Async submission to Supabase
- Error handling with user feedback
- Stores applications in Supabase for HR review

### 4. Resume Upload (`lib/utils/`)

#### `resume_picker_web.dart`
- Updated to return both file name and base64 data
- Uses FileReader API to encode resume files
- Supports PDF, DOC, DOCX formats

## Workflow

### HR Posts a Job:
1. HR logs into dashboard
2. Navigates to "Jobs" section
3. Fills out job posting form
4. Clicks "Submit Job"
5. Job is saved to Supabase `jobs` table
6. Job immediately appears in HR dashboard and public Jobs page

### User Applies for Job:
1. User browses Jobs page (public access)
2. Clicks on a job to view details
3. Clicks "Apply Now"
4. Fills out application form with email and resume
5. Submits application
6. Application is saved to Supabase `job_applications` table
7. Application appears in HR dashboard under "Job Applications"

### HR Reviews Applications:
1. HR views applications in dashboard
2. Can download resumes
3. Can update application status
4. Can delete applications

### HR Edits a Job:
1. HR navigates to "Jobs" section
2. Clicks "Edit" button next to a job
3. Form populates with existing job data
4. HR makes changes
5. Clicks "Update Job"
6. Changes are saved to Supabase
7. Updated job appears everywhere immediately

## Setup Instructions

1. **Run Database Schema:**
   ```sql
   -- Execute supabase_jobs_schema.sql in Supabase SQL Editor
   ```

2. **Verify RLS Policies:**
   - Ensure `user_roles` table exists (from previous setup)
   - Verify HR users have role='hr' in `user_roles` table

3. **Test the Flow:**
   - Login as HR user
   - Create a test job posting
   - Logout and view the job on public Jobs page
   - Apply for the job
   - Login as HR again and verify application appears

## Key Features

✅ **Real-time Sync:** All changes immediately reflected across the app
✅ **Edit Functionality:** Full CRUD operations for jobs and internships
✅ **Resume Storage:** Base64 encoded resumes stored in database
✅ **Secure Access:** RLS policies ensure only HR can manage posts
✅ **Public Applications:** Anyone can view and apply for jobs
✅ **Status Tracking:** Applications can be marked as In Progress, Selected, or Rejected

## Files Modified

- `lib/data/post_store.dart` - Added Supabase integration
- `lib/data/application_store.dart` - Added Supabase integration
- `lib/pages/hr_dashboard_page.dart` - Added edit functionality, data fetching
- `lib/jobs_listing_page.dart` - Added data fetching
- `lib/internships_listing_page.dart` - Added data fetching
- `lib/pages/job_application_form_page.dart` - Added resume data capture
- `lib/utils/resume_picker_web.dart` - Added base64 encoding
- `lib/utils/resume_picker_stub.dart` - Updated signature

## Files Created

- `supabase_jobs_schema.sql` - Database schema and RLS policies
- `SUPABASE_JOBS_INTEGRATION.md` - This documentation

## Next Steps

1. **Test thoroughly** in your Supabase environment
2. **Consider adding:**
   - File size limits for resume uploads
   - Email notifications when applications are received
   - Application deadline enforcement
   - Advanced search and filtering
   - Bulk operations for applications
   - Export applications to CSV

## Troubleshooting

**Issue:** Jobs not appearing on public page
- **Solution:** Check that `fetchPosts()` is being called in `initState()`
- **Solution:** Verify RLS policies allow public read access

**Issue:** Can't create job as HR
- **Solution:** Verify HR user has `role='hr'` in `user_roles` table
- **Solution:** Check Supabase logs for RLS policy violations

**Issue:** Resume upload fails
- **Solution:** Check file size (browser limits may apply)
- **Solution:** Verify file format is PDF, DOC, or DOCX

**Issue:** Applications not appearing in HR dashboard
- **Solution:** Verify `fetchApplications()` is being called
- **Solution:** Check that application was successfully inserted into Supabase
