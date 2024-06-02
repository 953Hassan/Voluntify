import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'FirestoreConstants.dart';
import 'ChatMessages.dart';

class ChatProvider {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  // Method to upload an image file to Firebase Storage
  UploadTask uploadImageFile(File image, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  // Method to update Firestore database information
  Future<void> updateFirestoreData(
      String collectionPath, String docPath, Map<String, dynamic> dataUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataUpdate);
  }

  // Method to get a stream of chat messages from Firestore
  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  // Method to send chat messages to Firestore
  void sendChatMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    ChatMessages chatMessages = ChatMessages(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    firebaseFirestore.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });
  }
}
