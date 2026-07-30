import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flashi/features/quiz/application/quiz_provider.dart';
import 'package:flashi/core/design_system/app_semantic_colors.dart';

class QuizImportExportService {
  Future<void> exportList(
      BuildContext context, Map<String, dynamic> sets) async {
    try {
      final fileName = '${_safeFileName(sets['name'])} (Flashi).json';
      final bytes = Uint8List.fromList(
        utf8.encode(jsonEncode(convertTimestampsToString(sets))),
      );
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export quiz set',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );
      if (!context.mounted) return;

      if (savedPath == null) {
        _showSnack(context, 'Export canceled.', _FeedbackKind.warning);
        return;
      }
      _showSnack(
          context, 'Quiz set exported successfully.', _FeedbackKind.success);
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, 'Export failed. Please choose another location.',
          _FeedbackKind.error);
      developer.log('Quiz export failed.', error: e);
    }
  }

  Future<void> importList(
      BuildContext context, QuizProvider quizProvider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import quiz set',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (!context.mounted) return;

      if (result != null) {
        final selectedFile = result.files.single;
        final bytes = selectedFile.bytes ??
            (selectedFile.path == null
                ? null
                : await File(selectedFile.path!).readAsBytes());
        if (bytes == null) {
          throw const FormatException('The selected file could not be opened.');
        }
        final decoded = jsonDecode(utf8.decode(bytes));
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('The file is not a Flashi quiz set.');
        }
        if (!context.mounted) return;
        final importedData = decoded;

        bool isDuplicate = quizProvider.quizSets
            .any((set) => set['name'] == importedData['name']);

        if (isDuplicate) {
          _showSnack(
              context, 'This quiz set already exists.', _FeedbackKind.warning);
        } else {
          Map<String, dynamic> sets = _convertTimestamps(importedData);
          quizProvider.addQuizSet(sets);
          _showSnack(context, 'Quiz set imported.', _FeedbackKind.success);
        }
      } else {
        _showSnack(context, 'Import canceled.', _FeedbackKind.warning);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, 'Import failed. Select a valid Flashi JSON file.',
          _FeedbackKind.error);
      developer.log('Quiz import failed.', error: e);
    }
  }

  static String _safeFileName(Object? value) {
    final name = (value?.toString().trim().isNotEmpty ?? false)
        ? value.toString().trim()
        : 'Quiz Set';
    return name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
  }

  static Map<String, dynamic> convertTimestampsToString(
      Map<String, dynamic> data) {
    Map<String, dynamic> converted = Map<String, dynamic>.from(data);
    if (converted.containsKey('timestamp') &&
        converted['timestamp'] is DateTime) {
      converted['timestamp'] =
          (converted['timestamp'] as DateTime).toIso8601String();
    }
    if (converted.containsKey('cards')) {
      for (var card in converted['cards']) {
        if (card.containsKey('timestamp') && card['timestamp'] is DateTime) {
          card['timestamp'] = (card['timestamp'] as DateTime).toIso8601String();
        }
      }
    }
    return converted;
  }

  static Map<String, dynamic> convertStringsToTimestamps(
      Map<String, dynamic> data) {
    Map<String, dynamic> converted = Map<String, dynamic>.from(data);
    if (converted.containsKey('timestamp') &&
        converted['timestamp'] is String) {
      converted['timestamp'] = DateTime.parse(converted['timestamp']);
    }
    if (converted.containsKey('cards')) {
      for (var card in converted['cards']) {
        if (card.containsKey('timestamp') && card['timestamp'] is String) {
          card['timestamp'] = DateTime.parse(card['timestamp']);
        }
      }
    }
    return converted;
  }

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    if (data.containsKey('timestamp')) {
      data['timestamp'] = DateTime.parse(data['timestamp']);
    }
    if (data.containsKey('cards')) {
      for (var card in data['cards']) {
        if (card.containsKey('timestamp')) {
          card['timestamp'] = DateTime.parse(card['timestamp']);
        }
      }
    }
    return data;
  }

  void _showSnack(
    BuildContext context,
    String message,
    _FeedbackKind kind,
  ) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;
    final (icon, background, foreground, label) = switch (kind) {
      _FeedbackKind.success => (
          Icons.check_circle_rounded,
          semantic.successContainer,
          semantic.onSuccessContainer,
          'Success',
        ),
      _FeedbackKind.warning => (
          Icons.warning_amber_rounded,
          semantic.warningContainer,
          semantic.onWarningContainer,
          'Warning',
        ),
      _FeedbackKind.error => (
          Icons.error_rounded,
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
          'Error',
        ),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: background,
        content: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: $message',
                style: TextStyle(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _FeedbackKind { success, warning, error }
