import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  // .env 파일 로드 시도 (프로젝트 루트 기준)
  try {
    if (File('.env').existsSync()) {
      final lines = File('.env').readAsLinesSync();
      for (var line in lines) {
        if (line.isEmpty || line.startsWith('#')) continue;
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          Platform.environment[key] = value;
          print('Loaded ENV: $key');
        }
      }
    }
  } catch (e) {
    print('Env load error: $e');
  }

  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'https://aaaxmajwtxvzzqlyyxom.supabase.co';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhYXhtYWp3dHh2enpxbHl5eG9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwODkwMDMsImV4cCI6MjA4NDY2NTAwM30.zUTtidq34X2r9N5KBBwzYICU3w_r48Nldh_k72Ayt8g';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    print('Fetching profiles...');
    final response = await supabase
        .from('profiles')
        .select()
        .limit(5);
    
    print('Profiles found: ${response.length}');
    for (var profile in response) {
      print('ID: ${profile['id']}, Email: ${profile['email']}, Name: ${profile['display_name']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
