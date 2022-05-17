import 'package:flutter/material.dart';
import 'package:foodigram/data_center.dart';
import 'package:foodigram/theme.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class SearchAppbar extends StatefulWidget with PreferredSizeWidget {
  const SearchAppbar({Key? key}) : super(key: key);

  @override
  State<SearchAppbar> createState() => _SearchAppbarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppbarState extends State<SearchAppbar> {
  late DataCenter _dataCenter;
  late String tag;

  Future<void> _queryTags() async {
    final List<Map<String, String>> tagList = [];
    _dataCenter.tags.forEach((tag, postIndices) {
      Map<String, String> tagObj = {};
      tagObj['tag'] = tag;
      tagObj['numPosts'] = postIndices.length.toString();
      tagList.add(tagObj);
    });
    tagList.sort((tag1, tag2) => tag1['tag']!.compareTo(tag2['tag']!));
    final String? selectedTag = await showSearch(
      context: context,
      delegate: _SearchTags(tagList: tagList),
    );
    if (selectedTag != null && selectedTag != "") {
      Navigator.popUntil(context, ModalRoute.withName('lobby'));
      _dataCenter.filterByTag(selectedTag);
    }
  }

  @override
  Widget build(BuildContext context) {
    _dataCenter = context.read<DataCenter>();
    tag = _dataCenter.curTag;
    if (!tag.startsWith('#') && tag.toLowerCase() != "foodigram") {
      tag = _dataCenter
          .posts[_dataCenter.showedPostIndices.first].location['name'];
    }

    return AppBar(
      elevation: 0,
      title: Text(tag),
      centerTitle: true,
      leading: Transform.rotate(
        angle: 180 * math.pi / 180,
        child: IconButton(
          onPressed: () => _dataCenter.authService.signOut(),
          icon: const Icon(
            Icons.logout,
          ),
          tooltip: "Sign out",
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('lobby'));
            _dataCenter.filterByTag("Foodigram");
          },
          icon: const Icon(Icons.apps),
          tooltip: "See all posts",
        ),
        IconButton(
          onPressed: () {
            _queryTags();
          },
          icon: const Icon(Icons.search),
          tooltip: "Search tags",
        ),
      ],
    );
  }
}

class _SearchTags extends SearchDelegate<String> {
  final List<Map<String, dynamic>> tagList;
  _SearchTags({required this.tagList});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return customTheme();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          query = "";
          close(context, query);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final tagsResult = tagList
        .where((tag) => tag['tag'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: tagsResult.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = tagsResult[index]['tag'];
          close(context, query);
        },
        leading: const Icon(Icons.query_builder),
        title: Text(
          tagsResult[index]['tag'],
          style: Theme.of(context).textTheme.headline3,
        ),
        trailing: Text(
          tagsResult[index]['numPosts'],
          style: Theme.of(context).textTheme.headline3,
        ),
        iconColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final tagsResult = tagList
        .where((tag) => tag['tag'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: tagsResult.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = tagsResult[index]['tag'];
          close(context, query);
        },
        leading: const Icon(Icons.query_builder),
        title: Text(
          tagsResult[index]['tag'],
          style: Theme.of(context).textTheme.headline3,
        ),
        trailing: Text(
          tagsResult[index]['numPosts'],
          style: Theme.of(context).textTheme.headline3,
        ),
        iconColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
