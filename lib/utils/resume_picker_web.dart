// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';

Future<String?> pickResume(BuildContext context) async {
  final upload = html.FileUploadInputElement();
  upload.accept = '.pdf,.doc,.docx';
  upload.click();
  await upload.onChange.first;
  final files = upload.files;
  if (files != null && files.isNotEmpty) {
    return files.first.name;
  }
  return null;
}
