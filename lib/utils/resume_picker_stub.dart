import 'package:flutter/material.dart';

Future<Map<String, String>?> pickResume(BuildContext context) async {
  // Non-web fallback: not available in this demo
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Resume upload is not available on this platform in this demo')),
  );
  return null;
}
