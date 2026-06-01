# Local Library

A self-hosted platform for scraping, storing, and reading digital stories. Built for personal use as a private reading library.

## What It Does

You point it at a story URL, it scrapes the content and stores it locally, and you read it through the app. No accounts, no subscriptions, no internet required after scraping.

## Components

- **[locallibrary/](locallibrary/README.md)** - Flutter client app (iOS, Android, macOS, Windows)
- Backend server - handles scraping, storage, and serves the API (separate repo)

## How It Works

1. Backend runs locally and exposes a REST + SSE API
2. Flutter app connects to the backend via local network or localhost
3. Paste a story URL into the app to scrape it
4. Read offline from that point on

## App Pages

**Dashboard** - Main library view. Browse all scraped stories, search by title or author, and filter by genre, language, or tags.

**Story** - Detail page for a single story. Shows metadata (cover, description, genre, author), list of chapters, and reading progress.

**Scrape** - Paste a story URL to import it. Shows a live log of the scraping process as chapters and content are pulled in.

**Reader** - Chapter reading view. Displays content paragraph by paragraph with inline reader comments. Supports font size, line spacing, brightness, and orientation controls.

**Comments** - Browse reader comments at the paragraph or chapter level, with nested replies.

**Notifications** - In-app notification feed for story and scrape updates.

**Settings** - App preferences including reading defaults and display options.

## Status

Active development. Core reading and scraping features are functional.