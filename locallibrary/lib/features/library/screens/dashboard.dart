import 'package:flutter/material.dart';

import '../../../core/datasource.dart';
import '../../../dependency_injection.dart';
import '../widgets/book_grid.dart';
import '../widgets/search_input_bar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SearchInputBar(),
        ),
        Expanded(
          child: BookGrid(
            fetch: (limit, offset) async {
              final stories = await sl<AppApiDataSource>()
                  .listStories(limit: limit, offset: offset);
              return stories.map((s) => s.storyId).toList();
            },
          ),
        ),
      ],
    );
  }
}