import 'package:chatapp/Constants/widgets.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;
  const SearchPage(
      {Key? key, required this.firebaseUser, required this.userModel})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel> getChatRoom(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      //fetch existed one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromJson(docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;
    } else {
      // new
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastmessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Search'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {});
                },
                controller: searchController,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                        gapPadding: 0,
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    hintText: 'Type user name...'),
              ),
              sizedBox,
              /* CupertinoButton(
                  child: const Text('search'),
                  onPressed: () {
                    setState(() {});
                    searchUser();
                  }),*/
              sizedBox,
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("fullname", isEqualTo: searchController.text)
                    .where("fullname", isNotEqualTo: widget.userModel.fullname)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      if (dataSnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchedUser = UserModel.fromJson(userMap);
                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoom =
                                await getChatRoom(searchedUser);
                            if (chatRoom != null) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                    targetUser: searchedUser,
                                    firebaseUser: widget.firebaseUser,
                                    ownUser: widget.userModel,
                                    chatRoomModel: chatRoom,
                                  ),
                                ),
                              );
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(searchedUser.profilepic!),
                          ),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email!),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        );
                      } else {
                        return const Expanded(
                            child: Center(
                                child: Icon(
                          Icons.person_search,
                          size: 200,
                        )));
                      }
                    } else if (snapshot.hasError) {
                      return const Text("error occured");
                    } else {
                      return const Text("no data found");
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
