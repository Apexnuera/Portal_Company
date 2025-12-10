-- Enable UUID extension if not enabled
create extension if not exists "uuid-ossp";

-- 1. Attendance Table
create table public.timetracking_attendance (
  id uuid default uuid_generate_v4() primary key,
  employee_id uuid references auth.users(id) not null,
  date date not null,
  clock_in_time timestamptz,
  clock_out_time timestamptz,
  status text check (status in ('Present', 'Absent', 'Half Day', 'WFH')),
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. Leave Requests Table
create table public.timetracking_leave_requests (
  id uuid default uuid_generate_v4() primary key,
  employee_id uuid references auth.users(id) not null,
  start_date date not null,
  end_date date not null,
  leave_type text not null,
  reason text not null,
  status text check (status in ('Pending', 'Approved', 'Rejected')) default 'Pending',
  submitted_date timestamptz default now(),
  approved_date timestamptz,
  approver_comments text,
  document_url text, -- Store Supabase Storage URL
  document_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 3. WFH Requests Table
create table public.timetracking_wfh_requests (
  id uuid default uuid_generate_v4() primary key,
  employee_id uuid references auth.users(id) not null,
  start_date date not null,
  end_date date not null,
  reason text not null,
  status text check (status in ('Pending', 'Approved', 'Rejected')) default 'Pending',
  submitted_date timestamptz default now(),
  approved_date timestamptz,
  approver_comments text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 4. Holidays Table
create table public.timetracking_holidays (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  date date not null,
  type text check (type in ('National', 'Regional', 'Company')),
  description text,
  is_optional boolean default false,
  created_at timestamptz default now()
);

-- Row Level Security (RLS) Policies

-- Enable RLS
alter table public.timetracking_attendance enable row level security;
alter table public.timetracking_leave_requests enable row level security;
alter table public.timetracking_wfh_requests enable row level security;
alter table public.timetracking_holidays enable row level security;

-- Policies for Attendance
-- Employees can view their own attendance
create policy "Employees can view own attendance" on public.timetracking_attendance
  for select using (auth.uid() = employee_id);

-- Employees can insert/update their own attendance (clock in/out)
create policy "Employees can insert own attendance" on public.timetracking_attendance
  for insert with check (auth.uid() = employee_id);

create policy "Employees can update own attendance" on public.timetracking_attendance
  for update using (auth.uid() = employee_id);

-- HR can view all attendance
create policy "HR can view all attendance" on public.timetracking_attendance
  for select using (
    exists (select 1 from public.user_roles where id = auth.uid() and role = 'hr')
  );

-- Policies for Leave Requests
-- Employees can view own requests
create policy "Employees can view own leave requests" on public.timetracking_leave_requests
  for select using (auth.uid() = employee_id);

-- Employees can create requests
create policy "Employees can create leave requests" on public.timetracking_leave_requests
  for insert with check (auth.uid() = employee_id);

-- HR can view all requests
create policy "HR can view all leave requests" on public.timetracking_leave_requests
  for select using (
    exists (select 1 from public.user_roles where id = auth.uid() and role = 'hr')
  );

-- HR can update requests (approve/reject)
create policy "HR can update leave requests" on public.timetracking_leave_requests
  for update using (
    exists (select 1 from public.user_roles where id = auth.uid() and role = 'hr')
  );

-- Policies for WFH Requests
-- Employees can view own requests
create policy "Employees can view own wfh requests" on public.timetracking_wfh_requests
  for select using (auth.uid() = employee_id);

-- Employees can create requests
create policy "Employees can create wfh requests" on public.timetracking_wfh_requests
  for insert with check (auth.uid() = employee_id);

-- HR can view all requests
create policy "HR can view all wfh requests" on public.timetracking_wfh_requests
  for select using (
    exists (select 1 from public.user_roles where id = auth.uid() and role = 'hr')
  );

-- HR can update requests
create policy "HR can update wfh requests" on public.timetracking_wfh_requests
  for update using (
    exists (select 1 from public.user_roles where id = auth.uid() and role = 'hr')
  );

-- Policies for Holidays
-- Everyone can view holidays
create policy "Everyone can view holidays" on public.timetracking_holidays
  for select using (true);

-- Only HR can manage holidays
create policy "HR can manage holidays" on public.timetracking_holidays
  for all using (
    exists (select 1 from public.user_roles where id = auth.uid() and role = 'hr')
  );
