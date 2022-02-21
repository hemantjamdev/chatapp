import 'package:chatapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class Profile extends StatefulWidget {
  final UserModel currentUser;
  const Profile({Key? key, required this.currentUser}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut().then((value) =>
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage())));
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {},
            child: DrawerHeader(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.currentUser.profilepic!),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(widget.currentUser.fullname!),
            subtitle: Text(widget.currentUser.email!),
          ),
          OutlinedButton.icon(
              onPressed: () {
                logout(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"))
        ],
      ),
    );
  }
}
