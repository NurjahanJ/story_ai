class Story {
  final String title;
  final String content;
  final String? imageUrl;
  final String? localImagePath;
  final String? imageBase64; // Base64-encoded image data
  final String? audioUrl; // URL to the Play.ht generated narration
  final NarrationStatus narrationStatus; // Status of narration generation

  Story({
    required this.title,
    required this.content,
    this.imageUrl,
    this.localImagePath,
    this.imageBase64,
    this.audioUrl,
    this.narrationStatus = NarrationStatus.none,
  });
  
  /// Creates a copy of this Story with the given fields replaced with the new values
  Story copyWith({
    String? title,
    String? content,
    String? imageUrl,
    String? localImagePath,
    String? imageBase64,
    String? audioUrl,
    NarrationStatus? narrationStatus,
  }) {
    return Story(
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      imageBase64: imageBase64 ?? this.imageBase64,
      audioUrl: audioUrl ?? this.audioUrl,
      narrationStatus: narrationStatus ?? this.narrationStatus,
    );
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    // Handle different possible JSON structures
    String title = 'Untitled Story';
    String content = '';
    String? imageUrl;
    String? localImagePath;
    String? imageBase64;
    String? audioUrl;
    NarrationStatus narrationStatus = NarrationStatus.none;
    
    // Try to get title
    if (json.containsKey('title')) {
      title = json['title'] ?? 'Untitled Story';
    }
    
    // Try to get content
    if (json.containsKey('content')) {
      content = json['content'] ?? '';
    } else if (json.containsKey('text')) {
      // Some models might return 'text' instead of 'content'
      content = json['text'] ?? '';
    } else if (json.containsKey('story')) {
      // Some models might return 'story' instead of 'content'
      content = json['story'] ?? '';
    }
    
    // Try to get imageUrl if available
    if (json.containsKey('imageUrl')) {
      imageUrl = json['imageUrl'];
    }
    
    // Try to get localImagePath if available
    if (json.containsKey('localImagePath')) {
      localImagePath = json['localImagePath'];
    }
    
    // Try to get imageBase64 if available
    if (json.containsKey('imageBase64')) {
      imageBase64 = json['imageBase64'];
    }
    
    // Try to get audioUrl if available
    if (json.containsKey('audioUrl')) {
      audioUrl = json['audioUrl'];
    }
    
    // Try to get narrationStatus if available
    if (json.containsKey('narrationStatus')) {
      narrationStatus = _parseNarrationStatus(json['narrationStatus']);
    }
    
    return Story(
      title: title,
      content: content,
      imageUrl: imageUrl,
      localImagePath: localImagePath,
      imageBase64: imageBase64,
      audioUrl: audioUrl,
      narrationStatus: narrationStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (localImagePath != null) 'localImagePath': localImagePath,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      if (audioUrl != null) 'audioUrl': audioUrl,
      'narrationStatus': narrationStatus.toString(),
    };
  }
}

/// Status of narration generation
enum NarrationStatus {
  none,       // No narration has been requested
  generating, // Narration is being generated
  ready,      // Narration is ready to play
  failed      // Narration generation failed
}

/// Parse narration status from string
NarrationStatus _parseNarrationStatus(String? status) {
  if (status == null) return NarrationStatus.none;
  
  switch (status) {
    case 'NarrationStatus.generating':
      return NarrationStatus.generating;
    case 'NarrationStatus.ready':
      return NarrationStatus.ready;
    case 'NarrationStatus.failed':
      return NarrationStatus.failed;
    case 'NarrationStatus.none':
    default:
      return NarrationStatus.none;
  }
}
