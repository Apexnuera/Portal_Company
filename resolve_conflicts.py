#!/usr/bin/env python3
"""
Script to automatically resolve git conflict markers by keeping the "theirs" version
(Database connecting branch - the code after ======= and before >>>>>>>)
"""

def resolve_conflicts(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    resolved_lines = []
    in_conflict = False
    in_ours = False  # Between <<<<<<< and =======
    in_theirs = False  # Between ======= and >>>>>>>
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        if line.startswith('<<<<<<<'):
            in_conflict = True
            in_ours = True
            in_theirs = False
            i += 1
            continue
        elif line.startswith('=======') and in_conflict:
            in_ours = False
            in_theirs = True
            i += 1
            continue
        elif line.startswith('>>>>>>>') and in_conflict:
            in_conflict = False
            in_ours = False
            in_theirs = False
            i += 1
            continue
        
        # Keep lines that are not in conflict or in the "theirs" section
        if not in_conflict or in_theirs:
            resolved_lines.append(line)
        
        i += 1
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(resolved_lines)
    
    print(f"✓ Resolved conflicts in {file_path}")
    print(f"  Kept {len(resolved_lines)} lines (Database connecting version)")

if __name__ == '__main__':
    file_path = r'c:\Company Portal\company_portal\lib\pages\hr_dashboard_page.dart'
    resolve_conflicts(file_path)
