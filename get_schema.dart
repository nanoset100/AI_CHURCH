import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://aaaxmajwtxvzzqlyyxom.supabase.co/rest/v1/?apikey=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhYXhtYWp3dHh2enpxbHl5eG9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwODkwMDMsImV4cCI6MjA4NDY2NTAwM30.zUTtidq34X2r9N5KBBwzYICU3w_r48Nldh_k72Ayt8g');
  
  try {
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    final content = await response.transform(utf8.decoder).join();
    
    final data = jsonDecode(content);
    
    if (data['definitions'] != null) {
      if (data['definitions']['worship_logs'] != null) {
        final worshipLogs = data['definitions']['worship_logs']['properties'];
        print('worship_logs columns: ${worshipLogs.keys.toList()}');
      } else {
        print('worship_logs table not found in schema definitions.');
      }
      
      if (data['definitions']['bible_reading_logs'] != null) {
        final bibleLogs = data['definitions']['bible_reading_logs']['properties'];
        print('bible_reading_logs columns: ${bibleLogs.keys.toList()}');
      } else {
        print('bible_reading_logs table not found in schema definitions.');
      }
    } else {
      print('Definitions not found in response.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
