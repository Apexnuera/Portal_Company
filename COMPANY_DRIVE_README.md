# Company Drive - Supabase Integration

## Overview
The Company Drive module has been successfully migrated from in-memory storage to Supabase, providing persistent, cloud-based file storage with the following features:

### Features Maintained
✅ **Hierarchical Folder Structure** - Create nested folders  
✅ **File Upload** - Upload files with binary data  
✅ **File Download** - Download files to local device  
✅ **File Preview** - Open files in browser/viewer  
✅ **Create/Rename/Delete** - Full CRUD operations for files and folders  
✅ **Search Functionality** - Search files and folders by name  
✅ **Breadcrumb Navigation** - Navigate through folder hierarchy  
✅ **Owner Tracking** - Track who created each file/folder  
✅ **File Size Display** - Show file sizes in human-readable format  
✅ **File Type Icons** - Different icons for different file types  

### New Features
🆕 **Persistent Storage** - Files are stored in Supabase and persist across sessions  
🆕 **Realtime Updates** - Changes are reflected in real-time across all clients  
🆕 **Cloud Storage** - Files are stored in Supabase Storage bucket  
🆕 **Automatic Timestamps** - Created and updated timestamps are tracked  
🆕 **Cascade Delete** - Deleting a folder automatically deletes all children  

## Architecture

### Database Schema
**Table: `drive_items`**
- `id` (UUID) - Primary key
- `name` (TEXT) - File/folder name
- `is_folder` (BOOLEAN) - Whether item is a folder
- `parent_id` (UUID) - Reference to parent folder (NULL for root)
- `created_at` (TIMESTAMPTZ) - Creation timestamp
- `updated_at` (TIMESTAMPTZ) - Last update timestamp
- `created_by` (UUID) - User who created the item
- `file_size` (BIGINT) - File size in bytes (NULL for folders)
- `mime_type` (TEXT) - MIME type (NULL for folders)
- `storage_path` (TEXT) - Path in Supabase Storage (NULL for folders)

### Storage Bucket
**Bucket: `company-drive`**
- Private bucket (not publicly accessible)
- Files are stored with unique paths: `files/{timestamp}-{filename}`
- Only HR users can access

### Security (RLS Policies)
- ✅ Only HR users can view, create, update, and delete items
- ✅ Storage bucket is private with HR-only access
- ✅ Cascade delete ensures no orphaned files

## Setup Instructions

### 1. Run SQL Setup
Execute the SQL file in your Supabase SQL Editor:

```bash
# File: company_drive_setup.sql
```

This will:
- Create the `drive_items` table
- Set up indexes for performance
- Enable Row Level Security (RLS)
- Create RLS policies for HR access
- Create the `company-drive` storage bucket
- Set up storage policies
- Enable realtime replication

### 2. Verify Setup
After running the SQL:

1. **Check Table**: Go to Table Editor → verify `drive_items` table exists
2. **Check Storage**: Go to Storage → verify `company-drive` bucket exists
3. **Check Policies**: Go to Authentication → Policies → verify RLS policies are active

### 3. Test the Feature
1. Log in as an HR user
2. Navigate to Company Drive section
3. Try creating a folder
4. Try uploading a file
5. Verify files persist after page refresh

## File Operations

### Upload Flow
1. User selects file via file picker
2. File is uploaded to Supabase Storage (`company-drive` bucket)
3. Database record is created in `drive_items` table
4. File data is cached locally for quick access
5. Realtime stream updates all connected clients

### Download Flow
1. Check if file data is cached locally
2. If not cached, download from Supabase Storage
3. Cache the data for future use
4. Save to user's device

### Delete Flow
1. If file: Delete from Storage first, then database
2. If folder: Database CASCADE delete handles children automatically
3. Realtime stream updates all clients

## Code Structure

### Service Layer
**File**: `lib/services/company_drive_service.dart`

Key methods:
- `fetchAll()` - Load all items from database
- `getChildren(parentId)` - Get items in a folder
- `createFolder(name, parentId)` - Create new folder
- `uploadFile(name, data, mimeType, parentId)` - Upload file
- `downloadFile(item)` - Download file data
- `rename(id, newName)` - Rename item
- `delete(id)` - Delete item
- `search(query)` - Search by name

### UI Layer
**File**: `lib/pages/hr_dashboard_page.dart`

The `_CompanyDriveModule` widget provides:
- File/folder list view
- Breadcrumb navigation
- Search functionality
- Upload/create buttons
- Context menus for operations

## Performance Optimizations

1. **Local Caching**: Downloaded files are cached in memory
2. **Indexed Queries**: Database indexes on parent_id, name, created_by
3. **Realtime Streaming**: Efficient updates without polling
4. **Lazy Loading**: Files are only downloaded when needed

## Troubleshooting

### Files not appearing
- Check browser console for errors
- Verify RLS policies are set correctly
- Ensure user is logged in as HR
- Check Supabase logs in dashboard

### Upload fails
- Check file size limits (Supabase free tier: 50MB per file)
- Verify storage bucket exists
- Check storage policies
- Look for CORS errors in browser console

### Realtime not working
- Verify `ALTER PUBLICATION supabase_realtime ADD TABLE drive_items;` was run
- Check if realtime is enabled in Supabase dashboard
- Restart the Flutter app

## Migration Notes

### What Changed
- **Before**: Files stored in memory (lost on page refresh)
- **After**: Files stored in Supabase (persistent)

### Breaking Changes
- None! The UI and functionality remain exactly the same

### Data Migration
- No existing data to migrate (was in-memory only)
- Fresh start with Supabase backend

## Future Enhancements

Possible improvements:
- [ ] File sharing with employees
- [ ] Version history
- [ ] File comments/annotations
- [ ] Bulk operations
- [ ] Drag-and-drop upload
- [ ] Folder permissions
- [ ] File preview thumbnails
- [ ] Download progress indicator

## Support

If you encounter issues:
1. Check the browser console for errors
2. Check Supabase logs
3. Verify SQL setup was completed
4. Ensure HR user is properly authenticated
