# 🚀 Supabase HR Features Integration Guide

This guide will help you integrate Supabase for Jobs, Internships, and Employee management in your HR Dashboard.

---

## 📋 Table of Contents

1. [Database Setup](#database-setup)
2. [Service Integration](#service-integration)
3. [Update HR Dashboard](#update-hr-dashboard)
4. [Testing](#testing)
5. [Troubleshooting](#troubleshooting)

---

## 1. Database Setup

### Step 1: Run the SQL Script

1. **Open Supabase Dashboard**
   - Go to https://app.supabase.com
   - Select your project

2. **Open SQL Editor**
   - Click on "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Run the Setup Script**
   - Open `supabase_hr_features_setup.sql`
   - Copy the entire content
   - Paste into the SQL Editor
   - Click "Run" or press `Ctrl+Enter`

4. **Verify Tables Created**
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name IN ('jobs', 'internships', 'job_applications', 'internship_applications');
   ```

   You should see 4 tables:
   - `jobs`
   - `internships`
   - `job_applications`
   - `internship_applications`

### Step 2: Verify RLS Policies

1. **Go to Table Editor**
   - Click on "Table Editor" in the left sidebar
   - Select each table (jobs, internships, etc.)

2. **Check RLS is Enabled**
   - You should see "RLS enabled" badge on each table

3. **View Policies**
   - Click on a table
   - Click on "Policies" tab
   - Verify policies exist for SELECT, INSERT, UPDATE, DELETE

---

## 2. Service Integration

The `HRPostsService` has been created at `lib/services/hr_posts_service.dart`.

### Key Features:

#### Jobs Management
- ✅ `createJob()` - Create new job posting
- ✅ `getAllJobs()` - Fetch all jobs
- ✅ `getJob(id)` - Get single job
- ✅ `updateJob(id, updates)` - Update job
- ✅ `deleteJob(id)` - Delete job

#### Internships Management
- ✅ `createInternship()` - Create new internship
- ✅ `getAllInternships()` - Fetch all internships
- ✅ `getInternship(id)` - Get single internship
- ✅ `updateInternship(id, updates)` - Update internship
- ✅ `deleteInternship(id)` - Delete internship

#### Applications Management
- ✅ Job applications CRUD
- ✅ Internship applications CRUD
- ✅ Status updates (In Progress, Selected, Rejected)

#### Realtime Features (Optional)
- ✅ `subscribeToJobs()` - Live updates for jobs
- ✅ `subscribeToInternships()` - Live updates for internships
- ✅ `subscribeToJobApplications()` - Live updates for applications

---

## 3. Update HR Dashboard

### Current State

Your HR Dashboard currently uses in-memory storage:
- `PostStore` - Stores jobs and internships locally
- `ApplicationStore` - Stores applications locally

### Migration Strategy

You have **two options**:

#### Option A: Update Existing Stores (Recommended)
Modify `PostStore` and `ApplicationStore` to use Supabase instead of in-memory storage.

#### Option B: Create New Supabase-Based Stores
Create new stores that use `HRPostsService` and gradually migrate.

---

### Option A: Update Existing Stores (Step-by-Step)

#### 1. Update `PostStore` for Jobs

Find the `PostStore` class and update the `addJob` method:

```dart
// OLD (in-memory)
void addJob(JobPost job) {
  _jobs.add(job);
  notifyListeners();
}

// NEW (Supabase)
Future<void> addJob(JobPost job) async {
  final result = await HRPostsService.instance.createJob(
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

  if (result != null) {
    _jobs.add(job);
    notifyListeners();
  }
}
```

#### 2. Update `PostStore` to Load Jobs from Supabase

Add an initialization method:

```dart
Future<void> loadJobs() async {
  final jobsData = await HRPostsService.instance.getAllJobs();
  
  _jobs = jobsData.map((data) => JobPost(
    id: data['id'],
    title: data['title'],
    location: data['location'],
    contractType: data['contract_type'],
    department: data['department'],
    postingDate: data['posting_date'],
    applicationDeadline: data['application_deadline'],
    experience: data['experience'],
    skills: List<String>.from(data['skills'] ?? []),
    responsibilities: List<String>.from(data['responsibilities'] ?? []),
    qualifications: List<String>.from(data['qualifications'] ?? []),
    description: data['description'],
  )).toList();
  
  notifyListeners();
}
```

#### 3. Update Delete Job Method

```dart
// OLD
bool deleteJob(String id) {
  final before = _jobs.length;
  _jobs.removeWhere((j) => j.id == id);
  notifyListeners();
  return _jobs.length < before;
}

// NEW
Future<bool> deleteJob(String id) async {
  final success = await HRPostsService.instance.deleteJob(id);
  
  if (success) {
    _jobs.removeWhere((j) => j.id == id);
    notifyListeners();
  }
  
  return success;
}
```

#### 4. Repeat for Internships

Apply the same pattern for:
- `addInternship()`
- `loadInternships()`
- `deleteInternship()`

#### 5. Update Application Store

Similarly update `ApplicationStore` for job and internship applications.

---

### Option B: Create New Supabase Stores

Create a new file `lib/services/supabase_posts_store.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'hr_posts_service.dart';

class SupabasePostsStore extends ChangeNotifier {
  static final SupabasePostsStore instance = SupabasePostsStore._();
  SupabasePostsStore._();

  final _service = HRPostsService.instance;
  
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _internships = [];
  
  List<Map<String, dynamic>> get jobs => _jobs;
  List<Map<String, dynamic>> get internships => _internships;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Initialize and load data
  Future<void> initialize() async {
    await Future.wait([
      loadJobs(),
      loadInternships(),
    ]);
  }

  // Jobs
  Future<void> loadJobs() async {
    _isLoading = true;
    notifyListeners();
    
    _jobs = await _service.getAllJobs();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createJob({
    required String id,
    required String title,
    required String location,
    required String contractType,
    required String department,
    required String postingDate,
    required String applicationDeadline,
    required String experience,
    required List<String> skills,
    required List<String> responsibilities,
    required List<String> qualifications,
    required String description,
  }) async {
    final result = await _service.createJob(
      id: id,
      title: title,
      location: location,
      contractType: contractType,
      department: department,
      postingDate: postingDate,
      applicationDeadline: applicationDeadline,
      experience: experience,
      skills: skills,
      responsibilities: responsibilities,
      qualifications: qualifications,
      description: description,
    );

    if (result != null) {
      await loadJobs();
      return true;
    }
    return false;
  }

  Future<bool> deleteJob(String id) async {
    final success = await _service.deleteJob(id);
    if (success) {
      await loadJobs();
    }
    return success;
  }

  // Internships
  Future<void> loadInternships() async {
    _isLoading = true;
    notifyListeners();
    
    _internships = await _service.getAllInternships();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createInternship({
    required String id,
    required String title,
    required String duration,
    required String skill,
    required String qualification,
    required String description,
    required String postingDate,
  }) async {
    final result = await _service.createInternship(
      id: id,
      title: title,
      duration: duration,
      skill: skill,
      qualification: qualification,
      description: description,
      postingDate: postingDate,
    );

    if (result != null) {
      await loadInternships();
      return true;
    }
    return false;
  }

  Future<bool> deleteInternship(String id) async {
    final success = await _service.deleteInternship(id);
    if (success) {
      await loadInternships();
    }
    return success;
  }
}
```

---

## 4. Testing

### Test Jobs Creation

1. **Login as HR**
   - Go to `/login/hr`
   - Use your HR credentials

2. **Create a Job**
   - Navigate to "Jobs" section
   - Fill in the job form
   - Click "Submit Job"

3. **Verify in Supabase**
   - Go to Supabase Dashboard
   - Click "Table Editor"
   - Select "jobs" table
   - You should see your new job

### Test Internships Creation

1. **Navigate to Internships**
   - Click "Internships" in sidebar

2. **Create an Internship**
   - Fill in the form
   - Click "Submit Internship"

3. **Verify in Supabase**
   - Check "internships" table in Supabase

### Test Employee Creation

Employee creation already uses Supabase through `AuthService`:
- Creates user in `auth.users`
- Adds role to `user_roles`
- Creates profile in `employee_profiles`

---

## 5. Troubleshooting

### Issue: "Permission denied for table jobs"

**Solution**: Make sure you're logged in as HR user. Check RLS policies:

```sql
-- Verify you're logged in as HR
SELECT ur.role 
FROM user_roles ur 
WHERE ur.id = auth.uid();
```

### Issue: "Jobs not showing up"

**Solution**: 
1. Check if data exists in Supabase
2. Verify `loadJobs()` is called on initialization
3. Check browser console for errors

### Issue: "Cannot create job"

**Solution**:
1. Verify Supabase credentials in `supabase_config.dart`
2. Check if HR user has correct role in `user_roles` table
3. Verify RLS policies allow HR to insert

### Issue: "Realtime not working"

**Solution**:
1. Enable Realtime in Supabase Dashboard
2. Go to Database → Replication
3. Enable replication for tables

---

## 6. Quick Reference

### SQL Queries

```sql
-- View all jobs
SELECT * FROM jobs ORDER BY created_at DESC;

-- View all internships
SELECT * FROM internships ORDER BY created_at DESC;

-- View all job applications
SELECT * FROM job_applications ORDER BY created_at DESC;

-- View all internship applications
SELECT * FROM internship_applications ORDER BY created_at DESC;

-- Count jobs by department
SELECT department, COUNT(*) as count 
FROM jobs 
GROUP BY department;

-- View applications with job details
SELECT 
  ja.*,
  j.title as job_title,
  j.department
FROM job_applications ja
JOIN jobs j ON ja.job_id = j.id
ORDER BY ja.created_at DESC;
```

### Dart Usage Examples

```dart
// Create a job
final success = await SupabasePostsStore.instance.createJob(
  id: 'JOB-123',
  title: 'Flutter Developer',
  location: 'Remote',
  contractType: 'Full-time',
  department: 'Engineering',
  postingDate: '2025-11-27',
  applicationDeadline: '2025-12-27',
  experience: '2-4 years',
  skills: ['Flutter', 'Dart', 'Firebase'],
  responsibilities: ['Develop mobile apps', 'Code reviews'],
  qualifications: ['BSc Computer Science', '2+ years Flutter'],
  description: 'We are looking for...',
);

// Delete a job
final deleted = await SupabasePostsStore.instance.deleteJob('JOB-123');

// Load all jobs
await SupabasePostsStore.instance.loadJobs();
```

---

## 🎉 Next Steps

1. ✅ Run `supabase_hr_features_setup.sql` in Supabase
2. ✅ Choose migration strategy (Option A or B)
3. ✅ Update HR Dashboard code
4. ✅ Test job creation
5. ✅ Test internship creation
6. ✅ Verify data in Supabase

---

## 📞 Support

If you encounter any issues:
1. Check the Troubleshooting section
2. Verify Supabase credentials
3. Check browser console for errors
4. Review Supabase logs in Dashboard

---

**Last Updated**: November 2025
