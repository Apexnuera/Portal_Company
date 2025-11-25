-- Quick Diagnostic Check for Employee Creation Issue
-- Run this in Supabase SQL Editor to diagnose the problem

-- 1. Check if employees table exists
SELECT 
  'employees table exists' as check_name,
  EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'employees'
  ) as result;

-- 2. Check RLS is enabled on employees
SELECT 
  'RLS enabled on employees' as check_name,
  relrowsecurity as result
FROM pg_class
WHERE relname = 'employees';

-- 3. List all policies on employees table
SELECT 
  'Policy: ' || policyname as check_name,
  cmd as operation,
  qual as using_clause,
  with_check as with_check_clause
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'employees'
ORDER BY policyname;

-- 4. Check if current user has HR role
SELECT 
  'Current user has HR role' as check_name,
  EXISTS (
    SELECT 1 FROM user_roles 
    WHERE id = auth.uid() 
    AND role = 'hr'
  ) as result;

-- 5. Check current user ID
SELECT 
  'Current user ID' as check_name,
  auth.uid() as result;

-- 6. Check user_roles table for current user
SELECT 
  'User role from user_roles' as check_name,
  role as result
FROM user_roles
WHERE id = auth.uid();

-- 7. Try to select from employees (this tests SELECT policy)
SELECT 
  'Can SELECT from employees' as check_name,
  COUNT(*) as result
FROM employees;

-- 8. Check all users in auth.users
SELECT 
  'Total users in auth.users' as check_name,
  COUNT(*) as result
FROM auth.users;

-- 9. Check all rows in employees
SELECT 
  'Total rows in employees' as check_name,
  COUNT(*) as result  
FROM employees;

-- 10. Check all rows in user_roles
SELECT 
  'Total rows in user_roles' as check_name,
  COUNT(*) as result
FROM user_roles;
