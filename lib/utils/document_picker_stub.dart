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
  // Non-web fallback: not available in this demo
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Document upload is not available on this platform in this demo'),
      backgroundColor: Colors.orange,
    ),
  );
  return null;
}

void reviewDocument(BuildContext context, DocumentFile document) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Document review is not available on this platform in this demo'),
      backgroundColor: Colors.orange,
    ),
  );
}
