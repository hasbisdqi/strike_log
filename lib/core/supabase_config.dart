import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mwmgkgjxgrymhdgwnolm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13bWdrZ2p4Z3J5bWhkZ3dub2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxNTM0MDMsImV4cCI6MjA4NzcyOTQwM30.haavbsBI6CgbLaLS54HskcWfwI38JtYg-c_O56feXcc';

  static SupabaseClient get client => Supabase.instance.client;
}
