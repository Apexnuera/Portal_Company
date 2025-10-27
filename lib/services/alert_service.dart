import 'package:flutter/foundation.dart';

class AlertItem {
  AlertItem({required this.id, required this.text, this.active = true, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();
  final String id; // unique id
  String text;
  bool active;
  final DateTime createdAt;
}

class AlertService extends ChangeNotifier {
  final List<AlertItem> _alerts = <AlertItem>[];

  List<AlertItem> get alerts => List<AlertItem>.unmodifiable(_alerts);

  List<AlertItem> get activeAlerts => _alerts.where((a) => a.active).toList(growable: false);

  bool get hasActive => _alerts.any((a) => a.active);

  void add(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    _alerts.insert(0, AlertItem(id: id, text: value, active: true));
    notifyListeners();
  }

  void remove(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleActive(String id, bool active) {
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    if (_alerts[idx].active == active) return;
    _alerts[idx].active = active;
    notifyListeners();
  }

  // Mark all alerts as seen (set active=false)
  void markAllSeen() {
    bool changed = false;
    for (final a in _alerts) {
      if (a.active) {
        a.active = false;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void clearAll() {
    if (_alerts.isEmpty) return;
    _alerts.clear();
    notifyListeners();
  }
}
