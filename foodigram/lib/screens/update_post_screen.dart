import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/functions.dart';
import 'package:hashtagable/widgets/hashtag_text_field.dart';
import 'package:provider/provider.dart';
import '../data_center.dart';
import '../database/models.dart';
import '../widgets/places_field.dart';
import 'loading_screen.dart';

class UpdatePostArg {
  final int postIndex;
  UpdatePostArg(this.postIndex);
}

class UpdatePost extends StatefulWidget {
  final int postIndex;
  const UpdatePost({Key? key, required this.postIndex}) : super(key: key);

  @override
  State<UpdatePost> createState() => _UpdatePostState();
}

class _UpdatePostState extends State<UpdatePost> {
  final _textAreaController = TextEditingController();
  late final Post post;
  Map<String, String?>? place;
  DataCenter? _dataCenter;
  bool _isLoading = false;

  void retrieveDate() {
    post = _dataCenter!.posts[widget.postIndex];
    place = post.location.cast<String, String?>();
    _textAreaController.text = post.content;
  }

  void _unfocusAll(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _snackBarMessenger(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
      ),
    );
  }

  void _placeFieldCallback(Map<String, String?>? queryPlace) {
    place = queryPlace;
  }

  Future<void> _updatePost() async {
    final String content = _textAreaController.text;
    Map<String, bool> tags = {};
    Map<String, String?> location = {};

    extractHashTags(content).forEach((tag) {
      tags[tag] = true;
    });

    if (place != null && place!.isNotEmpty) {
      location['name'] = place!['name'];
      location['vicinity'] = place!['vicinity'];
      location['placeId'] = place!['placeId'];
    }

    setState(() => _isLoading = true);

    try {
      await _dataCenter!.updatePost(
        Post(
          id: post.id,
          timestamp: post.timestamp,
          imageUrl: post.imageUrl,
          location: location,
          content: content,
          tags: tags,
        ),
        widget.postIndex,
      );
      //close the form screen
      Navigator.pop(context);
    } on FirebaseException catch (error) {
      log("Failed to add post: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dataCenter == null) {
      _dataCenter = context.read<DataCenter>();
      retrieveDate();
    }
    return _isLoading
        ? const Loading()
        : GestureDetector(
            onTap: () {
              _unfocusAll(context);
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Foodigram"),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () {
                        if (_textAreaController.text.isNotEmpty) {
                          _unfocusAll(context);
                          _updatePost();
                        } else {
                          _snackBarMessenger(
                              'Content cannot be empty!', (Colors.grey[600])!);
                        }
                      },
                      icon: const Icon(Icons.add))
                ],
              ),
              body: Column(
                children: [
                  Form(
                    child: Column(
                      children: [
                        PlacesQuery(
                            placeInfoText: place ?? {},
                            valueCallback: _placeFieldCallback),
                        HashTagTextField(
                          controller: _textAreaController,
                          decoratedStyle: Theme.of(context).textTheme.button,
                          maxLines: 5,
                          maxLength: 200,
                          autofocus: true,
                          basicStyle: Theme.of(context).textTheme.headline3,
                          decoration: InputDecoration(
                            helperStyle: Theme.of(context).textTheme.headline2,
                            border: const OutlineInputBorder(),
                            hintText: "What's your thought?",
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(child: CachedNetworkImage(imageUrl: post.imageUrl)),
                ],
              ),
            ),
          );
  }
}
