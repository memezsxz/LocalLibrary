# Local Library

A multi-platform Flutter e-reader for browsing, scraping, and reading digital stories. Connects to a self-hosted backend that scrapes story data from external sources.

> **Warning:** The app requires a running backend to function. Without it, all data fetching, scraping, and reading will fail.

## Features

- **Story Discovery:** Browse, search, and filter a library of stories with advanced filters (genre, language, tags, author)
- **Full-Featured Reader:** Paragraph-level e-reader with inline comments, adjustable typography, brightness, spacing, and orientation
- **Real-Time Scraping:** Scrape stories from URLs via Server-Sent Events with live progress visualization
- **Reading Progress:** Track position across chapters with timestamps and metrics
- **Comments System:** View paragraph-level and chapter-level comments with nested replies
- **Notifications:** In-app notification inbox with read/unread state
- **Multi-Window:** Desktop multi-window support (macOS, Windows)

## Platforms

| Platform | Status |
|----------|--------|
| macOS | Supported |
| Windows | Supported |
| Android | Supported |
| iOS | Supported |
| Web | Partial |

## Tech Stack

| Concern | Package |
|---------|---------|
| State Management | `flutter_bloc` (BLoC + Cubit) |
| HTTP Client | `dio` + `retrofit` |
| Real-Time Events | `flutter_client_sse` |
| Code Generation | `freezed`, `json_serializable` |
| Dependency Injection | `get_it` |
| UI | `flutter_html`, `carousel_slider`, `scrollable_positioned_list` |
| Media | `media_kit`, `video_player` |
| Environment | `flutter_dotenv` |

## Architecture

Clean architecture with feature-based modules:

```
lib/
├── core/
│   ├── api/          # Retrofit API clients
│   ├── theme/        # Material Design 3 theming
│   ├── secrets/      # Environment config
│   ├── common/       # Shared widgets
│   └── error/        # Exception/failure types
├── features/
│   ├── library/      # Dashboard, search, filtering
│   ├── story/        # Story detail, scraping
│   ├── part/         # Chapter reader, reading settings
│   ├── comments/     # Comment viewing
│   ├── notifications/
│   └── settings/
├── dependency_injection.dart
└── main.dart
```

**Navigation:** Custom stack-based `NavigationCubit` (no Go Router).  
**DI:** GetIt service locator with lazy singletons for API clients, factory instances for BLoCs.

## Setup

### Prerequisites

- Flutter SDK
- Running backend server (required, app is non-functional without it)

### Configuration

Create a `.env` file in the project root:

```env
BASE_URL=http://your-backend-host:5050
```

**Platform defaults if not set:**
- Android emulator: `http://10.0.2.2:5050`
- All others: `http://127.0.0.1:5050`

### Install & Run

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## API

The app communicates with a REST backend plus SSE streaming endpoints:

| Endpoint | Description |
|----------|-------------|
| `GET /stories` | List stories (paginated) |
| `GET /stories/{id}` | Story detail + parts + progress |
| `POST /stories/search_filter` | Advanced search |
| `GET /stories/{id}/parts/{partId}` | Chapter content + paragraphs |
| `GET /stories/{id}/progress` | Reading progress |
| `GET /app/scrape/story/stream` | Scrape story (SSE) |
| `GET /app/scrape/part/stream` | Scrape chapter (SSE) |
| `GET /app/scrape/comments/stream` | Scrape comments (SSE) |
| `GET /notifications` | Notification list |

## Key Data Models

- **Story:** title, description, genre, author, language, tags, media
- **Part:** chapter with paragraphs, votes, publication date
- **Paragraph:** atomic content unit (text/HTML/media) with comment count
- **StoryProgress:** current position, timestamps, duration metrics
- **ScrapeEvent:** real-time scraping event streamed from backend