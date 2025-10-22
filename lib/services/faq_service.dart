import 'package:flutter/foundation.dart';

class FaqItem {
  final String id;
  String question;
  String answer;

  FaqItem({required this.id, required this.question, required this.answer});

  FaqItem copy() => FaqItem(id: id, question: question, answer: answer);
}

class FaqService extends ChangeNotifier {
  FaqService._internal();
  static final FaqService instance = FaqService._internal();

  final List<FaqItem> _faqs = <FaqItem>[];

  List<FaqItem> get faqs => List.unmodifiable(_faqs);

  void initialize() {
    // start empty; ready for HR to add
  }

  void addFaq(String question, String answer) {
    final id = 'FAQ-${DateTime.now().millisecondsSinceEpoch}';
    _faqs.insert(0, FaqItem(id: id, question: question, answer: answer));
    notifyListeners();
  }

  void updateFaq(String id, {String? question, String? answer}) {
    final idx = _faqs.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    final f = _faqs[idx];
    _faqs[idx] = FaqItem(
      id: f.id,
      question: question ?? f.question,
      answer: answer ?? f.answer,
    );
    notifyListeners();
  }

  void removeFaq(String id) {
    _faqs.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}
