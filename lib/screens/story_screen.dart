import 'package:flutter/material.dart';
import '../models/story.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/logger.dart';
import '../utils/speech_service.dart';
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
  // Speech service for text-to-speech functionality
  final SpeechService _speechService = SpeechService();
  bool _isNarrating = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize the speech service
    _speechService.initialize();
  }
  
  @override
  void dispose() {
    // Dispose the speech service
    _speechService.dispose();
    super.dispose();
  }
  
  /// Builds the appropriate image widget based on available image sources
  Widget _buildImageWidget() {
    // If we have base64 image data, use that first (works on all platforms)
    if (widget.story.imageBase64 != null) {
      try {
        final imageBytes = base64Decode(widget.story.imageBase64!);
        return Image.memory(
          imageBytes,
          fit: BoxFit.contain, // Changed from cover to contain to show the full image
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
          fit: BoxFit.contain, // Changed from cover to contain to show the full image
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
      fit: BoxFit.contain, // Changed from cover to contain to show the full image
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
          // Narration button
          IconButton(
            icon: Icon(_isNarrating ? Icons.stop : Icons.volume_up),
            tooltip: _isNarrating ? 'Stop narration' : 'Read aloud',
            onPressed: () {
              _toggleNarration();
            },
          ),
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
              if (widget.story.imageBase64 != null || widget.story.localImagePath != null || widget.story.imageUrl != null)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 200,
                    maxHeight: 400, // Allow more height for taller images
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
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
      // Floating action buttons
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Narration control button
          FloatingActionButton(
            heroTag: 'narrationButton',
            onPressed: _toggleNarration,
            backgroundColor: _isNarrating ? Colors.red : Theme.of(context).colorScheme.secondary,
            mini: true,
            child: Icon(_isNarrating ? Icons.stop : Icons.volume_up),
          ),
          const SizedBox(height: 16),
          // Home button
          FloatingActionButton(
            heroTag: 'homeButton',
            onPressed: () {
              // Stop narration if active before navigating
              if (_isNarrating) {
                _speechService.stop();
              }
              Navigator.pop(context);
            },
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
  
  /// Toggle narration on/off
  void _toggleNarration() async {
    if (_isNarrating) {
      // Stop narration
      await _speechService.stop();
      setState(() {
        _isNarrating = false;
      });
      AppLogger.i('Narration stopped');
    } else {
      // Start narration
      AppLogger.i('Starting narration of story: ${widget.story.title}');
      
      // Prepare the text to be narrated
      final String narrateText = '${widget.story.title}. ${widget.story.content}';
      
      // Start narration
      final bool success = await _speechService.speak(narrateText);
      
      setState(() {
        _isNarrating = success;
      });
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start narration')),
        );
      }
    }
  }
}
