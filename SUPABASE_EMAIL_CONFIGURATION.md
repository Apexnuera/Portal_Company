# Supabase Email Domain Configuration Guide

## Issue
Supabase Auth rejects custom email domains like `test@company.com` because:
1. It requires real, verifiable email domains
2. Email confirmation is enabled by default
3. Custom domains need special configuration

## Solutions

### Solution 1: Use Real Email Domain (Easiest for Testing)

**Instead of**: `test@company.com`  
**Use**: `test.employee@gmail.com` (or any real provider)

**Supported Domains:**
- ✅ gmail.com
- ✅ outlook.com
- ✅ yahoo.com
- ✅ hotmail.com
- ✅ Any real email provider

**How to Test:**
1. Go to HR Dashboard → Employee Details
2. Create employee with:
   - Employee ID: `TEST001`
   - Name: `Test Employee`
   - Email: `test.employee@gmail.com` ← Use real domain
   - Password: `Test@123`
3. Employee can log in with these credentials

**Note**: You don't need to verify the email if you disable confirmations (see Solution 2)

---

### Solution 2: Disable Email Confirmation (Recommended for Development)

This allows ANY email format without verification.

#### Steps:

1. **Open Supabase Dashboard**
   - Go to: https://app.supabase.com
   - Select your project

2. **Navigate to Authentication Settings**
   - Left sidebar → Authentication
   - Click "Email Auth" tab

3. **Disable Email Confirmation**
   - Find: "Enable email confirmations"
   - Toggle: **OFF** (disable)
   - Click: "Save"

4. **Optional: Add Custom Domain**
   - Scroll to "Site URL" or "Redirect URLs"
   - Add your local development URL
   - Save changes

#### After Disabling:
- ✅ Can use `test@company.com`
- ✅ Can use any custom domain
- ✅ No email verification needed
- ✅ Employees can log in immediately

**Screenshot Guide:**
```
Supabase Dashboard
  → Authentication
    → Email Auth
      → [ ] Enable email confirmations  ← Turn this OFF
      → [Save]
```

---

### Solution 3: Configure SMTP (For Production)

For production with real corporate emails:

1. **Set up SMTP Server**
   - Go to: Authentication → Email Templates
   - Configure SMTP settings
   - Add your company's email server details

2. **Verify Domain**
   - Add SPF and DKIM records
   - Verify domain ownership

3. **Enable Email Confirmation**
   - Employees will receive verification emails
   - Must click link to activate account

---

### Solution 4: Use Test Email Service

For development testing with email verification:

#### Option A: Mailtrap
1. Sign up at https://mailtrap.io
2. Get SMTP credentials
3. Configure in Supabase
4. All emails go to Mailtrap inbox

#### Option B: Gmail SMTP (For Testing)
1. Create a Gmail account for testing
2. Enable "Less secure app access"
3. Use Gmail SMTP settings in Supabase
4. Receive verification emails

---

## Recommended Setup for Development

### For Your Current Project:

**Step 1**: Disable Email Confirmation (Solution 2)
- Quick and easy
- Works with any email format
- No SMTP setup needed

**Step 2**: Test with Real Domain Initially
- Use `test.employee@gmail.com` for first test
- Verify everything works
- Then switch to custom domains

**Step 3**: Production Configuration Later
- Set up SMTP when deploying
- Enable confirmations
- Use real corporate emails

---

## Current Error Fix

The error you're seeing:
```
Email address "test@company.com" is invalid
```

**Quick Fix** (Choose ONE):

### Option A: Change Email (Immediate)
1. Use: `test.employee@gmail.com`
2. Create employee
3. Works instantly

### Option B: Configure Supabase (5 minutes)
1. Supabase Dashboard → Authentication
2. Disable "Email confirmations"
3. Save
4. Use: `test@company.com`
5. Works with any domain

---

## Code Changes Made

Updated `EmployeeManagementService` to show helpful error:

**Before:**
```
"Email is already in use"
```

**After:**
```
"Invalid email domain. Please use a real email domain 
(e.g., gmail.com, outlook.com) or disable email 
confirmation in Supabase Settings → Authentication."
```

This guides users to the solution!

---

## Testing Checklist

After configuration:

- [ ] HR can create employee with `@gmail.com` email
- [ ] HR can create employee with `@company.com` email (if confirmation disabled)
- [ ] Employee can log in with created credentials
- [ ] Employee profile loads correctly
- [ ] No email verification required (if disabled)

---

## For Production Deployment

### Email Strategy:

1. **Development**: Disable confirmations, use test emails
2. **Staging**: Enable confirmations, use test SMTP
3. **Production**: Enable confirmations, use corporate SMTP

### Security Considerations:

- ✅ Always verify in production
- ✅ Use corporate email domains
- ✅ Enable MFA (Multi-Factor Auth)
- ✅ Set password requirements
- ✅ Monitor auth logs

---

## Summary

**Problem**: Supabase won't accept `@company.com` emails

**Solution** (Choose one):
1. ✅ **Use real domain**: `test@gmail.com` (Fastest)
2. ✅ **Disable confirmations**: Accept any domain (Best for dev)
3. ✅ **Configure SMTP**: Full email support (For production)

**Recommended for Now**: 
- Disable email confirmations in Supabase
- Then you can use any email format

This will unblock you immediately! 🚀
