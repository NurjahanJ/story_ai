import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/services.dart';
import '../models/story.dart';
import '../utils/logger.dart';
import '../utils/app_theme.dart';

class StoryScreen extends StatefulWidget {
  final Story story;

  const StoryScreen({
    super.key,
    required this.story,
  });
  
  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Create fade-in animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
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
    // Parse story content into paragraphs
    List<String> paragraphs = _formatContentIntoParagraphs(widget.story.content);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      // Transparent AppBar with no title
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon!'))
              );
            },
          ),
          // Save button
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () {
              _showSaveOptions(context);
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Explorer-themed background
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                // Use a gradient instead of an image to avoid asset issues
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundColor,
                    AppTheme.backgroundColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Image section
                SliverToBoxAdapter(
                  child: Hero(
                    tag: 'story_image',
                    child: Container(
                      // 60% of screen height
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image (always show, fallback if missing)
                          _buildImageWidget(),
                          // Gradient overlay for text visibility
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 150, // Increased gradient height
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(220), // Darker gradient
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Title overlay (always show)
                          Positioned(
                            bottom: 24, // Increased bottom padding
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Story title with explorer styling - uppercase
                                Text(
                                  widget.story.title.toUpperCase(),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Merriweather',
                                    letterSpacing: 1.2,
                                    fontSize: 28,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.7),
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
                  ),
                ),
                
                // Story content with explorer styling
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: widget.story.imageBase64 != null || 
                           widget.story.localImagePath != null || 
                           widget.story.imageUrl != null ? 0 : 16,
                      bottom: 80, // Add bottom margin to avoid FAB overlap
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: widget.story.imageBase64 != null || 
                                   widget.story.localImagePath != null || 
                                   widget.story.imageUrl != null
                        ? const BorderRadius.vertical(top: Radius.circular(32))
                        : BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                     child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Only show the title above the content if it's not the default
                        if (widget.story.title.trim().toLowerCase() != 'generated story') ...[
                          Text(
                            widget.story.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Merriweather',
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Decorative divider
                          Center(
                            child: SizedBox(
                              width: 100,
                              child: Divider(
                                color: AppTheme.secondaryColor.withOpacity(0.5),
                                thickness: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Story content with paragraphs and styled text
                        ..._buildParagraphs(paragraphs, context),
                        
                        const SizedBox(height: 16),
                        
                        // Decorative footer
                        Center(
                          child: Icon(
                            Icons.explore,
                            color: AppTheme.secondaryColor.withOpacity(0.5),
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Floating action buttons
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Home button
            FloatingActionButton(
              heroTag: 'homeButton',
              onPressed: () {
                // Navigate back with animation
                Navigator.pop(context);
              },
              backgroundColor: AppTheme.primaryColor,
              elevation: 4,
              child: const Icon(Icons.explore),
            ),
          ],
        ),
      ),
    );
  }
  
  // Format content into paragraphs
  List<String> _formatContentIntoParagraphs(String content) {
    // Check if content is in JSON format and parse it
    if (content.trim().startsWith('{') && content.trim().endsWith('}')) {
      try {
        // Sanitize the content before parsing
        String sanitized = content.replaceAll(RegExp(r'[\x00-\x1F]'), ' ');
        final Map<String, dynamic> jsonContent = jsonDecode(sanitized);
        if (jsonContent.containsKey('content')) {
          content = jsonContent['content'].toString();
        }
      } catch (e) {
        // If JSON parsing fails, use the original content
        AppLogger.e('Error parsing JSON content: $e');
        // Just use the content as is, without trying to parse JSON
      }
    }
    
    // Split by double newlines first (for explicit paragraphs)
    List<String> explicitParagraphs = content.split(RegExp(r'\n\s*\n'));
    
    if (explicitParagraphs.length > 1) {
      return explicitParagraphs.map((p) => p.trim()).toList();
    }
    
    // If no explicit paragraphs, try to split by sentences
    // This is a simple approach - split after periods followed by spaces
    List<String> sentences = content.split(RegExp(r'\. '));
    
    // Group sentences into paragraphs (3-4 sentences per paragraph)
    List<String> paragraphs = [];
    for (int i = 0; i < sentences.length; i += 3) {
      int end = i + 3;
      if (end > sentences.length) end = sentences.length;
      
      String paragraph = sentences.sublist(i, end).join('. ');
      // Add back the period if needed
      if (!paragraph.endsWith('.')) paragraph += '.';
      
      paragraphs.add(paragraph.trim());
    }
    
    return paragraphs;
  }
  
  // Build paragraphs with proper styling
  List<Widget> _buildParagraphs(List<String> paragraphs, BuildContext context) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < paragraphs.length; i++) {
      widgets.add(
        Text(
          paragraphs[i],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.8,
            letterSpacing: 0.4,
            fontFamily: 'Merriweather',
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.justify,
        ),
      );
      
      // Add spacing between paragraphs
      if (i < paragraphs.length - 1) {
        widgets.add(const SizedBox(height: 24));
      }
    }
    
    return widgets;
  }
  
  // Show save options dialog
  void _showSaveOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Save Story',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
                fontFamily: 'Merriweather',
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.copy, color: AppTheme.primaryColor),
              title: const Text('Copy to Clipboard'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.story.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Story copied to clipboard'))
                );
              },
            ),
            // Disabled options that require additional plugins
            Opacity(
              opacity: 0.5,
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
                title: const Text('Save as PDF'),
                subtitle: const Text('Not available in web version'),
                enabled: false,
                onTap: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
