import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

class ImagePickerWeb {
  static Future<Uint8List?> pickImage() async {
    final completer = Completer<Uint8List?>();
    
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();
    
    input.onChange.listen((event) async {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        
        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          completer.complete(null);
          return;
        }
        
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        
        reader.onLoadEnd.listen((event) {
          final bytes = reader.result as List<int>;
          completer.complete(Uint8List.fromList(bytes));
        });
        
        reader.onError.listen((event) {
          completer.complete(null);
        });
      } else {
        completer.complete(null);
      }
    });
    
    return completer.future;
  }
}
