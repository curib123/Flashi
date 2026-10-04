import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/widget/components/study_generator_sheet.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeAllQuizSetList extends StatelessWidget {
  final String name;
  final ColorScheme colorScheme;

  const SeeAllQuizSetList({
    super.key,
    required this.name,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final sort = context.watch<SortProvider>();
    final sets = quiz.filteredQuizSets.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showStudyGeneratorSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          FlashiDesign.pagePadding,
          4,
          FlashiDesign.pagePadding,
          0,
        ),
        child: Column(
          children: [
            TextField(
              controller: quiz.searchController,
              onChanged: quiz.updateSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search study sets',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    sets.length == 1
                        ? '1 study set'
                        : sets.length.toString() + ' study sets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                DropdownButton<String>(
                  value: sort.dropdownValueSet,
                  underline: const SizedBox.shrink(),
                  items: sort.sortOptionsSet
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    sort.updateSortValueSet(value);
                    quiz.sortQuizSets(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sets.isEmpty
                  ? const Center(child: Text('No study sets yet.'))
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [ReusableQuizSetList(quizSets: sets)],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
