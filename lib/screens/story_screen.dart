import 'package:flutter/material.dart';
import '../models/story.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/logger.dart';
import 'dart:io';
import 'dart:convert';

class StoryScreen extends StatefulWidget {
  final Story story;

  const StoryScreen({
    super.key,
    required this.story,
  });
  
  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  
  /// Builds the appropriate image widget based on available image sources
  Widget _buildImageWidget() {
    // If we have base64 image data, use that first (works on all platforms)
    if (widget.story.imageBase64 != null) {
      try {
        final imageBytes = base64Decode(widget.story.imageBase64!);
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            AppLogger.e('Error loading base64 image: $error');
            return _buildFallbackImage();
          },
        );
      } catch (e) {
        AppLogger.e('Error decoding base64 image: $e');
        // Try other image sources if base64 fails
      }
    }
    
    // If we have a local image path, try that next
    if (widget.story.localImagePath != null) {
      try {
        final file = File(widget.story.localImagePath!);
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            AppLogger.e('Error loading local image: $error');
            // Fall back to network image if local file fails
            if (widget.story.imageUrl != null) {
              return _buildNetworkImage();
            } else {
              return _buildFallbackImage();
            }
          },
        );
      } catch (e) {
        AppLogger.e('Error with file image: $e');
        // Platform might not support File operations (web)
      }
    }
    
    // If we only have a URL, use that
    if (widget.story.imageUrl != null) {
      return _buildNetworkImage();
    }
    
    // Fallback if no image source is available
    return const Center(
      child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
    );
  }
  
  /// Builds a fallback image widget for error cases
  Widget _buildFallbackImage() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: Colors.red, size: 40),
          SizedBox(height: 8),
          Text('Failed to load image', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
  
  /// Builds a network image widget with loading and error states
  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: widget.story.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            const SizedBox(height: 8),
            const Text('Loading image...'),
          ],
        ),
      ),
      errorWidget: (context, url, error) {
        AppLogger.e('Failed to load image: $url, Error: $error');
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              const Text('Failed to load image', 
                style: TextStyle(color: Colors.red),
              ),
              TextButton(
                onPressed: () {
                  AppLogger.i('Attempting to reload image: $url');
                  // This will trigger a reload of the image
                  CachedNetworkImage.evictFromCache(url);
                  setState(() {});
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      httpHeaders: const {
        // Add required headers for image loading
        'Accept': 'image/jpeg,image/png,image/svg+xml,image/*,*/*;q=0.8',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        centerTitle: true,
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story title
              Text(
                widget.story.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 24),
              
              // Story image (if available)
              if (widget.story.localImagePath != null || widget.story.imageUrl != null)
                Container(
                  width: double.infinity,
                  height: 250,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51), // 0.2 opacity equals approximately 51 in alpha
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImageWidget(),
                ),
              
              // Story content
              Text(
                widget.story.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
      // Floating action button to return to home
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
