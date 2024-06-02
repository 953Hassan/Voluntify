// post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String userId;
  String content;
  String timestamp;

  Post({required this.id, required this.userId, required this.content, required this.timestamp});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc['id'],
      userId: doc['userId'],
      content: doc['content'],
      timestamp: doc['timestamp'],
    );
  }
}
