import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../utils/logger.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _disposeAudioPlayer();
      _initAudioPlayer();
    }
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Set the audio source
      await _audioPlayer.setUrl(widget.audioUrl);
      
      // Get the duration
      _duration = _audioPlayer.duration ?? Duration.zero;
      
      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((playerState) {
        final isPlaying = playerState.playing;
        final processingState = playerState.processingState;
        
        if (processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
            _position = _duration;
          });
        } else if (processingState == ProcessingState.ready) {
          setState(() {
            _isLoading = false;
          });
        }
        
        if (mounted && _isPlaying != isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      });
      
      // Listen to position changes
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });
      
      // Listen to duration changes
      _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('Error initializing audio player: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _disposeAudioPlayer() {
    _audioPlayer.dispose();
  }

  @override
  void dispose() {
    _disposeAudioPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return const Center(
        child: Text(
          'Failed to load audio',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ProgressBar(
            progress: _position,
            total: _duration,
            buffered: _duration,
            onSeek: (duration) {
              _audioPlayer.seek(duration);
            },
            thumbColor: Theme.of(context).colorScheme.primary,
            progressBarColor: Theme.of(context).colorScheme.primary,
            baseBarColor: Colors.grey.shade300,
            bufferedBarColor: Colors.grey.shade500,
            timeLabelTextStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Playback controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () {
                final newPosition = _position - const Duration(seconds: 10);
                _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
              },
            ),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () {
                final newPosition = _position + const Duration(seconds: 10);
                _audioPlayer.seek(newPosition > _duration ? _duration : newPosition);
              },
            ),
          ],
        ),
      ],
    );
  }
}
