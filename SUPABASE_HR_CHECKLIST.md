# ✅ Supabase HR Features - Quick Start Checklist

Follow this checklist to integrate Supabase for Jobs, Internships, and Employee management.

---

## 📋 Pre-requisites

- [ ] Supabase project created
- [ ] Supabase credentials updated in `lib/config/supabase_config.dart`
- [ ] `supabase_complete_setup.sql` already run (for user_roles and employee_profiles)
- [ ] HR user created and role assigned

---

## 🗄️ Step 1: Database Setup (5 minutes)

### 1.1 Run SQL Script

- [ ] Open Supabase Dashboard → SQL Editor
- [ ] Open `supabase_hr_features_setup.sql`
- [ ] Copy entire content
- [ ] Paste into SQL Editor
- [ ] Click "Run" (Ctrl+Enter)
- [ ] Wait for "Success" message

### 1.2 Verify Tables Created

- [ ] Go to Table Editor
- [ ] Verify these tables exist:
  - [ ] `jobs`
  - [ ] `internships`
  - [ ] `job_applications`
  - [ ] `internship_applications`

### 1.3 Verify RLS Policies

- [ ] Click on `jobs` table → Policies tab
- [ ] Verify 4 policies exist (SELECT, INSERT, UPDATE, DELETE)
- [ ] Repeat for `internships`, `job_applications`, `internship_applications`

---

## 🔧 Step 2: Code Integration (10 minutes)

### 2.1 Files Already Created

These files have been created for you:

- [x] `lib/services/hr_posts_service.dart` - Supabase API service
- [x] `lib/services/supabase_hr_store.dart` - State management store
- [x] `supabase_hr_features_setup.sql` - Database schema
- [x] `SUPABASE_HR_INTEGRATION.md` - Integration guide

### 2.2 Find Existing Stores

Locate these files in your project:

- [ ] Find `PostStore` class (search for "class PostStore")
- [ ] Find `ApplicationStore` class (search for "class ApplicationStore")
- [ ] Note their file locations

### 2.3 Choose Integration Method

**Option A: Replace Existing Stores** (Recommended)
- [ ] Use `SupabaseHRStore` instead of `PostStore` and `ApplicationStore`
- [ ] Update providers in `main.dart` or `hr_dashboard_page.dart`

**Option B: Update Existing Stores**
- [ ] Modify `PostStore` methods to use `HRPostsService`
- [ ] Modify `ApplicationStore` methods to use `HRPostsService`

---

## 🎯 Step 3: Update HR Dashboard (15 minutes)

### 3.1 Update Providers (Option A)

Find where `PostStore` and `ApplicationStore` are provided:

```dart
// OLD
MultiProvider(
  providers: [
    ChangeNotifierProvider<PostStore>.value(value: PostStore.I),
    ChangeNotifierProvider<ApplicationStore>.value(value: ApplicationStore.I),
  ],
  // ...
)

// NEW
MultiProvider(
  providers: [
    ChangeNotifierProvider<SupabaseHRStore>.value(
      value: SupabaseHRStore.instance,
    ),
  ],
  // ...
)
```

- [ ] Update provider in `hr_dashboard_page.dart`
- [ ] Import `supabase_hr_store.dart`

### 3.2 Initialize Store on Dashboard Load

Add initialization in `HRDashboardPage`:

```dart
@override
void initState() {
  super.initState();
  SupabaseHRStore.instance.initialize();
}
```

- [ ] Add `initState` method
- [ ] Call `initialize()`

### 3.3 Update Job Creation

Find the job creation code in `_PostJobFormInline`:

```dart
// OLD
PostStore.I.addJob(job);

// NEW
await SupabaseHRStore.instance.createJob(
  id: job.id,
  title: job.title,
  location: job.location,
  contractType: job.contractType,
  department: job.department,
  postingDate: job.postingDate,
  applicationDeadline: job.applicationDeadline,
  experience: job.experience,
  skills: job.skills,
  responsibilities: job.responsibilities,
  qualifications: job.qualifications,
  description: job.description,
);
```

- [ ] Update job creation code
- [ ] Make method `async`
- [ ] Add `await` keyword

### 3.4 Update Job Deletion

```dart
// OLD
final ok = PostStore.I.deleteJob(j.id);

// NEW
final ok = await SupabaseHRStore.instance.deleteJob(j.id);
```

- [ ] Update job deletion code
- [ ] Make method `async`
- [ ] Add `await` keyword

### 3.5 Update Job List Display

```dart
// OLD
final items = context.watch<PostStore>().jobs;

// NEW
final items = context.watch<SupabaseHRStore>().jobs;
```

- [ ] Update job list to use new store
- [ ] Convert from `JobPost` objects to `Map<String, dynamic>`

### 3.6 Repeat for Internships

- [ ] Update internship creation
- [ ] Update internship deletion
- [ ] Update internship list display

### 3.7 Update Applications (if needed)

- [ ] Update job applications display
- [ ] Update internship applications display
- [ ] Update status change handlers

---

## 🧪 Step 4: Testing (10 minutes)

### 4.1 Test Job Creation

- [ ] Run the app: `flutter run -d chrome`
- [ ] Login as HR
- [ ] Navigate to "Jobs" section
- [ ] Fill in job form
- [ ] Click "Submit Job"
- [ ] Verify success message
- [ ] Check job appears in list

### 4.2 Verify in Supabase

- [ ] Open Supabase Dashboard
- [ ] Go to Table Editor → `jobs`
- [ ] Verify job was created
- [ ] Check all fields are correct

### 4.3 Test Job Deletion

- [ ] Click "Delete" on a job
- [ ] Verify job is removed from list
- [ ] Check Supabase - job should be deleted

### 4.4 Test Internship Creation

- [ ] Navigate to "Internships" section
- [ ] Fill in internship form
- [ ] Click "Submit Internship"
- [ ] Verify success message
- [ ] Check internship appears in list

### 4.5 Verify in Supabase

- [ ] Go to Table Editor → `internships`
- [ ] Verify internship was created

### 4.6 Test Internship Deletion

- [ ] Click "Delete" on an internship
- [ ] Verify internship is removed
- [ ] Check Supabase - internship should be deleted

### 4.7 Test Employee Creation (Already Working)

- [ ] Navigate to "Employee Details"
- [ ] Click "Create Employee"
- [ ] Fill in form
- [ ] Click "Create Employee"
- [ ] Verify employee appears in list
- [ ] Check Supabase - verify in `auth.users`, `user_roles`, `employee_profiles`

---

## 🐛 Step 5: Troubleshooting

### Common Issues

#### Issue: "Permission denied for table jobs"

- [ ] Verify you're logged in as HR user
- [ ] Check `user_roles` table - your user should have role='hr'
- [ ] Run this query in Supabase SQL Editor:
  ```sql
  SELECT ur.role FROM user_roles ur WHERE ur.id = auth.uid();
  ```

#### Issue: "Jobs not showing up"

- [ ] Check browser console for errors
- [ ] Verify `initialize()` is called
- [ ] Check if data exists in Supabase `jobs` table
- [ ] Verify RLS policies are correct

#### Issue: "Cannot create job"

- [ ] Check Supabase credentials in `supabase_config.dart`
- [ ] Verify HR user has correct role
- [ ] Check browser console for error details
- [ ] Verify RLS policies allow INSERT for HR users

#### Issue: "Build errors"

- [ ] Run `flutter pub get`
- [ ] Check imports are correct
- [ ] Verify all files are saved
- [ ] Restart the app

---

## 📊 Step 6: Verification Queries

Run these in Supabase SQL Editor to verify everything:

### Check Tables
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('jobs', 'internships', 'job_applications', 'internship_applications');
```

- [ ] Should return 4 rows

### Check RLS Policies
```sql
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('jobs', 'internships', 'job_applications', 'internship_applications')
ORDER BY tablename, policyname;
```

- [ ] Should return multiple policies for each table

### View All Jobs
```sql
SELECT * FROM jobs ORDER BY created_at DESC;
```

- [ ] Should show jobs you created

### View All Internships
```sql
SELECT * FROM internships ORDER BY created_at DESC;
```

- [ ] Should show internships you created

### Check HR User
```sql
SELECT u.email, ur.role 
FROM auth.users u
JOIN user_roles ur ON u.id = ur.id
WHERE ur.role = 'hr';
```

- [ ] Should show your HR user

---

## ✅ Final Checklist

- [ ] Database tables created
- [ ] RLS policies verified
- [ ] Service files created
- [ ] Store files created
- [ ] HR Dashboard updated
- [ ] Job creation works
- [ ] Job deletion works
- [ ] Internship creation works
- [ ] Internship deletion works
- [ ] Employee creation works (already implemented)
- [ ] All data persists in Supabase
- [ ] No console errors

---

## 🎉 Success Criteria

You've successfully integrated Supabase when:

✅ HR can create jobs and they appear in Supabase
✅ HR can delete jobs and they're removed from Supabase
✅ HR can create internships and they appear in Supabase
✅ HR can delete internships and they're removed from Supabase
✅ HR can create employees (already working)
✅ Data persists across page refreshes
✅ Data is visible in Supabase Dashboard

---

## 📚 Additional Resources

- [SUPABASE_HR_INTEGRATION.md](SUPABASE_HR_INTEGRATION.md) - Detailed integration guide
- [supabase_hr_features_setup.sql](supabase_hr_features_setup.sql) - Database schema
- [lib/services/hr_posts_service.dart](lib/services/hr_posts_service.dart) - API service
- [lib/services/supabase_hr_store.dart](lib/services/supabase_hr_store.dart) - State management

---

## 🚀 Next Steps (Optional)

After basic integration:

- [ ] Add loading indicators
- [ ] Add error handling UI
- [ ] Implement realtime updates
- [ ] Add search/filter functionality
- [ ] Add pagination for large lists
- [ ] Add job/internship editing
- [ ] Add application management UI

---

**Estimated Time**: 30-40 minutes total

**Last Updated**: November 2025
