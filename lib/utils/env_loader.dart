import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger.dart';

class EnvLoader {
  // Initialize environment variables
  static Future<void> load() async {
    try {
      await dotenv.load();
      AppLogger.i('Environment variables loaded successfully');
    } catch (e) {
      AppLogger.e('Error loading environment variables: $e');
    }
  }
  
  // Check if API key is set
  static bool isApiKeySet() {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    return apiKey != null && apiKey.isNotEmpty && apiKey != 'your_openai_api_key_here';
  }
}
