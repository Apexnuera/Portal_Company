import 'dart:html' as html;
import 'dart:typed_data';

/// Utility function to get the HTML document for web file picker
Future<html.HtmlDocument> importWebFilePicker() async {
  return html.document;
}
