// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<bool> openDocumentBytes({
  required Uint8List bytes,
  String? fileName,
  String? mimeType,
}) async {
  // Determine MIME type from file extension if not provided
  String contentType = mimeType ?? 'application/octet-stream';
  
  if (contentType == 'application/octet-stream' && fileName != null) {
    final ext = fileName.split('.').last.toLowerCase();
    contentType = _getMimeTypeFromExtension(ext);
  }
  
  // Create blob with correct MIME type
  final blob = html.Blob(<Uint8List>[bytes], contentType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Open in new tab
  html.window.open(url, '_blank');
  
  // Clean up the URL after a delay to ensure it's loaded
  Future.delayed(const Duration(seconds: 1), () {
    html.Url.revokeObjectUrl(url);
  });
  
  return true;
}

Future<bool> openDocumentUrl(String url) async {
  html.window.open(url, '_blank');
  return true;
}

String _getMimeTypeFromExtension(String ext) {
  switch (ext) {
    // Documents
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'txt':
      return 'text/plain';
    case 'rtf':
      return 'application/rtf';
    case 'csv':
      return 'text/csv';
    
    // Images
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'webp':
      return 'image/webp';
    case 'svg':
      return 'image/svg+xml';
    
    // Archives
    case 'zip':
      return 'application/zip';
    case 'rar':
      return 'application/x-rar-compressed';
    case '7z':
      return 'application/x-7z-compressed';
    
    // Code/Text
    case 'html':
      return 'text/html';
    case 'css':
      return 'text/css';
    case 'js':
      return 'application/javascript';
    case 'json':
      return 'application/json';
    case 'xml':
      return 'application/xml';
    
    // Audio
    case 'mp3':
      return 'audio/mpeg';
    case 'wav':
      return 'audio/wav';
    case 'ogg':
      return 'audio/ogg';
    
    // Video
    case 'mp4':
      return 'video/mp4';
    case 'webm':
      return 'video/webm';
    case 'avi':
      return 'video/x-msvideo';
    
    default:
      return 'application/octet-stream';
  }
}
