import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mwmgkgjxgrymhdgwnolm.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_rNObFy-vsATDVoHt3O7IDg_lWRTLcMK';

  static SupabaseClient get client => Supabase.instance.client;
}
