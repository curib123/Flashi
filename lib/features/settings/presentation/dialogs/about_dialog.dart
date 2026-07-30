import 'package:flashi/core/updates/application/app_update_provider.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showAppAboutDialog(BuildContext context) {
  final updates = context.read<AppUpdateProvider>();
  showAppDialog<void>(
    context: context,
    builder: (context) => AppDialog(
      icon: Icons.auto_awesome_rounded,
      title: 'Flashi',
      description: 'Quiz maker and learning companion',
      body: Column(
        children: [
          _AboutItem(
            icon: Icons.rocket_launch_outlined,
            label: 'Version',
            value: updates.currentVersion.isEmpty
                ? 'Unknown'
                : updates.currentVersion,
          ),
          const _AboutItem(
            icon: Icons.code_outlined,
            label: 'Developer',
            value: 'Curib Tech',
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _AboutItem extends StatelessWidget {
  const _AboutItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
