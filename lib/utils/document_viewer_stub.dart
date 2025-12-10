import 'dart:typed_data';

Future<bool> openDocumentBytes({
  required Uint8List bytes,
  String? fileName,
  String? mimeType,
}) async {
  // Not supported on non-web platforms in this demo.
  return false;
}

Future<bool> openDocumentUrl(String url) async {
  // Not supported on non-web platforms in this demo.
  return false;
}
