import 'package:anymex/models/Offline/Hive/episode.dart';
import 'package:anymex/controllers/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpisodeChunkSelector extends StatelessWidget {
  final RxInt selectedChunkIndex;
  final ValueChanged<int> onChunkSelected;
  final List<List<Episode>> chunks;
  
  const EpisodeChunkSelector({
    super.key,
    required this.selectedChunkIndex,
    required this.onChunkSelected,
    required this.chunks,
  });
  
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<Settings>();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          chunks.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
              child: Focus(
                canRequestFocus: true,
                skipTraversal: false,
                // Auto-focus selected chunk on TV
                autofocus: settings.isTV.value && selectedChunkIndex.value == index,
                child: ChoiceChip(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.4),
                  showCheckmark: false,
                  label: Text(
                    index == 0
                        ? "All"
                        : '${chunks[index].first.number} - ${chunks[index].last.number}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: selectedChunkIndex.value == index,
                  onSelected: (bool selected) {
                    if (selected) {
                      selectedChunkIndex.value = index;
                      onChunkSelected(index);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
