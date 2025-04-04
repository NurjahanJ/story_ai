import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'logger.dart';

/// A utility class for downloading and caching images from URLs
class ImageDownloader {
  static final Dio _dio = Dio();
  
  /// Downloads an image from a URL and saves it to local storage
  /// Returns the path to the saved file
  static Future<String> downloadImage(String imageUrl) async {
    try {
      // Generate a unique filename based on the URL
      final String filename = _generateFilename(imageUrl);
      
      // Get the temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$filename';
      
      // Check if the file already exists
      final File file = File(filePath);
      if (await file.exists()) {
        AppLogger.i('Image already cached: $filePath');
        return filePath;
      }
      
      // Download the image
      AppLogger.i('Downloading image from: $imageUrl');
      final Response response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          headers: {
            'Accept': 'image/jpeg,image/png,image/svg+xml,image/*,*/*;q=0.8',
          },
        ),
      );
      
      // Save the image to a file
      await file.writeAsBytes(response.data);
      AppLogger.i('Image saved to: $filePath');
      
      return filePath;
    } catch (e) {
      AppLogger.e('Error downloading image: $e');
      rethrow;
    }
  }
  
  /// Generates a unique filename based on the URL
  static String _generateFilename(String url) {
    // Create a hash of the URL to use as the filename
    final String hash = md5.convert(utf8.encode(url)).toString();
    return 'dalle_image_$hash.png';
  }
}
