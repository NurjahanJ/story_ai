# AI Storyteller

An immersive, interactive storytelling app powered by AI. This Flutter application allows users to generate creative stories using OpenAI's GPT API.

## Features

- **Custom Prompts**: Enter your own story ideas to generate unique narratives
- **Genre Selection**: Choose from various genres to influence the style of your story
- **AI-Generated Content**: Uses OpenAI's GPT API to create compelling narratives
- **Interactive Reading Experience**: Navigate through chapters with a user-friendly interface

## Screenshots

*Screenshots will be added once the app is running*

## Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- OpenAI API key

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
│   └── story.dart      # Story model
├── screens/            # App screens
│   ├── home_screen.dart    # Home screen with prompt input
│   └── story_screen.dart   # Story display screen
├── services/           # API services
│   └── openai_service.dart # OpenAI API integration
├── utils/              # Utility classes
│   ├── app_theme.dart      # App theming
│   └── env_loader.dart     # Environment variable loader
└── widgets/            # Reusable widgets
    └── genre_selector.dart # Genre selection widget
```

## How It Works

1. The user enters a story prompt and optionally selects a genre
2. The app sends the prompt to OpenAI's GPT API to generate a story as a single continuous narrative
3. The complete story is displayed in a clean, readable interface

## API Integration

This app uses OpenAI's GPT API for generating story text based on prompts.

API calls are handled asynchronously with proper error handling to ensure a smooth user experience.

## Dependencies

- `flutter_dotenv`: For secure API key management
- `http`: For making API requests
- `provider`: For state management
- `shared_preferences`: For local storage

## Future Enhancements

- Save stories for offline reading
- Share stories with others
- Text-to-speech narration
- More customization options for story generation
- Add illustration capabilities

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- OpenAI for providing the APIs
- Flutter team for the amazing framework
