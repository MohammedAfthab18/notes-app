<div align="center">

# NotesHub

### Offline study notes with an Apple Notes x Notion inspired reading experience

![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-Only-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Offline](https://img.shields.io/badge/Offline_First-Hive-111111?style=for-the-badge)

NotesHub is a premium Android-only Flutter app for organizing programming notes, theory notes, chapters, snippets, imports, favorites, and reading sessions entirely offline.

</div>

---

## Preview

NotesHub is designed around a quiet, Apple-inspired interface:

| Area | Experience |
| --- | --- |
| Home | Glassmorphism subject cards, search, sorting, grid/list toggle, context menus |
| Subject | Chapter cards with previews, reading time, pinning, favorites, import actions |
| Reader | Large typography, reading progress, table of contents, themes, font scaling |
| Editor | Manual writing, autosave, live preview, Markdown and smart formatting |
| Search | Instant global search across subjects, chapters, and note content |
| Settings | Apple-style grouped settings, backup, restore, appearance controls |

Fresh installs start empty. If no subjects exist, the app shows a clear empty state and asks the user to create the first subject.

---

## Features

### Offline Notes System

- Fully offline Android app
- No backend, Firebase, authentication, or cloud dependency
- Hive local database for subjects and chapters
- Manual Hive adapters, no code generation required
- Clean repositories for CRUD operations

### Subject Management

- Create, rename, delete, and reorder subjects
- Search subjects instantly
- Sort by custom order, A-Z, or updated date
- Toggle between grid and list layouts
- Cupertino context menus for quick actions

### Chapter Management

- Create chapters manually
- Import `.txt` and `.docx` files
- Rename, edit, delete, pin, and favorite chapters
- Sort by updated date or name
- Chapter previews, reading time, and last edited metadata

### Smart Formatter

The formatter improves pasted or imported study material automatically:

- Detects headings and large section titles
- Supports Markdown headings, lists, quotes, tables, links, and inline code
- Detects code blocks for C, Java, Python, JavaScript, SQL, HTML, CSS, JSON, Dart, and related snippets
- Renders syntax-highlighted code blocks with language labels and copy buttons
- Builds a table of contents from headings

### Reader Experience

- Comfortable long-form reading layout
- Font size controls
- Reader width controls
- Light, sepia, dark, and AMOLED reader modes
- Reading progress indicator
- Search inside note
- Bookmark/resume scroll position
- Word count and reading time estimation

### Productivity

- Global search across all local content
- Dedicated favorites support
- Recent notes
- Pinned notes
- Statistics dashboard
- JSON and TXT backup export
- JSON restore entry point

---

## Tech Stack

| Purpose | Package |
| --- | --- |
| UI | Flutter Cupertino |
| State management | Riverpod 3 `NotifierProvider` and `Provider` |
| Navigation | GoRouter |
| Local database | Hive, Hive Flutter |
| File import | file_picker |
| DOCX extraction | docx_to_text |
| Markdown rendering | flutter_markdown |
| Syntax highlighting | flutter_highlight |
| Fonts | google_fonts |
| Links | url_launcher |
| IDs | uuid |

---

## Architecture

```text
lib/
  core/
    constants/
    theme/
    utils/

  features/
    home/
      models/
      providers/
      views/
      widgets/

    subjects/
      providers/
      views/
      widgets/

    notes/
      models/
      providers/
      views/
      widgets/

    search/
      views/

    settings/
      views/

    statistics/
      views/

  services/
    backup_service.dart
    file_import_service.dart
    hive_service.dart
    repositories.dart
    router.dart

  main.dart
```

The codebase is organized by feature. Shared platform concerns such as persistence, routing, importing, backup, utilities, and theming live outside feature folders.

---

## Data Models

### Subject

```dart
class Subject {
  String id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  int position;
  int iconIndex;
}
```

### Chapter

```dart
class Chapter {
  String id;
  String subjectId;
  String title;
  String content;
  bool favorite;
  bool pinned;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastOpenedAt;
  double bookmarkOffset;
}
```

---

## Getting Started

### Requirements

- Flutter stable `3.41+`
- Dart `3.11+`
- Android SDK
- Android emulator or physical Android device

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Analyze

```bash
flutter analyze
```

### Test

```bash
flutter test
```

---

## Android Only

This project is intentionally configured for Android only.

```bash
flutter create --platforms=android .
```

No iOS, web, desktop, Firebase, or backend setup is required.

---

## Persistence

Hive is initialized in:

```text
lib/services/hive_service.dart
```

Opened boxes:

- `subjects`
- `chapters`
- `settings`

The app does not seed mock subjects. Empty storage produces an empty state in the UI.

---

## Design System

NotesHub uses a Cupertino-first interface:

- `CupertinoPageScaffold`
- `CupertinoNavigationBar`
- `CupertinoButton`
- `CupertinoContextMenu`
- `CupertinoActionSheet`
- `CupertinoSlidingSegmentedControl`
- Frosted glass cards
- Rounded corners
- Soft shadows
- Smooth transitions
- Light and dark appearance support

Material widgets are avoided unless Flutter requires them for package compatibility.

---

## Verification Status

Current project checks:

```text
flutter analyze
No issues found

flutter test
All tests passed
```

---

## Roadmap Ideas

- Full JSON restore for original subject and chapter IDs
- In-reader collapsible heading sections
- Export backup through Android share sheet
- Richer formula rendering
- Image attachment storage instead of remote image previews only
- Optional encrypted local vault

---

## License

This project is private by default. Add a license before publishing or distributing.
