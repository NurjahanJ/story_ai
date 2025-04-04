import 'package:flutter_tts/flutter_tts.dart';
import 'logger.dart';

/// A service for text-to-speech functionality
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  
  SpeechService._internal();
  
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  double _volume = 1.0;
  double _pitch = 1.0;
  double _rate = 0.5; // Slightly slower rate for better clarity
  String _currentLanguage = 'en-US';
  
  /// Initialize the TTS engine
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Set default values
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_rate);
      await _flutterTts.setLanguage(_currentLanguage);
      
      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        AppLogger.i('TTS: Finished speaking');
      });
      
      // Set error handler
      _flutterTts.setErrorHandler((error) {
        _isSpeaking = false;
        AppLogger.e('TTS Error: $error');
      });
      
      _isInitialized = true;
      AppLogger.i('TTS: Initialized successfully');
    } catch (e) {
      AppLogger.e('TTS: Failed to initialize: $e');
      _isInitialized = false;
    }
  }
  
  /// Speak the given text
  Future<bool> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isSpeaking) {
      await stop();
    }
    
    try {
      AppLogger.i('TTS: Speaking text of length ${text.length}');
      _isSpeaking = true;
      await _flutterTts.speak(text);
      return true;
    } catch (e) {
      AppLogger.e('TTS: Error speaking: $e');
      _isSpeaking = false;
      return false;
    }
  }
  
  /// Stop speaking
  Future<bool> stop() async {
    if (!_isInitialized) return false;
    
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      AppLogger.i('TTS: Stopped speaking');
      return true;
    } catch (e) {
      AppLogger.e('TTS: Error stopping: $e');
      return false;
    }
  }
  
  /// Pause speaking
  Future<bool> pause() async {
    if (!_isInitialized || !_isSpeaking) return false;
    
    try {
      var result = await _flutterTts.pause();
      AppLogger.i('TTS: Paused speaking');
      return result == 1;
    } catch (e) {
      AppLogger.e('TTS: Error pausing: $e');
      return false;
    }
  }
  
  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) return;
    
    try {
      await _flutterTts.setVolume(volume);
      _volume = volume;
      AppLogger.i('TTS: Volume set to $_volume');
    } catch (e) {
      AppLogger.e('TTS: Error setting volume: $e');
    }
  }
  
  /// Set the pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (pitch < 0.5 || pitch > 2.0) return;
    
    try {
      await _flutterTts.setPitch(pitch);
      _pitch = pitch;
      AppLogger.i('TTS: Pitch set to $_pitch');
    } catch (e) {
      AppLogger.e('TTS: Error setting pitch: $e');
    }
  }
  
  /// Set the speech rate (0.0 to 1.0)
  Future<void> setRate(double rate) async {
    if (rate < 0.0 || rate > 1.0) return;
    
    try {
      await _flutterTts.setSpeechRate(rate);
      _rate = rate;
      AppLogger.i('TTS: Rate set to $_rate');
    } catch (e) {
      AppLogger.e('TTS: Error setting rate: $e');
    }
  }
  
  /// Set the language
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      _currentLanguage = language;
      AppLogger.i('TTS: Language set to $_currentLanguage');
    } catch (e) {
      AppLogger.e('TTS: Error setting language: $e');
    }
  }
  
  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.cast<String>();
    } catch (e) {
      AppLogger.e('TTS: Error getting languages: $e');
      return [];
    }
  }
  
  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;
  
  /// Get current volume
  double get volume => _volume;
  
  /// Get current pitch
  double get pitch => _pitch;
  
  /// Get current rate
  double get rate => _rate;
  
  /// Get current language
  String get language => _currentLanguage;
  
  /// Dispose the TTS engine
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    try {
      if (_isSpeaking) {
        await stop();
      }
      
      await _flutterTts.stop();
      _isInitialized = false;
      AppLogger.i('TTS: Disposed');
    } catch (e) {
      AppLogger.e('TTS: Error disposing: $e');
    }
  }
}
