import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';
import '../utils/env_loader.dart';


/// Service for interacting with the Play.ht API for text-to-speech generation
class PlayHtService {
  static final PlayHtService _instance = PlayHtService._internal();
  factory PlayHtService() => _instance;
  
  PlayHtService._internal();
  
  // Play.ht API endpoints
  static const String _baseUrl = 'https://play.ht/api/v2';
  static const String _ttsEndpoint = '/tts';
  
  // Get API key from .env file
  String get _apiKey => dotenv.env['PLAYHT_API_KEY'] ?? '';
  
  // Default voice ID (one of the free-tier voices)
  // s3://voice-cloning-zero-shot/d9ff78ba-d016-47f6-b0ef-dd630f59414e/female-cs/manifest.json
  static const String _defaultVoiceId = 'd9ff78ba-d016-47f6-b0ef-dd630f59414e';
  
  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
    'X-USER-ID': 'user-id', // This would typically be a user ID from Play.ht
    'Accept': 'application/json',
  };
  
  // Log headers for debugging (without exposing full API key)
  void _logHeaders() {
    final apiKey = _apiKey;
    final maskedKey = apiKey.isNotEmpty 
        ? '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}' 
        : 'empty';
    AppLogger.d('API Key (masked): $maskedKey');
  }
  
  /// Check if the API key is set
  bool isApiKeySet() {
    final isSet = EnvLoader.isPlayHtApiKeySet();
    if (isSet) {
      final apiKey = dotenv.env['PLAYHT_API_KEY'];
      AppLogger.i('Play.ht API key is set (length: ${apiKey?.length ?? 0})');
    } else {
      AppLogger.e('Play.ht API key is not properly set in .env file');
    }
    return isSet;
  }
  
  /// Generate speech from text using Play.ht API
  /// Returns the URL of the generated audio file
  Future<String?> generateSpeech({
    required String text,
    String? voiceId,
    bool waitForCompletion = true,
  }) async {
    // Check if API key is set
    if (!isApiKeySet()) {
      AppLogger.e('Play.ht API key is not set');
      return null;
    }
    
    // Log headers (masked)
    _logHeaders();
    
    try {
      AppLogger.i('Generating speech with Play.ht API for text of length ${text.length}');
      
      // Prepare the request body
      final requestBody = {
        'text': text,
        'voice': voiceId ?? _defaultVoiceId,
        'output_format': 'mp3',
        'voice_engine': 'PlayHT2.0', // Changed from PlayHT2.0-turbo which might not exist
        'quality': 'draft', // Use draft quality for faster generation
      };
      
      // Log request body
      AppLogger.d('Request body: ${jsonEncode(requestBody)}');
      
      final body = jsonEncode(requestBody);
      
      // Make the API request to generate speech
      final response = await http.post(
        Uri.parse('$_baseUrl$_ttsEndpoint'),
        headers: _headers,
        body: body,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Check if the response contains a job ID
        if (data.containsKey('id')) {
          final jobId = data['id'];
          AppLogger.i('Speech generation job created with ID: $jobId');
          
          if (waitForCompletion) {
            // Wait for the job to complete and get the audio URL
            return await _waitForJobCompletion(jobId);
          } else {
            // Return the job ID if not waiting for completion
            return jobId;
          }
        } else {
          AppLogger.e('No job ID found in Play.ht API response');
          return null;
        }
      } else {
        final errorBody = response.body;
        AppLogger.e('Failed to generate speech: Status ${response.statusCode}');
        AppLogger.e('Error details: $errorBody');
        return null;
      }
    } catch (e) {
      AppLogger.e('Error generating speech with Play.ht API: $e');
      return null;
    }
  }
  
  /// Wait for a Play.ht job to complete and return the audio URL
  Future<String?> _waitForJobCompletion(String jobId, {int maxAttempts = 30, int delaySeconds = 2}) async {
    AppLogger.i('Waiting for Play.ht job completion: $jobId');
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        // Check job status
        final response = await http.get(
          Uri.parse('$_baseUrl/jobs/$jobId'),
          headers: _headers,
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          // Check job status
          final status = data['status'];
          
          if (status == 'completed') {
            // Job completed, get the audio URL
            if (data.containsKey('output') && data['output'] != null) {
              final audioUrl = data['output']['url'];
              AppLogger.i('Speech generation completed. Audio URL: $audioUrl');
              return audioUrl;
            } else {
              AppLogger.e('No audio URL found in completed job');
              return null;
            }
          } else if (status == 'failed') {
            // Job failed
            AppLogger.e('Speech generation job failed: ${data['error'] ?? 'Unknown error'}');
            return null;
          } else {
            // Job still in progress, wait and try again
            AppLogger.d('Job status: $status. Waiting ${delaySeconds}s before checking again...');
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        } else {
          AppLogger.e('Failed to check job status: ${response.statusCode} ${response.body}');
          return null;
        }
      } catch (e) {
        AppLogger.e('Error checking job status: $e');
        return null;
      }
    }
    
    // Max attempts reached without completion
    AppLogger.e('Timed out waiting for job completion');
    return null;
  }
  
  /// Check job status for a previously submitted job
  Future<Map<String, dynamic>?> checkJobStatus(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/jobs/$jobId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        AppLogger.e('Failed to check job status: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      AppLogger.e('Error checking job status: $e');
      return null;
    }
  }
  
  /// Get available voices from Play.ht API
  Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        AppLogger.e('Failed to get voices: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      AppLogger.e('Error getting voices: $e');
      return [];
    }
  }
  
  /// Create an audio player for the given audio URL
  Future<AudioPlayer?> createAudioPlayer(String audioUrl) async {
    try {
      final audioPlayer = AudioPlayer();
      await audioPlayer.setUrl(audioUrl);
      return audioPlayer;
    } catch (e) {
      AppLogger.e('Error creating audio player: $e');
      return null;
    }
  }
}
