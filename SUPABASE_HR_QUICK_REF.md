# 🚀 Supabase HR Features - Quick Reference Card

## 📋 3-Step Setup

### 1️⃣ Database (5 min)
```bash
1. Open Supabase → SQL Editor
2. Run: supabase_hr_features_setup.sql
3. Verify: 4 tables created
```

### 2️⃣ Code (10 min)
```dart
// Import
import 'package:your_app/services/supabase_hr_store.dart';

// Add Provider
ChangeNotifierProvider<SupabaseHRStore>.value(
  value: SupabaseHRStore.instance,
)

// Initialize
@override
void initState() {
  super.initState();
  SupabaseHRStore.instance.initialize();
}
```

### 3️⃣ Update (10 min)
```dart
// OLD
PostStore.I.addJob(job);

// NEW
await SupabaseHRStore.instance.createJob(...);
```

---

## 📊 Database Tables

| Table | Purpose | Who Can Access |
|-------|---------|----------------|
| `jobs` | Job postings | HR: CRUD, Public: Read |
| `internships` | Internship postings | HR: CRUD, Public: Read |
| `job_applications` | Job applications | HR: CRUD, Public: Create |
| `internship_applications` | Internship applications | HR: CRUD, Public: Create |

---

## 🔧 API Quick Reference

### Jobs
```dart
// Create
await SupabaseHRStore.instance.createJob(
  id: 'JOB-123',
  title: 'Flutter Developer',
  location: 'Remote',
  contractType: 'Full-time',
  department: 'Engineering',
  postingDate: '2025-11-27',
  applicationDeadline: '2025-12-27',
  experience: '2-4 years',
  skills: ['Flutter', 'Dart'],
  responsibilities: ['Develop apps'],
  qualifications: ['BSc CS'],
  description: 'Description...',
);

// List
final jobs = SupabaseHRStore.instance.jobs;

// Delete
await SupabaseHRStore.instance.deleteJob('JOB-123');
```

### Internships
```dart
// Create
await SupabaseHRStore.instance.createInternship(
  id: 'INT-123',
  title: 'Flutter Intern',
  duration: '3 months',
  skill: 'Flutter',
  qualification: 'BSc CS',
  description: 'Description...',
  postingDate: '2025-11-27',
);

// List
final internships = SupabaseHRStore.instance.internships;

// Delete
await SupabaseHRStore.instance.deleteInternship('INT-123');
```

### Applications
```dart
// List job applications
final jobApps = SupabaseHRStore.instance.jobApplications;

// Update status
await SupabaseHRStore.instance.updateJobApplicationStatus(
  'JOB-123',
  'applicant@email.com',
  'Selected', // or 'In Progress', 'Rejected'
);

// Delete
await SupabaseHRStore.instance.deleteJobApplication(
  'JOB-123',
  'applicant@email.com',
);
```

---

## 🗄️ SQL Quick Commands

### View Data
```sql
-- All jobs
SELECT * FROM jobs ORDER BY created_at DESC;

-- All internships
SELECT * FROM internships ORDER BY created_at DESC;

-- All job applications
SELECT * FROM job_applications ORDER BY created_at DESC;

-- Jobs with application count
SELECT 
  j.id,
  j.title,
  COUNT(ja.id) as application_count
FROM jobs j
LEFT JOIN job_applications ja ON j.id = ja.job_id
GROUP BY j.id, j.title
ORDER BY j.created_at DESC;
```

### Verify Setup
```sql
-- Check tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('jobs', 'internships', 'job_applications', 'internship_applications');

-- Check RLS policies
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('jobs', 'internships')
ORDER BY tablename;

-- Check current user role
SELECT ur.role 
FROM user_roles ur 
WHERE ur.id = auth.uid();
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Permission denied** | Verify HR role: `SELECT * FROM user_roles WHERE id = auth.uid()` |
| **Jobs not showing** | Call `SupabaseHRStore.instance.initialize()` |
| **Cannot create** | Check Supabase credentials in `supabase_config.dart` |
| **Build errors** | Run `flutter pub get` and restart |

---

## ✅ Verification Checklist

- [ ] SQL script run successfully
- [ ] 4 tables created in Supabase
- [ ] RLS enabled on all tables
- [ ] `SupabaseHRStore` imported
- [ ] Provider added
- [ ] `initialize()` called
- [ ] Job creation updated
- [ ] Job deletion updated
- [ ] Internship creation updated
- [ ] Internship deletion updated
- [ ] Test: Create job → appears in Supabase
- [ ] Test: Delete job → removed from Supabase
- [ ] Test: Create internship → appears in Supabase
- [ ] Test: Delete internship → removed from Supabase

---

## 📁 Files Created

| File | Purpose |
|------|---------|
| `supabase_hr_features_setup.sql` | Database schema |
| `lib/services/hr_posts_service.dart` | Supabase API service |
| `lib/services/supabase_hr_store.dart` | State management |
| `SUPABASE_HR_CHECKLIST.md` | Step-by-step guide |
| `SUPABASE_HR_INTEGRATION.md` | Detailed docs |
| `SUPABASE_HR_SUMMARY.md` | Overview |

---

## 🎯 What's Already Working

✅ **Employee Creation** - Already uses Supabase
- Creates in `auth.users`
- Assigns role in `user_roles`
- Creates profile in `employee_profiles`

⏳ **Jobs** - Needs integration
⏳ **Internships** - Needs integration
⏳ **Applications** - Needs integration

---

## 📞 Quick Help

**Start Here**: `SUPABASE_HR_CHECKLIST.md`

**Need Details**: `SUPABASE_HR_INTEGRATION.md`

**Quick Reference**: This file

**Architecture**: See `supabase_hr_architecture.png`

---

## 🎉 Success Criteria

When done, you should be able to:

✅ Create jobs in HR Dashboard → See in Supabase
✅ Delete jobs in HR Dashboard → Removed from Supabase
✅ Create internships in HR Dashboard → See in Supabase
✅ Delete internships in HR Dashboard → Removed from Supabase
✅ Create employees (already working)
✅ All data persists across refreshes

---

**Estimated Time**: 30-40 minutes

**Print this card for quick reference!**

**Last Updated**: November 2025
