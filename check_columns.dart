import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://aaaxmajwtxvzzqlyyxom.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhYXhtYWp3dHh2enpxbHl5eG9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwODkwMDMsImV4cCI6MjA4NDY2NTAwM30.zUTtidq34X2r9N5KBBwzYICU3w_r48Nldh_k72Ayt8g';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('--- Testing sermon_title column ---');
  try {
     final response = await supabase.from('worship_logs').insert({'sermon_title': 'test'});
     print('sermon_title success: $response');
  } catch (e) {
     print('sermon_title error: $e');
  }

  print('--- Testing book_name column ---');
  try {
     final response = await supabase.from('bible_reading_logs').insert({'book_name': 'test'});
     print('book_name success: $response');
  } catch (e) {
     print('book_name error: $e');
  }

  print('--- Testing title and book columns ---');
  try {
     await supabase.from('worship_logs').insert({'title': 'test'});
  } catch (e) {
     print('title error: $e');
  }
  try {
     await supabase.from('bible_reading_logs').insert({'book': 'test'});
  } catch (e) {
     print('book error: $e');
  }
}
