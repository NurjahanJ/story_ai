import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/story.dart';
import 'dart:math';
import '../utils/logger.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  // Get API key from .env file
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };
  
  // DALL-E image size - using fixed size for reliability
  static const String _imageSize = '1024x1024';

  // Helper method to preprocess JSON content
  String _preprocessJsonContent(String content) {
    // Remove markdown code block markers if present
    content = content.replaceAll('```json', '').replaceAll('```', '');
    
    // Trim whitespace
    content = content.trim();
    
    // Ensure content starts with { and ends with }
    if (!content.startsWith('{')) {
      int startIndex = content.indexOf('{');
      if (startIndex >= 0) {
        content = content.substring(startIndex);
      } else {
        // If no JSON object found, wrap the content in a simple JSON structure
        return '{"title": "Generated Story", "content": ${jsonEncode(content)}}';
      }
    }
    
    if (!content.endsWith('}')) {
      int endIndex = content.lastIndexOf('}');
      if (endIndex >= 0) {
        content = content.substring(0, endIndex + 1);
      }
    }
    
    return content;
  }
  
  // Generate a story based on a prompt or genre
  Future<Story> generateStory(String prompt, {String? genre}) async {
    try {
      // Create a more detailed prompt based on the genre if provided
      String enhancedPrompt = prompt;
      if (genre != null && genre.isNotEmpty) {
        enhancedPrompt = 'Create a $genre story about: $prompt';
      }
      
      // Call the GPT API to generate a story
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a creative storyteller. Create a short story as a single continuous narrative. Your response MUST be valid JSON with EXACTLY this structure: {"title": "Story Title", "content": "The full story content"}. Do not include any markdown formatting, code blocks, or explanations outside the JSON. Make the story about 3-5 paragraphs long. Ensure all quotes in the content are properly escaped.'
            },
            {
              'role': 'user',
              'content': enhancedPrompt
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'];
          
          // Preprocess the content to fix potential JSON formatting issues
          final preprocessedContent = _preprocessJsonContent(content);
          
          // Try to parse the JSON response
          try {
            final storyJson = jsonDecode(preprocessedContent);
            return Story.fromJson(storyJson);
          } catch (jsonError) {
            // If JSON parsing fails, create a story from the raw content
            AppLogger.e('Error parsing JSON: $jsonError');
            AppLogger.d('Raw content: $content');
            AppLogger.d('Preprocessed content: $preprocessedContent');
            
            // Extract title and content using regex or simple string manipulation
            String title = 'Generated Story';
            String storyContent = content;
            
            // Try to extract a title if the content starts with something that looks like a title
            final contentLines = content.split('\n');
            if (contentLines.isNotEmpty && contentLines[0].trim().isNotEmpty) {
              // Use the first line as title if it's short enough
              if (contentLines[0].length < 100) {
                title = contentLines[0].trim();
                // Remove the title from the content
                storyContent = contentLines.skip(1).join('\n').trim();
              }
            }
            
            return Story(
              title: title,
              content: storyContent,
            );
          }
        } catch (e) {
          throw Exception('Error processing API response: $e');
        }
      } else {
        throw Exception('Failed to generate story: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating story: $e');
    }
  }

  // Generate an image using DALL-E 3
  Future<String> generateImage(String prompt) async {
    try {
      // Create a more detailed prompt for the image
      String enhancedPrompt = 'Create a high-quality, detailed illustration for a story with the following description: $prompt';
      
      AppLogger.d('Generating image with prompt: $enhancedPrompt');
      
      // Use a fixed size for more reliable results
      AppLogger.d('Using image size: $_imageSize');
      
      // Call the DALL-E API to generate an image
      final response = await http.post(
        Uri.parse('$_baseUrl/images/generations'),
        headers: _headers,
        body: jsonEncode({
          'model': 'dall-e-2', // Try DALL-E 2 which might be more reliable for some accounts
          'prompt': enhancedPrompt,
          'n': 1,
          'size': _imageSize,
          'response_format': 'url',
        }),
      );

      AppLogger.d('DALL-E API response status: ${response.statusCode}');
      AppLogger.d('DALL-E API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if the response contains the expected data structure
        if (data != null && data['data'] != null && data['data'].isNotEmpty) {
          // Extract the image URL from the response
          final imageData = data['data'][0];
          if (imageData.containsKey('url')) {
            final imageUrl = imageData['url'];
            AppLogger.i('Successfully generated image: $imageUrl');
            return imageUrl;
          } else if (imageData.containsKey('b64_json')) {
            // Handle base64 encoded image if that's what was returned
            AppLogger.w('Received base64 image instead of URL. This is not currently supported.');
            throw Exception('Base64 image format not supported');
          }
        }
        
        // If we got here, the response format was unexpected
        AppLogger.e('Invalid response format from DALL-E API: $data');
        throw Exception('Invalid response format from DALL-E API');
      } else {
        AppLogger.e('Failed to generate image: ${response.statusCode} ${response.body}');
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('Error generating image: $e');
      throw Exception('Error generating image: $e');
    }
  }

  // Generate a complete story with an image
  Future<Story> generateStoryWithPrompt(String prompt, {String? genre}) async {
    // First generate the story
    final story = await generateStory(prompt, genre: genre);
    
    try {
      // Then generate an image based on the story title and content
      final imagePrompt = '${story.title}: ${story.content.substring(0, min(100, story.content.length))}';
      final imageUrl = await generateImage(imagePrompt);
      
      // Return a new story object with the image URL
      return Story(
        title: story.title,
        content: story.content,
        imageUrl: imageUrl,
      );
    } catch (e) {
      // If image generation fails, return the story without an image
      AppLogger.w('Failed to generate image, returning story without image: $e');
      return story;
    }
  }
}
