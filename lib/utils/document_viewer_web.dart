// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<bool> openDocumentBytes({required Uint8List bytes, String? fileName}) async {
  final blob = html.Blob(<Uint8List>[bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  html.Url.revokeObjectUrl(url);
  return true;
}
