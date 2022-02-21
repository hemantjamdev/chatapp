import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoomModel;
  final User firebaseUser;
  final UserModel ownUser;
  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatRoomModel,
      required this.firebaseUser,
      required this.ownUser})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg.isNotEmpty) {
      /// set new message
      MessageModel newMessageModel = MessageModel(
          messageid: uuid.v1(),
          sender: widget.ownUser.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      ///send new message
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .collection("messages")
          .doc(newMessageModel.messageid)
          .set(newMessageModel.toMap());

      ///set last msg
      widget.chatRoomModel.lastmessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .set(widget.chatRoomModel.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.targetUser.profilepic!),
          ),
          const SizedBox(width: 10),
          Text(widget.targetUser.fullname!),
        ],
      )),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatRoomModel.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, int index) {
                            MessageModel currentMsg = MessageModel.fromJson(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  currentMsg.sender == widget.ownUser.uid
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: currentMsg.sender ==
                                                widget.ownUser.uid
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                    child: Text(
                                      currentMsg.text!,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          overflow: TextOverflow.visible),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Text("check internet connection");
                      } else {
                        return const Text("say hi to your frnd");
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(
                                gapPadding: 0,
                                borderSide:
                                    BorderSide(color: Colors.blueAccent)),
                            hintText: 'Type message...'),
                        maxLines: null,
                        controller: messageController,
                      ),
                    ),
                    const SizedBox(width: 5),
                    CircleAvatar(
                      child: IconButton(
                        alignment: Alignment.center,
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          sendMessage();
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
