import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'PostProvider.dart';
import 'Comment.dart';

class CommentPage extends StatefulWidget {
  final String postId;

  CommentPage({required this.postId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final PostProvider postProvider = PostProvider(firebaseFirestore: FirebaseFirestore.instance);
  final TextEditingController contentController = TextEditingController();

  void createComment() {
    String content = contentController.text.trim();
    if (content.isNotEmpty) {
      Comment comment = Comment(
        id: '',
        postId: widget.postId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        content: content,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      postProvider.createComment(comment);
      contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Write a comment...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: createComment,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: postProvider.getComments(widget.postId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Comment comment = Comment.fromDocument(docs[index]);
                    return ListTile(
                      title: Text(comment.content),
                      subtitle: Text('Commented by: ${comment.userId}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
