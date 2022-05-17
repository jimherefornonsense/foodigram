import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodigram/screens/update_post_screen.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:provider/provider.dart';
import '../data_center.dart';
import '../database/models.dart';
import '../widgets/expandable_fab.dart';

class PostDetailArg {
  final int startingPage;
  PostDetailArg(this.startingPage);
}

class PostDetail extends StatefulWidget {
  final int startingPage;

  const PostDetail({
    Key? key,
    required this.startingPage,
  }) : super(key: key);

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> with TickerProviderStateMixin {
  late DataCenter _dataCenter;
  late int _curPage;
  late PageController _pageCtr;
  late List<int> _postIdxList;
  final List<AnimationController> _animationSet = [];

  @override
  initState() {
    super.initState();
    _curPage = widget.startingPage;
    _pageCtr = PageController(initialPage: _curPage);
  }

  List<Widget> _createPostPages() {
    return List<Widget>.generate(
      _postIdxList.length,
      (pageNum) {
        final animationController = AnimationController(
            vsync: this, duration: const Duration(milliseconds: 300));
        // final curveAnimate =
        //     CurvedAnimation(parent: animationController, curve: Curves.linear);
        _animationSet.add(animationController);
        final int postIdx = _postIdxList[pageNum];
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 1))
                  .animate(animationController),
          child: _postContent(postIdx),
        );
      },
    );
  }

  Widget _postContent(int postIdx) {
    Post post = _dataCenter.posts[postIdx];
    String locationTag = "";

    if (post.location.isNotEmpty) {
      locationTag = post.location['vicinity'] != null
          ? post.location['name'] + ", " + post.location['vicinity']
          : post.location['name'];
    }

    final date = post.timestamp.toLocal().toString().substring(0, 10);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: const Color(0xe6e6e6e5),
            borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Hero(
                    tag: "post_$postIdx",
                    child: CachedNetworkImage(imageUrl: post.imageUrl),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      post.location.isNotEmpty
                          ? ListTile(
                              dense: true,
                              leading: const Icon(Icons.place),
                              title: Text(
                                locationTag,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.button,
                              ),
                              onTap: () {
                                Navigator.popUntil(
                                    context, ModalRoute.withName('lobby'));
                                _dataCenter.filterByTag(locationTag);
                              },
                              iconColor: Theme.of(context).primaryColor,
                            )
                          : const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: HashTagText(
                          textAlign: TextAlign.center,
                          text: post.content,
                          basicStyle: Theme.of(context).textTheme.headline3!,
                          decoratedStyle: Theme.of(context).textTheme.button!,
                          onTap: (tag) {
                            Navigator.popUntil(
                                context, ModalRoute.withName('lobby'));
                            _dataCenter.filterByTag(tag);
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            date,
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deletePost() {
    final length = _postIdxList.length;
    final postIndex = _postIdxList[_curPage];

    if (length == 1) {
      // Only one left
      Navigator.pop(context);
      _dataCenter.deletePost(postIndex);
    } else {
      _animationSet[_curPage].forward().whenComplete(() {
        _dataCenter.deletePost(postIndex);
        // setState(() {});
      });
    }
  }

  void _deleteAlert() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:
            Text('Removing Post', style: Theme.of(context).textTheme.headline6),
        content: Text('Do you want to remove the post?',
            style: Theme.of(context).textTheme.headline4),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              _deletePost();
            },
            child: const Text('OK', style: TextStyle(color: Colors.black38)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var ctr in _animationSet) {
      ctr.dispose();
    }
    _pageCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _dataCenter = context.watch<DataCenter>();
    _postIdxList = _dataCenter.showedPostIndices.toList();

    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          int sensitivity = 20;
          if (details.delta.dy.abs() > sensitivity) {
            // Up and Down Swipe
            Navigator.pop(context);
          }
        },
        child: PageView(
          children: _createPostPages(),
          controller: _pageCtr,
          onPageChanged: (page) {
            _curPage = page;
          },
        ),
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _deleteAlert(),
            icon: const Icon(Icons.delete),
          ),
          ActionButton(
            onPressed: () => Navigator.pushNamed(context, 'new-post'),
            icon: const Icon(Icons.add_to_photos),
          ),
          ActionButton(
            onPressed: () => Navigator.pushNamed(
              context,
              'update-post',
              arguments: UpdatePostArg(_postIdxList[_curPage]),
            ),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }
}
