import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodigram/authentication/auth_service.dart';
import 'package:foodigram/database/database.dart';
import 'package:google_place/google_place.dart';
import 'database/models.dart';
import 'database/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DataCenter extends ChangeNotifier {
  final AuthService authService = AuthService();
  final CloudBaseHandler _cloudBaseHandler = CloudBaseHandler();
  final CloudStorageHandler _cloudStorageHandler = CloudStorageHandler();
  final ScrollController lobbyScrollController = ScrollController();
  bool isFetched = false;
  late Account account;
  late List<Post> posts;
  late String curTag;
  late Map<String, PriorityQueue<int>> tags;
  late Queue<int> showedPostIndices;
  late int numPlaces;
  GooglePlace googlePlace = GooglePlace("${dotenv.env['places_api_key']}");

  @override
  dispose() {
    lobbyScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    posts = [];
    numPlaces = 0;
    showedPostIndices = Queue<int>();
    tags = {};
    try {
      var userSnapshot =
          await _cloudBaseHandler.getUser(authService.currentUser()!.uid);
      var user = userSnapshot.data() as Map<String, dynamic>;
      account = Account.fromJson(user);

      for (int i = 0; i < account.postIdSet.length; i++) {
        final postId = account.postIdSet[i];
        var querySnapshot = await _cloudBaseHandler.getDocumentById(postId);
        var data = querySnapshot.data() as Map<String, dynamic>;
        data['id'] = postId;
        Post post = Post.fromJson(data);
        posts.add(post);
        _extractTags(post, i);
        showedPostIndices.addFirst(i);
      }

      curTag = 'Foodigram';
      isFetched = true;
      notifyListeners();
    } catch (e) {
      log("Failed to retrieve posts: $e");
    }
  }

  Future<Map<String, dynamic>> getPlaceInfo() async {
    Map<String, dynamic> placeInfo = {};
    String? placeId = posts[showedPostIndices.first].location['placeId'];

    if (placeId == null) {
      return placeInfo;
    }
    log("Request place detail.");
    DetailsResponse? response = await googlePlace.details.get(placeId);
    if (response!.result != null) {
      placeInfo['name'] = response.result!.name;
      placeInfo['address'] =
          response.result!.vicinity ?? response.result!.adrAddress;
      placeInfo['number'] = response.result!.internationalPhoneNumber;
      if (response.result!.openingHours!.openNow != null) {
        placeInfo['status'] =
            response.result!.openingHours!.openNow! ? "Open" : "Closed";
      }
      placeInfo['openDays'] = response.result!.openingHours!.weekdayText;
    }
    return placeInfo;
  }

  void _extractTags(Post post, int index) {
    if (post.location.isNotEmpty) {
      String locationTag = post.location['vicinity'] != null
          ? post.location['name'] + ", " + post.location['vicinity']
          : post.location['name'];
      if (!tags.containsKey(locationTag)) {
        numPlaces++;
        tags[locationTag] = PriorityQueue<int>();
        tags[locationTag]!.add(index);
      } else {
        tags[locationTag]!.add(index);
      }
    }
    post.tags.forEach((tag, _) {
      if (!tags.containsKey(tag)) {
        tags[tag] = PriorityQueue<int>();
        tags[tag]!.add(index);
      } else {
        tags[tag]!.add(index);
      }
    });
  }

  void _removeTags(Post post, int index) {
    if (post.location.isNotEmpty) {
      String locationTag = post.location['vicinity'] != null
          ? post.location['name'] + ", " + post.location['vicinity']
          : post.location['name'];
      if (tags.containsKey(locationTag)) {
        tags[locationTag]!.remove(index);
        if (tags[locationTag]!.isEmpty) {
          numPlaces++;
          tags.remove(locationTag);
        }
      }
    }
    post.tags.forEach((tag, _) {
      if (tags.containsKey(tag)) {
        tags[tag]!.remove(index);
        if (tags[tag]!.isEmpty) {
          tags.remove(tag);
        }
      }
    });
  }

  void filterByTag(String tag) {
    curTag = tag;
    numPlaces = 0;
    Set<String> placeSet = {};
    showedPostIndices.clear();
    if (tag == 'Foodigram') {
      for (int i = 0; i < posts.length; i++) {
        if (posts[i].disable) {
          continue;
        }
        if (posts[i].location.isNotEmpty) {
          String place = posts[i].location['name'] ??
              "" + posts[i].location['placeId'] ??
              "";
          placeSet.add(place);
        }
        showedPostIndices.addFirst(i);
      }
    } else if (tags.containsKey(tag)) {
      final postIdxListtags = tags[tag]!.toList();
      for (var index in postIdxListtags) {
        // Count places when filter by tag
        if (tag.startsWith("#") && posts[index].location.isNotEmpty) {
          String place = posts[index].location['name'] ??
              "" + posts[index].location['placeId'] ??
              "";
          placeSet.add(place);
        }
        showedPostIndices.addFirst(index);
      }
    }
    numPlaces = placeSet.length;
    //Scroll back to the top
    lobbyScrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    notifyListeners();
  }

  Future<void> addUser(Account account) async {
    try {
      _cloudBaseHandler.addUser(account.toMap());
    } catch (e) {
      log("Failed to add user: $e");
    }
  }

  UploadTask addImage(String fileName, File image) {
    return _cloudStorageHandler.addImage(fileName, image);
  }

  Future<void> addPost(Post post) async {
    try {
      //Posts
      final postRef = await _cloudBaseHandler.addDocument(post.toMap());
      post.id = postRef.id;
      posts.add(post);
      showedPostIndices.addFirst(posts.length - 1);
      //Users
      account.postIdSet.add(postRef.id);
      await _cloudBaseHandler
          .updateUser({'postIdSet': account.postIdSet}, account.uid);

      _extractTags(post, posts.length - 1);
      notifyListeners();
    } catch (e) {
      log("Failed to add post: $e");
    }
  }

  Future<void> updatePost(Post post, int index) async {
    try {
      _removeTags(posts[index], index);
      _extractTags(post, index);
      posts[index] = post;
      notifyListeners();
      await _cloudBaseHandler.updateDocument(post.toMap(), posts[index].id!);
    } catch (e) {
      log("Failed to update post: $e");
    }
  }

  Future<void> deletePost(int index) async {
    try {
      //Delete post in local lists
      posts[index].disable = true;
      account.postIdSet.remove(posts[index].id!);
      showedPostIndices.remove(index);
      _removeTags(posts[index], index);
      notifyListeners();
      //Delete post in cloud database
      await _cloudBaseHandler.removeDocument(posts[index].id!);
      await _cloudBaseHandler
          .updateUser({"postIdSet": account.postIdSet}, account.uid);
      await _cloudStorageHandler.deleteImage(posts[index].imageUrl);
    } catch (e) {
      log("Failed to delete post: $e");
    }
  }
}
