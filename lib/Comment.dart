// comment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id;
  String postId;
  String userId;
  String content;
  String timestamp;

  Comment({required this.id, required this.postId, required this.userId, required this.content, required this.timestamp});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc['id'],
      postId: doc['postId'],
      userId: doc['userId'],
      content: doc['content'],
      timestamp: doc['timestamp'],
    );
  }
}