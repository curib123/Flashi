import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Icon(icon, size: 28, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget noSetWidget(BuildContext context) => const AppEmptyState(
      icon: Icons.layers_outlined,
      title: 'No quiz sets yet',
      description: 'Create or import a quiz set to start learning.',
    );

Widget noNotesWidget(BuildContext context) => const AppEmptyState(
      icon: Icons.note_alt_outlined,
      title: 'No notes yet',
      description: 'Capture your first idea and keep it close.',
    );

Widget noHistoryWidget(BuildContext context) => const AppEmptyState(
      icon: Icons.history,
      title: 'No generation history',
      description: 'Content generated with the assistant will appear here.',
    );

Widget noCardWidget(BuildContext context) => const AppEmptyState(
      icon: Icons.style_outlined,
      title: 'No cards yet',
      description: 'Add the first card to begin building this quiz set.',
    );

Widget noTaskWidget(BuildContext context) => const AppEmptyState(
      icon: Icons.task_alt_outlined,
      title: 'No tasks yet',
      description: 'New tasks will appear here when you add them.',
    );
