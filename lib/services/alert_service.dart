import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AlertItem {
  AlertItem({
    required this.id,
    required this.title,
    required this.text,
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String text;
  bool active;
  final DateTime createdAt;

  factory AlertItem.fromMap(Map<String, dynamic> map) {
    return AlertItem(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Notification',
      text: map['message'] as String,
      active: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String).toLocal()
          : null,
    );
  }
}

class AlertService extends ChangeNotifier {
  List<AlertItem> _alerts = <AlertItem>[];
  bool _isLoading = false;
  String? _error;

  List<AlertItem> get alerts => List<AlertItem>.unmodifiable(_alerts);
  List<AlertItem> get activeAlerts => _alerts.where((a) => a.active).toList(growable: false);
  bool get hasActive => _alerts.any((a) => a.active);
  bool get isLoading => _isLoading;
  String? get error => _error;

  AlertService() {
    _init();
  }

  Future<void> _init() async {
    await fetchAlerts();
    
    // Subscribe to changes with error handling
    try {
      SupabaseConfig.client
          .from('alerts')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .listen(
            (data) {
              debugPrint('AlertService: Received ${data.length} alerts from stream');
              _alerts = data.map((e) => AlertItem.fromMap(e)).toList();
              notifyListeners();
            },
            onError: (error) {
              debugPrint('AlertService stream error: $error');
              _error = error.toString();
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('AlertService: Error setting up stream: $e');
    }
  }

  Future<void> fetchAlerts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client
          .from('alerts')
          .select()
          .order('created_at', ascending: false);
      
      _alerts = (response as List).map((e) => AlertItem.fromMap(e)).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching alerts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(String title, String message) async {
    try {
      debugPrint('AlertService: Adding alert - Title: $title, Message: $message');
      final result = await SupabaseConfig.client.from('alerts').insert({
        'title': title,
        'message': message,
        'is_active': true,
      }).select();
      debugPrint('AlertService: Alert added successfully: $result');
      // Stream will update the list automatically
    } catch (e) {
      debugPrint('Error adding alert: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Legacy support for simple text add
  Future<void> addSimple(String text) async {
    await add('Notification', text);
  }

  Future<void> remove(String id) async {
    try {
      await SupabaseConfig.client.from('alerts').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting alert: $e');
    }
  }

  Future<void> toggleActive(String id, bool active) async {
    // Optimistic update
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _alerts[idx].active = active;
      notifyListeners();
    }

    try {
      await SupabaseConfig.client.from('alerts').update({
        'is_active': active,
      }).eq('id', id);
    } catch (e) {
      debugPrint('Error updating alert status: $e');
      // Revert on error
      if (idx != -1) {
        _alerts[idx].active = !active;
        notifyListeners();
      }
    }
  }

  // Mark all alerts as seen (set active=false)
  Future<void> markAllSeen() async {
    // This might be expensive if many alerts, but for now it's fine
    // Or we could implement a separate 'user_alert_status' table
    // For now, we'll just update local state to avoid modifying global alerts
    // If the requirement is "mark as read for ME", we need a different approach.
    // Given the previous implementation was local-only, "markAllSeen" just cleared the badge.
    // We will keep it local for now to avoid hiding alerts for everyone.
    
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
    // Only clears local list, doesn't delete from DB
    _alerts.clear();
    notifyListeners();
  }
}
