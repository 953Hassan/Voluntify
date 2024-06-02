import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'FirestoreConstants.dart';
import 'ChatMessages.dart';
import 'ChatProvider.dart';
import 'Sizes.dart';
import 'Colours.dart';
import 'Styles.dart';

enum MessageType {
  text,
  image
}

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String peerId;
  final String peerAvatar;
  final String userAvatar;

  ChatPage({
    required this.currentUserId,
    required this.peerId,
    required this.peerAvatar,
    required this.userAvatar,
    required String peerNickname,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late String groupChatId;
  late File? imageFile;
  bool isLoading = false;
  String imageUrl = '';
  int _limit = 20; // Define the limit

  List<DocumentSnapshot> listMessages = [];

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    groupChatId = widget.currentUserId.compareTo(widget.peerId) > 0
        ? '${widget.currentUserId}-${widget.peerId}'
        : '${widget.peerId}-${widget.currentUserId}';
  }

  bool isMessageSent(int index) {
    if ((index > 0 &&
        listMessages[index - 1].get(FirestoreConstants.idFrom) !=
            widget.currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isMessageReceived(int index) {
    if ((index > 0 &&
        listMessages[index - 1].get(FirestoreConstants.idFrom) ==
            widget.currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void onSendMessage(String content, MessageType type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendChatMessage(
          content, type.index, groupChatId, widget.currentUserId, widget.peerId);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadImageFile();
      }
    }
  }

  void uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadImageFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, MessageType.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Widget buildMessageInput() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: Sizes.dimen_4),
            decoration: BoxDecoration(
              color: Colours.burgundy,
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
            ),
            child: IconButton(
              onPressed: getImage,
              icon: const Icon(
                Icons.camera_alt,
                size: Sizes.dimen_28,
              ),
              color: Colours.white,
            ),
          ),
          Flexible(
              child: TextField(
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                controller: textEditingController,
                decoration:
                kTextInputDecoration.copyWith(hintText: 'write here...'),
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, MessageType.text);
                },
              )),
          Container(
            margin: const EdgeInsets.only(left: Sizes.dimen_4),
            decoration: BoxDecoration(
              color: Colours.burgundy,
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
            ),
            child: IconButton(
              onPressed: () {
                onSendMessage(textEditingController.text, MessageType.text);
              },
              icon: const Icon(Icons.send_rounded),
              color: Colours.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      ChatMessages chatMessages = ChatMessages.fromDocument(documentSnapshot);
      if (chatMessages.idFrom == widget.currentUserId) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatMessages.type == MessageType.text.index
                    ? messageBubble(
                  chatContent: chatMessages.content,
                  color: Colours.spaceLight,
                  textColor: Colours.white,
                  margin: const EdgeInsets.only(right: Sizes.dimen_10),
                )
                    : chatMessages.type == MessageType.image.index
                    ? Container(
                  margin: const EdgeInsets.only(
                      right: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: chatImage(
                      imageSrc: chatMessages.content, onTap: () {}),
                )
                    : const SizedBox.shrink(),
                isMessageSent(index)
                    ? Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.dimen_12),
                  ),
                  child: Image.network(
                    widget.userAvatar,
                    width: Sizes.dimen_40,
                    height: Sizes.dimen_40,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colours.burgundy,
                          value: loadingProgress.expectedTotalBytes !=
                              null &&
                              loadingProgress.expectedTotalBytes !=
                                  null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(
                        Icons.account_circle,
                        size: 35,
                        color: Colours.greyColor,
                      );
                    },
                  ),
                )
                    : Container(
                  width: 35,
                ),
              ],
            ),
            isMessageSent(index)
                ? Container(
              margin: const EdgeInsets.only(
                  right: Sizes.dimen_50,
                  top: Sizes.dimen_4,
                  bottom: Sizes.dimen_8),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: Colours.lightGrey,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isMessageReceived(index)
                    ? Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.dimen_12),
                  ),
                  child: Image.network(
                    widget.peerAvatar,
                    width: Sizes.dimen_40,
                    height: Sizes.dimen_40,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colours.burgundy,
                          value: loadingProgress.expectedTotalBytes !=
                              null &&
                              loadingProgress.cumulativeBytesLoaded !=
                                  null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(
                        Icons.account_circle,
                        size: 35,
                        color: Colours.greyColor,
                      );
                    },
                  ),
                )
                    : Container(
                  width: 35,
                ),
                chatMessages.type == MessageType.text.index
                    ? messageBubble(
                  color: Colours.burgundy,
                  textColor: Colours.white,
                  chatContent: chatMessages.content,
                  margin: const EdgeInsets.only(left: Sizes.dimen_10),
                )
                    : chatMessages.type == MessageType.image.index
                    ? Container(
                  margin: const EdgeInsets.only(
                      left: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: chatImage(
                      imageSrc: chatMessages.content, onTap: () {}),
                )
                    : const SizedBox.shrink(),
              ],
            ),
            isMessageReceived(index)
                ? Container(
              margin: const EdgeInsets.only(
                  left: Sizes.dimen_50,
                  top: Sizes.dimen_4,
                  bottom: Sizes.dimen_8),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: Colours.lightGrey,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
          stream: chatProvider.getChatMessage(groupChatId, _limit),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              listMessages = snapshot.data!.docs;
              if (listMessages.isNotEmpty) {
                return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: scrollController,
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data?.docs[index]));
              } else {
                return const Center(
                  child: Text('No messages...'),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colours.burgundy,
                ),
              );
            }
          })
          : const Center(
        child: CircularProgressIndicator(
          color: Colours.burgundy,
        ),
      ),
    );
  }

  Widget messageBubble(
      {required String chatContent,
        required Color color,
        required Color textColor,
        required EdgeInsetsGeometry margin}) {
    return Container(
      child: Text(
        chatContent,
        style: TextStyle(color: textColor),
      ),
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      width: 200,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      margin: margin,
    );
  }

  Widget chatImage({required String imageSrc, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Material(
        child: Image.network(
          imageSrc,
          loadingBuilder: (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: Colours.burgundy,
                value: loadingProgress.expectedTotalBytes != null && loadingProgress.cumulativeBytesLoaded != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, object, stackTrace) {
            return const Icon(
              Icons.image,
              size: 50,
              color: Colours.greyColor,
            );
          },
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(Sizes.dimen_8)),
        clipBehavior: Clip.hardEdge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(color: Colours.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          buildListMessage(),
          buildMessageInput(),
        ],
      ),
    );
  }
}
