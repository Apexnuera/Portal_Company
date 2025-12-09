import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportQuery {
  final String id;
  final String email;
  final String description;
  final DateTime createdAt;
  final String status; // 'pending', 'in_progress', 'resolved'
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? notes;

  const SupportQuery({
    required this.id,
    required this.email,
    required this.description,
    required this.createdAt,
    this.status = 'pending',
    this.resolvedAt,
    this.resolvedBy,
    this.notes,
  });

  factory SupportQuery.fromJson(Map<String, dynamic> json) {
    return SupportQuery(
      id: json['id'] as String,
      email: json['email'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'pending',
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolvedBy: json['resolved_by'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'notes': notes,
    };
  }

  SupportQuery copyWith({
    String? id,
    String? email,
    String? description,
    DateTime? createdAt,
    String? status,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? notes,
  }) {
    return SupportQuery(
      id: id ?? this.id,
      email: email ?? this.email,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      notes: notes ?? this.notes,
    );
  }
}

/// Supabase-connected support store
class SupportStore extends ChangeNotifier {
  SupportStore._internal();
  static final SupportStore I = SupportStore._internal();

  final List<SupportQuery> _items = <SupportQuery>[];
  bool _isLoading = false;
  String? _error;

  List<SupportQuery> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Fetch all support queries from Supabase
  Future<void> fetchQueries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('support_queries')
          .select()
          .order('created_at', ascending: false);

      _items.clear();
      for (final item in response as List) {
        _items.add(SupportQuery.fromJson(item as Map<String, dynamic>));
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch support queries: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new support query (public submission)
  Future<bool> addQuery({
    required String email,
    required String description,
  }) async {
    try {
      await _supabase
          .from('support_queries')
          .insert({
            'email': email,
            'description': description,
            'status': 'pending',
          });

      // We don't add to _items locally because we can't .select() the return value
      // due to RLS policies (anon users can insert but not select).
      // The HR dashboard will pick it up on next fetch.
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit support query: $e';
      debugPrint(_error);
      return false;
    }
  }

  /// Update query status (HR only)
  Future<bool> updateQueryStatus({
    required String id,
    required String status,
    String? resolvedBy,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
      };

      if (status == 'resolved') {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
        if (resolvedBy != null) {
          updateData['resolved_by'] = resolvedBy;
        }
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await _supabase
          .from('support_queries')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final updatedQuery = SupportQuery.fromJson(response as Map<String, dynamic>);
      final index = _items.indexWhere((q) => q.id == id);
      if (index != -1) {
        _items[index] = updatedQuery;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update query status: $e';
      debugPrint(_error);
      return false;
    }
  }

  /// Delete a support query (HR only)
  Future<bool> deleteQuery(String id) async {
    try {
      await _supabase
          .from('support_queries')
          .delete()
          .eq('id', id);

      _items.removeWhere((q) => q.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete query: $e';
      debugPrint(_error);
      return false;
    }
  }

  /// Clear all queries (local only, for testing)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
