# Flashi architecture migration map

## Current boundaries

- State management uses `package:provider` with fourteen root
  `ChangeNotifierProvider` registrations. The development baseline does not
  contain Riverpod, so this presentation refactor preserves Provider behavior.
- Navigation uses direct `Navigator` and `MaterialPageRoute` calls.
- Persistence uses the existing Hive boxes opened in `main.dart`.
- API, ads, secure storage, permissions, import/export, and AI behavior remain
  compatibility boundaries during the presentation refactor.

## Target layout

```text
lib/
  app/                 bootstrap and responsive application shell
  core/
    design_system/     theme, spacing, radius, breakpoints, shared surfaces
    navigation/        presentation-only destinations and shell helpers
  features/
    onboarding/
    dashboard/
    chat/
    quiz/
    notes/
    history/
    favorites/
    reviewer/
    settings/
  shared/widgets/      feature-agnostic controls and states
  provider/            state compatibility boundary
  util/                integration compatibility boundary
```

## File migration map

| Current | Target |
| --- | --- |
| `home.dart` | `app/app_shell.dart` |
| `main/home_screen.dart` | `features/dashboard/presentation/dashboard_page.dart` |
| `main/chat_bot_screen.dart` | `features/chat/presentation/chat_page.dart` |
| `main/note_screen.dart` | `features/notes/presentation/notes_page.dart` |
| `main/history_screen.dart` | `features/history/presentation/history_page.dart` |
| `main/favorate_screen.dart` | `features/favorites/presentation/favorites_page.dart` |
| `main/settings_screen.dart` | `features/settings/presentation/settings_page.dart` |
| `onboarding screen/onboarding_screen.dart` | `features/onboarding/presentation/onboarding_page.dart` |

Misspelled public symbols such as `Favorate`, `toogleNavigation`, `wepage`, and
`ListOfMaxLength` move only with all call sites in a single atomic change.

## Consolidation targets

- Notes/history cards and editors share one visual composition.
- Quiz-set/card pages repeat search, sorting, empty state, and actions.
- Dialogs repeat headings, actions, padding, and shape.
- Reviewer pages repeat result dialogs and question framing.
- Pages repeat app bars, width constraints, banner offsets, and settings links.

## Compatibility rules

- Do not change Hive box names, keys, or stored map shapes.
- Do not change HTTP contracts, secure-storage keys, permission checks, model
  serialization, ad rewards, validation, or error mapping.
- Do not change provider public behavior, route results, or feature access.
