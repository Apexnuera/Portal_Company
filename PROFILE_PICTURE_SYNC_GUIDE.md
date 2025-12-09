# Profile Picture Sync - Quick Guide

## What Was Fixed

Profile picture uploads now save to Supabase and appear in HR dashboard automatically.

## How to Test

### Test 1: Employee Uploads Profile Picture
1. Login as employee
2. Go to Personal Details → Edit
3. Click "Upload Profile Picture"
4. Select an image
5. Wait for upload (shows progress)
6. See success message ✅
7. Logout

### Test 2: HR Views Updated Picture
1. Login as HR
2. Go to Employee Details
3. View the employee who uploaded picture
4. Open their profile
5. **Expected**: Should see the new profile picture! ✅

## Technical Flow

```
Employee uploads image
      ↓
EmployeeProfileService.uploadProfileImage(bytes, fileName)
      ↓
Upload to Supabase Storage bucket: 'employee-profiles'
      ↓
Get public URL from Storage
      ↓
UPDATE employee_profiles SET profile_image_url = <url>
      ↓
HR loads employee profile
      ↓
Fetches profile_image_url from database
      ↓
Displays image in HR dashboard ✅
```

## Storage Bucket

Profile pictures are stored in: **Supabase Storage → employee-profiles bucket**

Path format: `<user_id>/profile_<timestamp>.png`

This is already configured in the SQL schema you ran earlier!
