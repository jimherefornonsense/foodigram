class Post {
  String? id;
  final DateTime timestamp;
  final String imageUrl;
  final Map location;
  final String content;
  final Map tags;

  Post({
    this.id,
    required this.timestamp,
    required this.imageUrl,
    required this.location,
    required this.content,
    required this.tags,
  });

  bool disable = false;

  factory Post.fromJson(Map<String, dynamic> parsedJson) {
    return Post(
      id: parsedJson['id'],
      timestamp: parsedJson['timestamp'].toDate(),
      imageUrl: parsedJson['imageUrl'],
      location: parsedJson['location'],
      content: parsedJson['content'],
      tags: parsedJson['tags'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'location': location,
      'content': content,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'Post{id: $id, timestamp: $timestamp, imageUrl: $imageUrl, location: $location, content: $content, tags: $tags}';
  }
}

class Account {
  final String uid;
  final String email;
  final List<String> postIdSet;

  Account({
    required this.uid,
    required this.email,
    required this.postIdSet,
  });

  factory Account.fromJson(Map<String, dynamic> parsedJson) {
    return Account(
      uid: parsedJson['uid'],
      email: parsedJson['email'],
      postIdSet: parsedJson['postIdSet'].cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'postIdSet': postIdSet,
    };
  }
}
