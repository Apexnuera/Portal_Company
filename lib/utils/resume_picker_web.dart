// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';

Future<Map<String, String>?> pickResume(BuildContext context) async {
  final upload = html.FileUploadInputElement();
  upload.accept = '.pdf,.doc,.docx';
  upload.click();
  await upload.onChange.first;
  final files = upload.files;
  if (files != null && files.isNotEmpty) {
    final file = files.first;
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;
    final result = reader.result as String;
    // result is like "data:application/pdf;base64,JVBERi0xLjQK..."
    // We might want to strip the prefix or keep it. 
    // For simplicity, let's keep it or just store the base64 part.
    // The current store expects "resumeData".
    return {
      'name': file.name,
      'data': result,
    };
  }
  return null;
}

