import 'package:chatapp/FirebaseHelper.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'screens/login_page.dart';

Uuid uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) async {
    if (currentUser != null) {
      UserModel? fetchedUserModel =
          await FirebaseHelper.fetchUserModel(currentUser.uid);
      if (fetchedUserModel != null) {
        runApp(ChatAppLoggedIn(
            firebaseUser: currentUser, userModel: fetchedUserModel));
      }
    } else {
      runApp(const ChatApp());
    }
  });
}

/// no logged in
class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

/// already logged in
class ChatAppLoggedIn extends StatelessWidget {
  final User firebaseUser;
  final UserModel userModel;
  const ChatAppLoggedIn(
      {Key? key, required this.firebaseUser, required this.userModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      home: HomePage(
        userModel: userModel,
        user: firebaseUser,
      ),
    );
  }
}
