import 'package:flashi/app/app_shell.dart';
import 'package:flashi/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flashi/features/history/presentation/pages/history_editor_page.dart';
import 'package:flashi/features/history/presentation/pages/history_page.dart';
import 'package:flashi/features/notes/presentation/pages/note_editor_page.dart';
import 'package:flashi/features/quiz/presentation/pages/quiz_cards_page.dart';
import 'package:flashi/features/quiz/presentation/pages/quiz_sets_page.dart';
import 'package:flashi/features/reviewer/presentation/pages/reviewer_page.dart';
import 'package:flashi/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flashi/core/design_system/app_motion.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const favorites = '/favorites';
  static const history = '/history';
  static const historyEditor = '/history/editor';
  static const noteEditor = '/notes/editor';
  static const quizSets = '/quiz-sets';
  static const quizCards = '/quiz-sets/cards';
  static const reviewer = '/reviewer';
  static const settings = '/settings';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => _page(settings, const AppShell()),
      AppRoutes.favorites => _page(settings, const FavoritesPage()),
      AppRoutes.history => _page(settings, const HistoryPage()),
      AppRoutes.historyEditor => _page(
          settings,
          HistoryEditorPage.fromArguments(
            _arguments<HistoryEditorArguments>(settings),
          ),
        ),
      AppRoutes.noteEditor => _page(
          settings,
          NoteEditorPage.fromArguments(
            _arguments<NoteEditorArguments>(settings),
          ),
        ),
      AppRoutes.quizSets => _page(
          settings,
          Builder(
            builder: (context) => QuizSetsPage(
              name: _arguments<String>(settings),
              colorScheme: Theme.of(context).colorScheme,
            ),
          ),
        ),
      AppRoutes.quizCards => _page(
          settings,
          Builder(
            builder: (context) {
              final arguments = _arguments<QuizCardsArguments>(settings);
              return QuizCardsPage(
                name: arguments.name,
                colorScheme: Theme.of(context).colorScheme,
                card: arguments.card,
                index: arguments.index,
                cards: arguments.cards,
              );
            },
          ),
        ),
      AppRoutes.reviewer => _page(
          settings,
          ReviewerPage.fromArguments(
            _arguments<ReviewerArguments>(settings),
          ),
        ),
      AppRoutes.settings => _page(settings, const SettingsPage()),
      _ => _unknownRoute(settings),
    };
  }

  static PageRouteBuilder<dynamic> _page(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: AppMotion.standard,
      reverseTransitionDuration: AppMotion.fast,
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.entranceCurve,
          reverseCurve: AppMotion.exitCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.025, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static T _arguments<T>(RouteSettings settings) {
    final arguments = settings.arguments;
    if (arguments is T) return arguments;
    throw FlutterError(
      'Route ${settings.name} expected arguments of type $T, '
      'but received ${arguments.runtimeType}.',
    );
  }

  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return _page(
      settings,
      Scaffold(
        body: Center(
          child: Text('Page not found: ${settings.name ?? 'unknown'}'),
        ),
      ),
    );
  }
}

class NoteEditorArguments {
  const NoteEditorArguments({
    required this.isCreate,
    required this.title,
    required this.isRead,
    required this.date,
  });

  final bool isCreate;
  final String title;
  final bool isRead;
  final DateTime date;
}

class HistoryEditorArguments {
  const HistoryEditorArguments({
    required this.isCreate,
    required this.title,
    required this.isRead,
    required this.date,
  });

  final bool isCreate;
  final String title;
  final bool isRead;
  final DateTime date;
}

class QuizCardsArguments {
  const QuizCardsArguments({
    required this.name,
    required this.card,
    required this.index,
    required this.cards,
  });

  final String name;
  final Map<String, dynamic> card;
  final int index;
  final List<dynamic> cards;
}

class ReviewerArguments {
  const ReviewerArguments({
    required this.reviewer,
    required this.cards,
    required this.setname,
  });

  final String reviewer;
  final List<dynamic> cards;
  final String setname;
}
