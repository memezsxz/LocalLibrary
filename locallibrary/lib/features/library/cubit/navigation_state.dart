import 'package:flutter/material.dart';
import 'package:locallibrary/features/part/screens/part_screen.dart';
import 'package:locallibrary/features/settings/screens/settings.dart';
import 'package:locallibrary/features/story/screens/scrape_story_view_screen.dart';
import 'package:locallibrary/features/story/screens/story_screen.dart';

import '../../notifications/screens/notifications.dart';
import '../../story/models/dto/scrape_story_res.dart';
import '../screens/dashboard.dart';
import '../screens/library.dart';

@immutable
sealed class NavigationState {
  Widget build();
}

final class NavigationDashboardState extends NavigationState {
  @override
  Widget build() => Dashboard();
}

final class NavigationLibraryState extends NavigationState {
  @override
  Widget build() => Library();
}

final class NavigationNotificationsState extends NavigationState {
  @override
  Widget build() => Notifications();
}

final class NavigationSettingsState extends NavigationState {
  @override
  Widget build() => Settings();
}

final class NavigationStoryState extends NavigationState {
  final int storyId;

  NavigationStoryState({required this.storyId});

  @override
  Widget build() => StoryScreen(key: ValueKey(storyId), storyId: storyId);
}

final class NavigationScrapeStoryState extends NavigationState {
  final int storyId;
  final ScrapeStoryRes scrapeRes;

  NavigationScrapeStoryState({required this.storyId, required this.scrapeRes});

  @override
  Widget build() => ScrapeStoryViewScreen(
    key: ValueKey('scrape_$storyId'),
    storyId: storyId,
    scrapeRes: scrapeRes,
  );
}

final class NavigationPartState extends NavigationState {
  final int storyId;
  final int partId;
  final int? targetParagraphId;
  final int? targetCommentId;

  NavigationPartState({
    required this.storyId,
    required this.partId,
    this.targetParagraphId,
    this.targetCommentId,
  });

  @override
  Widget build() => PartScreen(
    key: ValueKey('part_${storyId}_$partId'),
    storyId: storyId,
    partId: partId,
    targetParagraphId: targetParagraphId,
    targetCommentId: targetCommentId,
  );
}