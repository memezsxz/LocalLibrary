import 'package:flutter/material.dart';

import '../../../core/api/library_api_client.dart';
import '../../../dependency_injection.dart';
import '../../story/models/domain/genre_model.dart';
import '../../story/models/domain/tag_model.dart';
import '../cubit/search_state.dart';
import 'advance_search_section.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

void openAdvancedSearchDialog({
  required BuildContext context,
  AdvancedSearchParams? initial,
  required ValueChanged<AdvancedSearchParams> onApply,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  if (isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: AdvancedSearchModal(
            initial: initial,
            onApply: onApply,
            scrollController: scrollController,
            isSheet: true,
          ),
        ),
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
            minHeight: MediaQuery.of(context).size.height * 0.7,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: AdvancedSearchModal(initial: initial, onApply: onApply),
        ),
      ),
    );
  }
}

// ─── Modal ────────────────────────────────────────────────────────────────────

class AdvancedSearchModal extends StatefulWidget {
  const AdvancedSearchModal({
    super.key,
    this.initial,
    required this.onApply,
    this.scrollController,
    this.isSheet = false,
  });

  final AdvancedSearchParams? initial;
  final ValueChanged<AdvancedSearchParams> onApply;
  final ScrollController? scrollController;
  final bool isSheet;

  @override
  State<AdvancedSearchModal> createState() => _AdvancedSearchModalState();
}

class _AdvancedSearchModalState extends State<AdvancedSearchModal> {
  late Set<String> _selectedLanguages;
  late Set<int> _selectedGenreIds;
  late Set<int> _selectedTagIds;
  String? _orderBy;
  late Set<SearchInclude> _include;

  List<String> _allLanguages = [];
  List<Tag> _allTags = [];
  List<Genre> _allGenres = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _selectedLanguages = Set.from(p?.languages ?? {});
    _selectedGenreIds = Set.from(p?.genreIds ?? {});
    _selectedTagIds = Set.from(p?.tagIds ?? {});
    _orderBy = p?.orderBy;
    _include = Set.from(p?.include ?? {SearchInclude.stories});
    _loadData();
  }

  Future<void> _loadData() async {
    final ds = sl<LibraryApiClient>();
    final results = await Future.wait([
      ds.listAllLanguages(),
      ds.listAllGenres(),
      ds.listAllTags(),
    ]);
    if (mounted) {
      setState(() {
        _allLanguages = results[0] as List<String>;
        _allGenres = results[1] as List<Genre>;
        _allTags = results[2] as List<Tag>;
        _loading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedLanguages.clear();
      _selectedGenreIds.clear();
      _selectedTagIds.clear();
      _orderBy = null;
      _include = {SearchInclude.stories};
    });
  }

  void _apply() {
    widget.onApply(
      AdvancedSearchParams(
        languages: Set.from(_selectedLanguages),
        genreIds: Set.from(_selectedGenreIds),
        tagIds: Set.from(_selectedTagIds),
        orderBy: _orderBy,
        include: Set.from(_include),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final languageItems = _allLanguages.map((l) => (id: l, label: l)).toList();
    final genreItems = _allGenres
        .map((g) => (id: g.genreId.toString(), label: g.name))
        .toList();
    final tagItems = _allTags
        .map((t) => (id: t.tagId.toString(), label: t.name))
        .toList();

    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSheet)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          const AdvancedSearchHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              children: [
                FilterSection(
                  title: 'Languages',
                  icon: Icons.language,
                  items: languageItems,
                  selectedIds: _selectedLanguages,
                  isLoading: _loading,
                  onToggle: (id) => setState(
                    () => _selectedLanguages.contains(id)
                        ? _selectedLanguages.remove(id)
                        : _selectedLanguages.add(id),
                  ),
                ),
                FilterSection(
                  title: 'Genres',
                  icon: Icons.category_outlined,
                  items: genreItems,
                  selectedIds: _selectedGenreIds
                      .map((id) => id.toString())
                      .toSet(),
                  isLoading: _loading,
                  onToggle: (id) {
                    final intId = int.parse(id);
                    setState(
                      () => _selectedGenreIds.contains(intId)
                          ? _selectedGenreIds.remove(intId)
                          : _selectedGenreIds.add(intId),
                    );
                  },
                ),
                FilterSection(
                  title: 'Tags',
                  icon: Icons.label_outline,
                  items: tagItems,
                  selectedIds: _selectedTagIds
                      .map((id) => id.toString())
                      .toSet(),
                  isLoading: _loading,
                  onToggle: (id) {
                    final intId = int.parse(id);
                    setState(
                      () => _selectedTagIds.contains(intId)
                          ? _selectedTagIds.remove(intId)
                          : _selectedTagIds.add(intId),
                    );
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel(label: 'Order By', icon: Icons.sort),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _orderBy,
                        hint: const Text('Default'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'relevance',
                            child: Text('Relevance'),
                          ),
                          DropdownMenuItem(
                            value: 'newest',
                            child: Text('Newest first'),
                          ),
                          DropdownMenuItem(
                            value: 'oldest',
                            child: Text('Oldest first'),
                          ),
                          DropdownMenuItem(
                            value: 'title_asc',
                            child: Text('Title A–Z'),
                          ),
                          DropdownMenuItem(
                            value: 'title_desc',
                            child: Text('Title Z–A'),
                          ),
                        ],
                        onChanged: (val) => setState(() => _orderBy = val),
                      ),
                      const SizedBox(height: 16),
                      const SectionLabel(label: 'Include', icon: Icons.search),
                      const SizedBox(height: 10),
                      Center(
                        child: SegmentedButton<SearchInclude>(
                          multiSelectionEnabled: true,
                          segments: const [
                            ButtonSegment(
                              value: SearchInclude.stories,
                              label: Text('Stories'),
                              icon: Icon(Icons.book_outlined, size: 16),
                            ),
                            ButtonSegment(
                              value: SearchInclude.parts,
                              label: Text('Parts'),
                              icon: Icon(Icons.article_outlined, size: 16),
                            ),
                            ButtonSegment(
                              value: SearchInclude.comments,
                              label: Text('Comments'),
                              icon: Icon(Icons.comment_outlined, size: 16),
                            ),
                          ],
                          selected: _include,
                          onSelectionChanged: (val) {
                            if (val.isEmpty) return;
                            setState(() => _include = val);
                          },
                          style: ButtonStyle(
                            iconSize: WidgetStateProperty.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _reset, child: const Text('Reset')),
                const SizedBox(width: 8),
                FilledButton(onPressed: _apply, child: const Text('Apply')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
