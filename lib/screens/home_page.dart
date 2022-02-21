import 'package:chatapp/FirebaseHelper.dart';
import 'package:chatapp/models/chat_room_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/chat_room_page.dart';
import 'package:chatapp/screens/login_page.dart';
import 'package:chatapp/screens/profile.dart';
import 'package:chatapp/screens/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final User user;
  final UserModel userModel;
  const HomePage({Key? key, required this.userModel, required this.user})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  logout() async {
    await FirebaseAuth.instance.signOut().then((value) =>
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Profile(
          currentUser: widget.userModel,
        ),
      ),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text("Messages"),
        centerTitle: true,
        /*actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: const Icon(Icons.logout),
          )
        ],*/
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatSnapshot = snapshot.data as QuerySnapshot;

                return ListView.builder(
                  itemCount: chatSnapshot.docs.length,
                  itemBuilder: (context, int index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromJson(
                        chatSnapshot.docs[index].data()
                            as Map<String, dynamic>);
                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;
                    List<String> participantKey = participants.keys.toList();

                    participantKey.remove(widget.userModel.uid);

                    return FutureBuilder(
                      future: FirebaseHelper.fetchUserModel(participantKey[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;
                            return Card(
                              elevation: 10,
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                          targetUser: targetUser,
                                          chatRoomModel: chatRoomModel,
                                          firebaseUser: widget.user,
                                          ownUser: widget.userModel),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(targetUser.profilepic!),
                                ),
                                title: Text(targetUser.fullname!),
                                subtitle: Text(
                                  chatRoomModel.lastmessage ?? "Say Hello!",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text("no data"),
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                  firebaseUser: widget.user, userModel: widget.userModel),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
