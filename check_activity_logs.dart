import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://aaaxmajwtxvzzqlyyxom.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhYXhtYWp3dHh2enpxbHl5eG9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwODkwMDMsImV4cCI6MjA4NDY2NTAwM30.zUTtidq34X2r9N5KBBwzYICU3w_r48Nldh_k72Ayt8g';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('--- Fetching all worship_logs ---');
  try {
     final response = await supabase.from('worship_logs').select();
     print('worship_logs: $response');
  } catch (e) {
     print('worship_logs error: $e');
  }

  print('--- Fetching all bible_reading_logs ---');
  try {
     final response = await supabase.from('bible_reading_logs').select();
     print('bible_reading_logs: $response');
  } catch (e) {
     print('bible_reading_logs error: $e');
  }
}
