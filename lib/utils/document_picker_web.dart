// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class DocumentFile {
  final String name;
  final String type;
  final int size;
  final Uint8List data;
  final DateTime uploadedAt;

  DocumentFile({
    required this.name,
    required this.type,
    required this.size,
    required this.data,
    required this.uploadedAt,
  });

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get extension {
    return name.split('.').last.toLowerCase();
  }

  bool get isPdf => extension == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  bool get isDocument => ['doc', 'docx', 'txt', 'rtf'].contains(extension);
}

Future<DocumentFile?> pickDocument(BuildContext context) async {
  try {
    final upload = html.FileUploadInputElement();
    upload.accept = '.pdf,.doc,.docx,.jpg,.jpeg,.png,.gif,.bmp,.webp,.txt,.rtf';
    upload.click();
    
    await upload.onChange.first;
    final files = upload.files;
    
    if (files != null && files.isNotEmpty) {
      final file = files.first;
      
      // Validate file size (max 10MB)
      if (file.size > 10 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size should be less than 10MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      // Read file data
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      
      final data = reader.result as List<int>;
      
      return DocumentFile(
        name: file.name,
        type: file.type,
        size: file.size,
        data: Uint8List.fromList(data),
        uploadedAt: DateTime.now(),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  return null;
}

void reviewDocument(BuildContext context, DocumentFile document) {
  if (document.isPdf || document.isDocument) {
    _openDocumentInNewTab(document);
  } else if (document.isImage) {
    _showImagePreview(context, document);
  } else {
    _showDocumentInfo(context, document);
  }
}

void _openDocumentInNewTab(DocumentFile document) {
  final blob = html.Blob([document.data], document.type);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  html.Url.revokeObjectUrl(url);
}

void _showImagePreview(BuildContext context, DocumentFile document) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Color(0xFFFF782B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Image
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Image.memory(
                  document.data,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Size: ${document.sizeFormatted}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _openDocumentInNewTab(document),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF782B),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Open in New Tab'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showDocumentInfo(BuildContext context, DocumentFile document) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.description, color: Color(0xFFFF782B)),
          const SizedBox(width: 8),
          const Text('Document Information'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Name:', document.name),
          _buildInfoRow('Type:', document.type.isEmpty ? 'Unknown' : document.type),
          _buildInfoRow('Size:', document.sizeFormatted),
          _buildInfoRow('Uploaded:', _formatDateTime(document.uploadedAt)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _openDocumentInNewTab(document);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF782B),
            foregroundColor: Colors.white,
          ),
          child: const Text('Open Document'),
        ),
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
