import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../utils/env_loader.dart';
import 'story_screen.dart';
import '../widgets/genre_selector.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? _selectedGenre;
  bool _isLoading = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  
  // List of available genres with explorer-themed descriptions
  final List<String> _genres = [
    'Fantasy',
    'Science Fiction',
    'Mystery',
    'Adventure',
    'Historical Fiction',
    'Folklore',
    'Mythology',
    'Expedition',
    'Wilderness',
    'Discovery',
  ];
  
  // Explorer-themed prompts for inspiration
  final List<String> _promptSuggestions = [
    'A hidden temple deep in the uncharted jungle...',
    'Discovering an ancient map leading to a forgotten civilization...',
    'A journey across treacherous mountains to find a legendary artifact...',
    'Explorers who stumble upon a mysterious island not on any map...',
    'An expedition to the depths of the ocean reveals an unexpected discovery...',
  ];

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  // Check if API key is set
  Future<void> _checkApiKey() async {
    if (!EnvLoader.isApiKeySet()) {
      setState(() {
        _errorMessage = 'OpenAI API key is not set. Please update the .env file with your API key.';
      });
    }
  }

  // Generate story based on prompt and selected genre
  Future<void> _generateStory() async {
    // Validate prompt
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt for your story')),
      );
      return;
    }
    
    // Check API key
    if (!EnvLoader.isApiKeySet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OpenAI API key is not set. Please update the .env file.')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final openAIService = OpenAIService();
      final story = await openAIService.generateStoryWithPrompt(
        _promptController.text,
        genre: _selectedGenre,
      );
      
      if (mounted) {
        // Navigate to story screen with generated story
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryScreen(story: story),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating story: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('STORY EXPLORER'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(204), // 0.8 opacity converted to alpha (0.8 * 255 = 204)
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack(
        children: [
          // Background image with parallax effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/explorer_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blurred overlay for readability
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              color: Colors.black.withAlpha(77), // 0.3 opacity converted to alpha (0.3 * 255 = 77)
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Main content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo - compass icon for explorer theme
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withAlpha(204), // 0.8 opacity converted to alpha (0.8 * 255 = 204)
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77), // 0.3 opacity converted to alpha (0.3 * 255 = 77)
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.explore,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App title and description with adventure styling
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withAlpha(217), // 0.85 opacity,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51), // 0.2 opacity,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary.withAlpha(77), // 0.3 opacity,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'EMBARK ON A STORY ADVENTURE',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Discover uncharted tales crafted by AI',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Error message if API key is not set
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error.withAlpha(26), // 0.1 opacity converted to alpha (0.1 * 255 = 26)
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.error),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, 
                                  color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (_errorMessage != null)
                          const SizedBox(height: 16),
                        
                        // Prompt input field with explorer styling
                        TextField(
                          controller: _promptController,
                          decoration: InputDecoration(
                            labelText: 'Chart Your Adventure',
                            hintText: _promptSuggestions[DateTime.now().second % _promptSuggestions.length],
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _promptController.clear(),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Genre selector with explorer theme
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withAlpha(217), // 0.85 opacity,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51), // 0.2 opacity,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary.withAlpha(77), // 0.3 opacity,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.map, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'CHOOSE YOUR PATH',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GenreSelector(
                          genres: _genres,
                          selectedGenre: _selectedGenre,
                          onGenreSelected: (genre) {
                            setState(() {
                              _selectedGenre = genre;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Generate button with explorer styling
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withAlpha(102), // 0.4 opacity converted to alpha (0.4 * 255 = 102)
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateStory,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('CHARTING YOUR ADVENTURE...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_stories, size: 24, color: Theme.of(context).colorScheme.onPrimary),
                                const SizedBox(width: 12),
                                const Text('EMBARK ON ADVENTURE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Note about API usage with explorer styling
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withAlpha(179), // 0.7 opacity converted to alpha (0.7 * 255 = 179)
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary.withAlpha(77), // 0.3 opacity,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, 
                              size: 16, 
                              color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This expedition uses OpenAI\'s GPT API to generate content. You will need to provide your own API key in the .env file.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
