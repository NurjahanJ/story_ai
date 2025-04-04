class Story {
  final String title;
  final String content;
  final String? imageUrl;
  final String? localImagePath;
  final String? imageBase64; // Base64-encoded image data

  Story({
    required this.title,
    required this.content,
    this.imageUrl,
    this.localImagePath,
    this.imageBase64,
  });
  
  /// Creates a copy of this Story with the given fields replaced with the new values
  Story copyWith({
    String? title,
    String? content,
    String? imageUrl,
    String? localImagePath,
    String? imageBase64,
  }) {
    return Story(
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    // Handle different possible JSON structures
    String title = 'Untitled Story';
    String content = '';
    String? imageUrl;
    String? localImagePath;
    String? imageBase64;
    
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
    
    return Story(
      title: title,
      content: content,
      imageUrl: imageUrl,
      localImagePath: localImagePath,
      imageBase64: imageBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (localImagePath != null) 'localImagePath': localImagePath,
      if (imageBase64 != null) 'imageBase64': imageBase64,
    };
  }
}

class Chapter {
  final String title;
  final String content;

  Chapter({
    required this.title,
    required this.content,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? 'Untitled Chapter',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}
