import 'package:cloud_firestore/cloud_firestore.dart';
import 'FirestoreConstants.dart';
import 'Post.dart';
import 'Comment.dart';

class PostProvider {
  final FirebaseFirestore firebaseFirestore;

  PostProvider({required this.firebaseFirestore});

  Future<void> createPost(Post post) {
    DocumentReference docRef = firebaseFirestore.collection(FirestoreConstants.pathPostCollection).doc();
    post.id = docRef.id;
    return docRef.set(post.toJson());
  }

  Stream<QuerySnapshot> getPosts() {
    return firebaseFirestore
        .collection(FirestoreConstants.pathPostCollection)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .snapshots();
  }

  Future<void> createComment(Comment comment) {
    DocumentReference docRef = firebaseFirestore.collection(FirestoreConstants.pathCommentCollection).doc();
    comment.id = docRef.id;
    return docRef.set(comment.toJson());
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathCommentCollection)
        .where(FirestoreConstants.postId, isEqualTo: postId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .snapshots();
  }
}
