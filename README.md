# AI Storyteller

An immersive, interactive storytelling app powered by AI. This Flutter application allows users to generate creative stories using OpenAI's GPT API and accompanying illustrations using DALL-E.

## Features

- **Custom Prompts**: Enter your own story ideas to generate unique narratives
- **Genre Selection**: Choose from various genres to influence the style of your story
- **AI-Generated Content**: Uses OpenAI's GPT API to create compelling narratives
- **AI-Generated Illustrations**: Uses OpenAI's DALL-E to create images that match your story
- **Interactive Reading Experience**: Navigate through stories with a user-friendly interface

## Screenshots

![image](https://github.com/user-attachments/assets/cc4f8c86-3d78-40fa-8fc8-79959c8f6146)

![image](https://github.com/user-attachments/assets/bac56446-e517-4357-9822-699ae05b7168)


## Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- OpenAI API key with access to both GPT-4 and DALL-E APIs

### Installation

1. Clone this repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Update the `.env` file with your OpenAI API key:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   ```
5. Run the app with `flutter run`

## Project Structure

```
lib/
├── main.dart           # App entry point
├── models/             # Data models
│   └── story.dart      # Story model with image handling support
├── screens/            # App screens
│   ├── home_screen.dart    # Home screen with prompt input
│   └── story_screen.dart   # Story display screen with image rendering
├── services/           # API services
│   └── openai_service.dart # OpenAI API integration (GPT & DALL-E)
├── utils/              # Utility classes
│   ├── app_theme.dart      # App theming
│   ├── env_loader.dart     # Environment variable loader
│   ├── logger.dart         # Structured logging utility
│   └── image_downloader.dart # Image downloading and caching utility
└── widgets/            # Reusable widgets
    └── genre_selector.dart # Genre selection widget
```

## How It Works

1. The user enters a story prompt and optionally selects a genre
2. The app sends the prompt to OpenAI's GPT API to generate a story as a single continuous narrative
3. The app then sends a derived prompt to DALL-E to generate an illustration for the story
4. The complete story with illustration is displayed in a clean, readable interface

## API Integration

This app uses OpenAI's APIs for content generation:
- **GPT-4**: For generating story text based on prompts
- **DALL-E 2**: For generating illustrations based on the story content

API calls are handled asynchronously with proper error handling and logging to ensure a smooth user experience.

## Dependencies

- `flutter_dotenv`: For secure API key management
- `http`: For making API requests
- `provider`: For state management
- `shared_preferences`: For local storage
- `path_provider`: For accessing device storage locations
- `dio`: For robust HTTP downloads
- `crypto`: For generating unique filenames
- `cached_network_image`: For loading and caching network images
- `flutter_markdown`: For rendering story text with markdown

## Future Enhancements

- Save stories for offline reading
- Share stories with others
- Text-to-speech narration
- More customization options for story generation
- Enhanced image generation options (style, aspect ratio, etc.)
- Multiple illustrations per story

