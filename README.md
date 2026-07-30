# Flashi - AI-Powered Flashcard Generator

Flashi is an advanced AI-powered tool designed to help you create and customize flashcards effortlessly. Enhance your learning experience with intuitive features, a variety of themes, and AI-generated flashcards. You can also generate flashcards from PDF or Docs files and interact with a chatbot for study assistance.

## Features
- AI-powered flashcard generation
- Create and personalize flashcards easily
- Generate flashcards from PDF or Docs files
- Multiple color themes, including Light and Dark modes
- Intuitive and user-friendly interface
- Customizable learning modes for various study techniques
- Integrated chatbot for interactive learning assistance

## Installation
To start using Flashi, follow these steps:
1. Clone this repository.
2. Install the required dependencies.
3. Copy `.env.example` to `.env` and fill in the environment configuration.
4. Run the application with:

```powershell
flutter run --dart-define-from-file=.env
```

Use the same configuration for release builds:

```powershell
flutter build apk --dart-define-from-file=.env
```

The `.env` file is ignored by Git and is not bundled as a Flutter asset. The
app reads `MISTRAL_API_KEY` from this file when built with
`--dart-define-from-file=.env`, unless a user key exists in platform secure
storage. Values passed through `dart-define` are compiled into the application
and can be recovered from an installed build, so use a restricted development
key here and keep production secrets behind a server-side API.

## License
This project is proprietary, and all rights are reserved by the author.

Unauthorized use, copying, modification, distribution, or display of this software or its source code is strictly prohibited without explicit written permission from the author.

Legal action will be taken against any unauthorized use, distribution, or modification of this software.

Copyright (c) 2025 . All rights reserved.

## Contact
For inquiries or permission requests, please contact [curibtech@gmail.com]

