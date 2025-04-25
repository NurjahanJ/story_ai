import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// A simple script to test the Play.ht API directly
void main() async {
  // Load environment variables
  await dotenv.load();
  
  // Get API key from .env file
  final apiKey = dotenv.env['PLAYHT_API_KEY'];
  print('API Key (masked): ${maskApiKey(apiKey ?? '')}');
  
  // API endpoints
  const baseUrl = 'https://play.ht/api/v2';
  const ttsEndpoint = '/tts';
  
  // Headers for API requests
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'X-USER-ID': 'user-id', // This would typically be a user ID from Play.ht
    'Accept': 'application/json',
  };
  
  // Sample text to convert to speech
  const text = 'This is a test of the Play.ht API.';
  
  // Default voice ID (one of the free-tier voices)
  const defaultVoiceId = 'd9ff78ba-d016-47f6-b0ef-dd630f59414e';
  
  try {
    print('Testing Play.ht API...');
    
    // Prepare the request body
    final requestBody = {
      'text': text,
      'voice': defaultVoiceId,
      'output_format': 'mp3',
      'voice_engine': 'PlayHT2.0',
      'quality': 'draft',
    };
    
    print('Request body: ${jsonEncode(requestBody)}');
    
    // Make the API request to generate speech
    final response = await http.post(
      Uri.parse('$baseUrl$ttsEndpoint'),
      headers: headers,
      body: jsonEncode(requestBody),
    );
    
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Success! Response data: $data');
      
      // Check if the response contains a job ID
      if (data.containsKey('id')) {
        final jobId = data['id'];
        print('Job ID: $jobId');
        
        // Wait for the job to complete
        await checkJobStatus(jobId, headers, baseUrl);
      }
    } else {
      print('Failed to generate speech: ${response.statusCode}');
      print('Error details: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Check job status
Future<void> checkJobStatus(String jobId, Map<String, String> headers, String baseUrl) async {
  print('Checking job status for job ID: $jobId');
  
  bool isCompleted = false;
  int attempts = 0;
  
  while (!isCompleted && attempts < 10) {
    attempts++;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: headers,
      );
      
      print('Job status check attempt $attempts - Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        
        print('Job status: $status');
        
        if (status == 'completed') {
          print('Job completed!');
          print('Output URL: ${data['output']['url']}');
          isCompleted = true;
        } else if (status == 'failed') {
          print('Job failed: ${data['error'] ?? 'Unknown error'}');
          isCompleted = true;
        } else {
          print('Job still in progress. Waiting 2 seconds before checking again...');
          await Future.delayed(Duration(seconds: 2));
        }
      } else {
        print('Failed to check job status: ${response.statusCode}');
        print('Error details: ${response.body}');
        isCompleted = true;
      }
    } catch (e) {
      print('Error checking job status: $e');
      isCompleted = true;
    }
  }
  
  if (!isCompleted) {
    print('Timed out waiting for job completion');
  }
}

// Mask API key for logging
String maskApiKey(String apiKey) {
  if (apiKey.isEmpty) return 'empty';
  if (apiKey.length <= 8) return '****';
  
  return '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';
}
