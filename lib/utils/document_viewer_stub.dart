import 'dart:typed_data';

Future<bool> openDocumentBytes({required Uint8List bytes, String? fileName}) async {
  // Not supported on non-web platforms in this demo.
  return false;
}
