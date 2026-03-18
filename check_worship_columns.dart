import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabaseUrl = 'https://aaaxmajwtxvzzqlyyxom.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhYXhtYWp3dHh2enpxbHl5eG9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwODkwMDMsImV4cCI6MjA4NDY2NTAwM30.zUTtidq34X2r9N5KBBwzYICU3w_r48Nldh_k72Ayt8g';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    final response = await supabase.from('worship_logs').select().limit(1);
    if (response.isNotEmpty) {
      print('worship_logs columns: ${response[0].keys.toList()}');
    } else {
      print('worship_logs is empty, trying to insert an invalid row to get error details');
      await supabase.from('worship_logs').insert({'invalid_column': 1});
    }
  } catch (e) {
    print('Error: $e');
  }
  exit(0);
}
