class Story {
  final String title;
  final String content;

  Story({
    required this.title,
    required this.content,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    // Handle different possible JSON structures
    String title = 'Untitled Story';
    String content = '';
    
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
    
    return Story(
      title: title,
      content: content,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
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
