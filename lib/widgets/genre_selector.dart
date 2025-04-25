import 'package:flutter/material.dart';

class GenreSelector extends StatelessWidget {
  final List<String> genres;
  final String? selectedGenre;
  final Function(String?) onGenreSelected;

  const GenreSelector({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  // Map of genres to their explorer-themed descriptions
  static const Map<String, Map<String, dynamic>> _genreDetails = {
    'Fantasy': {
      'icon': Icons.auto_awesome,
      'color': Color(0xFF7E57C2), // Purple
    },
    'Science Fiction': {
      'icon': Icons.rocket_launch,
      'color': Color(0xFF42A5F5), // Blue
    },
    'Mystery': {
      'icon': Icons.search,
      'color': Color(0xFF5C6BC0), // Indigo
    },
    'Adventure': {
      'icon': Icons.terrain,
      'color': Color(0xFF66BB6A), // Green
    },
    'Historical Fiction': {
      'icon': Icons.history_edu,
      'color': Color(0xFFFFB74D), // Orange
    },
    'Folklore': {
      'icon': Icons.menu_book,
      'color': Color(0xFFFF8A65), // Deep Orange
    },
    'Mythology': {
      'icon': Icons.bolt,
      'color': Color(0xFFFFD54F), // Amber
    },
    'Expedition': {
      'icon': Icons.hiking,
      'color': Color(0xFF8D6E63), // Brown
    },
    'Wilderness': {
      'icon': Icons.forest,
      'color': Color(0xFF43A047), // Green
    },
    'Discovery': {
      'icon': Icons.explore,
      'color': Color(0xFF26A69A), // Teal
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            // "None" option with explorer styling
            _buildGenreChip(
              context: context,
              label: 'Any Path',
              icon: Icons.all_inclusive,
              color: Colors.grey.shade700,
              isSelected: selectedGenre == null,
              onSelected: (selected) {
                if (selected) {
                  onGenreSelected(null);
                }
              },
            ),
            // Genre options with explorer styling
            ...genres.map((genre) {
              final details = _genreDetails[genre] ?? {
                'icon': Icons.category,
                'color': Theme.of(context).colorScheme.secondary,
              };
              
              return _buildGenreChip(
                context: context,
                label: genre,
                icon: details['icon'] as IconData,
                color: details['color'] as Color,
                isSelected: selectedGenre == genre,
                onSelected: (selected) {
                  if (selected) {
                    onGenreSelected(genre);
                  }
                },
              );
            }),
          ],
        ),
      ],
    );
  }
  
  // Custom genre chip with explorer styling
  Widget _buildGenreChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: color,
      elevation: isSelected ? 4 : 1,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : color.withOpacity(0.5),
          width: 1,
        ),
      ),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
