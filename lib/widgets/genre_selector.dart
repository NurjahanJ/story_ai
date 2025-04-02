import 'package:flutter/material.dart';

class GenreSelector extends StatelessWidget {
  final List<String> genres;
  final String? selectedGenre;
  final Function(String?) onGenreSelected;

  const GenreSelector({
    Key? key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Genre (Optional)',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            // "None" option
            ChoiceChip(
              label: const Text('None'),
              selected: selectedGenre == null,
              onSelected: (selected) {
                if (selected) {
                  onGenreSelected(null);
                }
              },
            ),
            // Genre options
            ...genres.map((genre) {
              return ChoiceChip(
                label: Text(genre),
                selected: selectedGenre == genre,
                onSelected: (selected) {
                  if (selected) {
                    onGenreSelected(genre);
                  }
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}
