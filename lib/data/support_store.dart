import 'package:flutter/foundation.dart';

class SupportQuery {
  final String email;
  final String description;
  final DateTime createdAt;

  const SupportQuery({
    required this.email,
    required this.description,
    required this.createdAt,
  });
}

/// Simple in-memory store. Any page can call SupportStore.I.addQuery(...)
/// The HR dashboard listens and reflects updates immediately.
class SupportStore extends ChangeNotifier {
  SupportStore._internal();
  static final SupportStore I = SupportStore._internal();

  final List<SupportQuery> _items = <SupportQuery>[];

  List<SupportQuery> get items => List.unmodifiable(_items);

  void addQuery(SupportQuery q) {
    _items.insert(0, q); // newest first
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
