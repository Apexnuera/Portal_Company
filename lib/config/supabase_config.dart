import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and client initialization
class SupabaseConfig {
  // TODO: Replace with your actual Supabase anon key from Project Settings > API
  // You can find this in your Supabase dashboard
  static const String supabaseUrl = 'https://utjihkmkmzzerhokpvps.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_wCSiSjeDtgx5-UQjBkszYQ_eshY8nFx';

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
