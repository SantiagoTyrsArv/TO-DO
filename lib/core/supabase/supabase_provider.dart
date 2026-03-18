import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides a single access point to the [SupabaseClient] singleton.
///
/// Supabase must already be initialised (via [Supabase.initialize]) in
/// [main.dart] before any call to [SupabaseProvider.client] is made.
class SupabaseProvider {
  SupabaseProvider._();

  /// Returns the globally initialised [SupabaseClient] instance.
  static SupabaseClient get client => Supabase.instance.client;
}
