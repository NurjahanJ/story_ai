import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../utils/env_loader.dart';
import 'story_screen.dart';
import '../widgets/genre_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? _selectedGenre;
  bool _isLoading = false;
  String? _errorMessage;
  
  // List of available genres
  final List<String> _genres = [
    'Fantasy',
    'Science Fiction',
    'Mystery',
    'Romance',
    'Horror',
    'Adventure',
    'Historical Fiction',
    'Thriller',
    'Comedy',
    'Drama',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Storyteller'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo or icon
              const Icon(
                Icons.auto_stories,
                size: 80,
                color: Colors.deepPurple,
              ),
              
              const SizedBox(height: 16),
              
              // App title and description
              Text(
                'AI Storyteller',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Create immersive stories with AI',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Error message if API key is not set
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              if (_errorMessage != null)
                const SizedBox(height: 16),
              
              // Prompt input field
              TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Enter your story prompt',
                  hintText: 'e.g., A journey to a hidden underwater city',
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              
              const SizedBox(height: 16),
              
              // Genre selector
              GenreSelector(
                genres: _genres,
                selectedGenre: _selectedGenre,
                onGenreSelected: (genre) {
                  setState(() {
                    _selectedGenre = genre;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Generate button
              ElevatedButton(
                onPressed: _isLoading ? null : _generateStory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Creating your story...'),
                        ],
                      )
                    : const Text('Generate Story'),
              ),
              
              const SizedBox(height: 16),
              
              // Note about API usage
              const Text(
                'Note: This app uses OpenAI\'s GPT API to generate content. '
                'You will need to provide your own API key in the .env file.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
