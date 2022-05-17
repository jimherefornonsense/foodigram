import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodigram/data_center.dart';
import 'package:foodigram/screens/post_detail_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/searchbar_appbar.dart';
import '../widgets/detail_row.dart';
import 'loading_screen.dart';

class Lobby extends StatefulWidget {
  const Lobby({Key? key}) : super(key: key);

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  late DataCenter _dataCenter;

  List<Widget> _createPosts() {
    final List<Widget> postList = [];

    int counter = 0;
    for (var postIdx in _dataCenter.showedPostIndices) {
      final postNum = counter;
      postList.add(
        InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            "post-detail",
            arguments: PostDetailArg(postNum),
          ),
          child: Hero(
            tag: "post_$postIdx",
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: const Color(0xe6e6e6e5),
                  borderRadius: BorderRadius.circular(15)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                      imageUrl: _dataCenter.posts[postIdx].imageUrl)),
            ),
          ),
        ),
      );
      counter++;
    }

    return postList;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _dataCenter = context.watch<DataCenter>();

    return _dataCenter.isFetched
        ? Scaffold(
            appBar: SearchAppbar(),
            body: Stack(
              children: [
                SingleChildScrollView(
                  controller: _dataCenter.lobbyScrollController,
                  child: Column(
                    children: [
                      SizedBox(
                        height: _dataCenter.curTag.startsWith("#") ||
                                _dataCenter.curTag.toLowerCase() == "foodigram"
                            ? 80
                            : 190,
                      ),
                      GridView.count(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        mainAxisSpacing: 1.5,
                        crossAxisSpacing: 1.5,
                        crossAxisCount: 3,
                        children: _createPosts(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                const DetailRow(),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () => Navigator.pushNamed(context, "new-post"),
              tooltip: 'New Post',
              child: const Icon(Icons.add_to_photos),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterFloat,
          )
        : const Loading();
  }
}
