import 'package:flashi/core/design_system/app_motion.dart';
import 'package:flashi/core/design_system/app_radii.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.colorScheme,
    required this.hintText,
    required this.onChanged,
    required this.controller,
    this.prominent = false,
    super.key,
  });

  final ColorScheme colorScheme;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final TextEditingController controller;
  final bool prominent;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final FocusNode _focusNode = FocusNode();

  bool get _hasText => widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_refresh)
      ..dispose();
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colorScheme;
    final focused = _focusNode.hasFocus;
    final height = widget.prominent ? 64.0 : 54.0;

    return Semantics(
      textField: true,
      label: widget.hintText,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        height: height,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: AppRadii.large,
          border: Border.all(
            color: focused ? colors.primary : colors.outlineVariant,
            width: focused ? 1.5 : 1,
          ),
          boxShadow: widget.prominent && !focused
              ? [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: height - (AppSpacing.md),
              height: height - (AppSpacing.md),
              decoration: BoxDecoration(
                color:
                    focused ? colors.primary : colors.surfaceContainerHighest,
                borderRadius: AppRadii.medium,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 22,
                color: focused ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyLarge,
                cursorColor: colors.primary,
                decoration: InputDecoration.collapsed(
                  hintText: widget.hintText,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: AppMotion.fast,
              child: _hasText
                  ? IconButton(
                      key: const ValueKey('clear-search'),
                      tooltip: 'Clear search',
                      onPressed: _clear,
                      icon: const Icon(Icons.close_rounded, size: 20),
                    )
                  : const SizedBox(
                      key: ValueKey('empty-search-action'),
                      width: AppSpacing.xs,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
