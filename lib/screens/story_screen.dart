import 'package:flutter/material.dart';
import '../models/story.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/logger.dart';
import '../utils/speech_service.dart';
import '../services/playht_service.dart';
import '../widgets/audio_player_widget.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

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
  // Services
  final SpeechService _speechService = SpeechService();
  final PlayHtService _playHtService = PlayHtService();
  bool _isNarrating = false;
  
  // Local copy of the story that can be updated
  late Story _story;
  
  @override
  void initState() {
    super.initState();
    // Initialize the speech service
    _speechService.initialize();
    
    // Initialize the local story copy
    _story = widget.story;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.story.title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
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
                SnackBar(
                  content: const Text('Sharing functionality coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background with subtle pattern
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              image: const DecorationImage(
                image: AssetImage('assets/images/explorer_paper_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
          ),
          
          // Main content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Story image with immersive design
                if (widget.story.imageBase64 != null || widget.story.localImagePath != null || widget.story.imageUrl != null)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Stack(
                      children: [
                        // Image
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: _buildImageWidget(),
                        ),
                        // Gradient overlay for better text visibility
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 150,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Title overlay
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Story title with explorer styling
                              Text(
                                widget.story.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Story content with explorer styling
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: widget.story.imageBase64 != null || widget.story.localImagePath != null || widget.story.imageUrl != null
                      ? const BorderRadius.vertical(top: Radius.circular(32))
                      : null,
                    boxShadow: widget.story.imageBase64 != null || widget.story.localImagePath != null || widget.story.imageUrl != null
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ]
                      : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show title only if no image is available
                      if (widget.story.imageBase64 == null && widget.story.localImagePath == null && widget.story.imageUrl == null) ...[                        
                        Text(
                          widget.story.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Story content with styled text
                      Text(
                        widget.story.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          letterSpacing: 0.3,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Narration section with explorer styling
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title
                            Row(
                              children: [
                                Icon(
                                  Icons.record_voice_over,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'STORY NARRATION',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Narration button - show only if narration is not ready
                            if (_story.narrationStatus != NarrationStatus.ready)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _story.narrationStatus == NarrationStatus.generating ? null : _generateNarration,
                                  icon: _story.narrationStatus == NarrationStatus.generating 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.record_voice_over),
                                  label: Text(_getButtonLabel()),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            
                            // Audio player - show only if narration is ready
                            if (_story.narrationStatus == NarrationStatus.ready && _story.audioUrl != null) ...[  
                              const Text(
                                'Listen to the tale unfold through narration:',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 16),
                              AudioPlayerWidget(audioUrl: _story.audioUrl!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating action buttons with explorer styling
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Narration control button
          FloatingActionButton(
            heroTag: 'narrationButton',
            onPressed: _toggleNarration,
            backgroundColor: _isNarrating 
                ? Theme.of(context).colorScheme.error 
                : Theme.of(context).colorScheme.secondary,
            mini: true,
            elevation: 4,
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            child: const Icon(Icons.explore),
          ),
        ],
      ),
    );
  }
  
  /// Generate narration using Play.ht API
  Future<void> _generateNarration() async {
    // Update state to show loading
    setState(() {
      _story = _story.copyWith(narrationStatus: NarrationStatus.generating);
    });
    
    try {
      // Prepare the text to be narrated
      final String narrateText = '${_story.title}. ${_story.content}';
      
      // Generate speech using Play.ht API
      final audioUrl = await _playHtService.generateSpeech(text: narrateText);
      
      if (audioUrl != null) {
        // Update the story with the audio URL
        setState(() {
          _story = _story.copyWith(
            audioUrl: audioUrl,
            narrationStatus: NarrationStatus.ready,
          );
        });
        
        AppLogger.i('Narration generated successfully: $audioUrl');
      } else {
        // Handle error
        setState(() {
          _story = _story.copyWith(narrationStatus: NarrationStatus.failed);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate narration')),
        );
      }
    } catch (e) {
      // Handle exception
      AppLogger.e('Error generating narration: $e');
      
      setState(() {
        _story = _story.copyWith(narrationStatus: NarrationStatus.failed);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating narration: $e')),
      );
    }
  }
  
  /// Get the appropriate button label based on narration status
  String _getButtonLabel() {
    switch (_story.narrationStatus) {
      case NarrationStatus.generating:
        return 'Generating Narration...';
      case NarrationStatus.ready:
        return 'Regenerate Narration';
      case NarrationStatus.failed:
        return 'Retry Narration';
      case NarrationStatus.none:
        return 'Generate Narration';
    }
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
