# Company Drive - Auto-Open Files Feature

## Overview
The Company Drive has been enhanced to automatically open uploaded files in their correct format. Files now open with the proper MIME type, ensuring they display correctly in the browser.

## Changes Made

### 1. Enhanced Document Viewer (`lib/utils/document_viewer_web.dart`)

**New Features:**
- ✅ **MIME Type Support**: Files now open with correct MIME type
- ✅ **Automatic Format Detection**: If MIME type is not provided, it's detected from file extension
- ✅ **Comprehensive Format Support**: Supports 30+ file formats

**Supported File Formats:**

#### Documents
- **PDF**: `application/pdf` - Opens in browser PDF viewer
- **Word**: `.doc`, `.docx` - Microsoft Word documents
- **Excel**: `.xls`, `.xlsx` - Microsoft Excel spreadsheets
- **PowerPoint**: `.ppt`, `.pptx` - Microsoft PowerPoint presentations
- **Text**: `.txt`, `.rtf`, `.csv` - Plain text and formatted text

#### Images
- **Common**: `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.webp`
- **Vector**: `.svg` - Scalable Vector Graphics

#### Archives
- **Compressed**: `.zip`, `.rar`, `.7z`

#### Code/Web
- **Web**: `.html`, `.css`, `.js`
- **Data**: `.json`, `.xml`

#### Media
- **Audio**: `.mp3`, `.wav`, `.ogg`
- **Video**: `.mp4`, `.webm`, `.avi`

### 2. Auto-Open After Upload

**Behavior:**
1. User uploads a file
2. File is saved to Supabase Storage
3. Database record is created
4. **File automatically opens in new tab** with correct format
5. Success message is shown

**User Experience:**
- Upload PDF → Opens in browser PDF viewer
- Upload Excel → Browser prompts to download or open in Excel Online
- Upload Image → Opens in browser image viewer
- Upload Video → Opens in browser video player

### 3. Manual File Opening

**Double-click behavior:**
- Folders: Navigate into folder
- Files: Download from Supabase and open with correct MIME type

**Context menu:**
- "Open" option for both files and folders
- Files open with proper format

## Technical Details

### MIME Type Flow

```
Upload File
    ↓
Get MIME type from file picker
    ↓
Store in Supabase (mime_type column)
    ↓
When opening:
    ↓
Use stored MIME type OR detect from extension
    ↓
Create Blob with correct MIME type
    ↓
Open in new browser tab
```

### Code Changes

**1. `document_viewer_web.dart`**
```dart
Future<bool> openDocumentBytes({
  required Uint8List bytes,
  String? fileName,
  String? mimeType,  // NEW: Accept MIME type
}) async {
  // Determine MIME type
  String contentType = mimeType ?? 'application/octet-stream';
  
  if (contentType == 'application/octet-stream' && fileName != null) {
    contentType = _getMimeTypeFromExtension(fileName.split('.').last);
  }
  
  // Create blob with MIME type
  final blob = html.Blob(<Uint8List>[bytes], contentType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  html.window.open(url, '_blank');
  
  return true;
}
```

**2. Upload Handler**
```dart
// After successful upload
final opened = await openDocumentBytes(
  bytes: doc.data,
  fileName: doc.name,
  mimeType: doc.type,  // Pass MIME type
);
```

**3. File Open Handler**
```dart
final opened = await openDocumentBytes(
  bytes: data,
  fileName: item.name,
  mimeType: item.mimeType,  // Use stored MIME type
);
```

## Browser Behavior

### PDF Files
- ✅ Open directly in browser PDF viewer
- ✅ Can view, zoom, print, download
- ✅ No additional software needed

### Office Documents (Word, Excel, PowerPoint)
- ⚠️ Browser may prompt to download
- ⚠️ May open in Office Online if configured
- ⚠️ Native apps may be required for full editing

### Images
- ✅ Open directly in browser
- ✅ Can zoom, save, share

### Videos/Audio
- ✅ Open in browser media player
- ✅ Can play, pause, seek, adjust volume

### Archives (ZIP, RAR)
- ⚠️ Browser will prompt to download
- ⚠️ Cannot view contents in browser

## Testing

### Test Scenarios

1. **Upload PDF**
   - Upload a PDF file
   - Verify it opens in browser PDF viewer
   - Verify you can scroll and zoom

2. **Upload Image**
   - Upload a JPG or PNG
   - Verify it opens in browser
   - Verify it displays correctly

3. **Upload Excel**
   - Upload an XLSX file
   - Verify browser handles it (download or open)

4. **Upload Text File**
   - Upload a TXT file
   - Verify it opens as plain text in browser

5. **Double-Click Existing File**
   - Double-click a file in the list
   - Verify it downloads and opens correctly

### Expected Results

| File Type | Expected Behavior |
|-----------|-------------------|
| PDF | Opens in browser PDF viewer |
| Image (JPG, PNG) | Opens in browser image viewer |
| Text (TXT) | Opens in browser as text |
| Video (MP4) | Opens in browser video player |
| Audio (MP3) | Opens in browser audio player |
| Office (DOCX, XLSX) | Browser prompts to download/open |
| Archive (ZIP) | Browser prompts to download |

## Limitations

### Browser Limitations
- Some file types require native applications
- Office documents may not render perfectly in browser
- Large files may take time to load

### Workarounds
- **Download option**: Users can always download files
- **Context menu**: Right-click for download option
- **Browser extensions**: Users can install viewers for specific formats

## Future Enhancements

Possible improvements:
- [ ] Inline preview for Office documents using Google Docs Viewer
- [ ] PDF.js integration for better PDF viewing
- [ ] Image gallery view for multiple images
- [ ] Video player with custom controls
- [ ] File format conversion (e.g., DOCX to PDF)
- [ ] Preview thumbnails in file list
- [ ] Quick preview on hover

## Troubleshooting

### File doesn't open
- **Check MIME type**: Verify file has correct MIME type in database
- **Check browser**: Some browsers block popups
- **Check file size**: Very large files may timeout

### Wrong format
- **Check extension**: Ensure file extension matches content
- **Check MIME type**: Verify MIME type is correct
- **Re-upload**: Try uploading the file again

### Browser blocks popup
- **Allow popups**: Enable popups for the site
- **Use context menu**: Right-click and select "Open"
- **Download instead**: Use download option

## Summary

The Company Drive now provides a seamless file viewing experience:
- ✅ Files open automatically after upload
- ✅ Correct format detection and display
- ✅ Support for 30+ file formats
- ✅ Browser-native viewing when possible
- ✅ Fallback to download when needed

This enhancement makes the Company Drive more user-friendly and professional, allowing HR users to quickly verify uploaded files and access them in the correct format.
