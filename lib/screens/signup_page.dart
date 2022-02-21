import 'package:chatapp/Constants/widgets.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'complete_profile.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  checkValue() {
    String email = emailController.text.trim();
    String pass = passController.text.trim();
    String cPass = confirmPassController.text.trim();
    if (email == "" || pass == "" || cPass == "") {
      Fluttertoast.showToast(msg: "enter correct detail");
    } else if (confirmPassController.text.length < 6) {
      return Fluttertoast.showToast(msg: "password greater than 6 digit");
    } else if (pass != cPass) {
      Fluttertoast.showToast(msg: "enter correct password");
    } else {
      signUp(email, pass);
    }
  }

  signUp(String email, String password) async {
    loader(context: context, isShow: true);
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      loader(context: context, isShow: false);
      Fluttertoast.showToast(msg: e.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        email: email,
        uid: uid,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        loader(context: context, isShow: false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompleteProfile(
              userModel: newUser,
              firebaseUser: credential!.user,
            ),
          ),
        );
      });
    } else {
      Fluttertoast.showToast(msg: "user not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Chat App",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                sizedBox,
                TextField(
                  textInputAction: TextInputAction.next,
                  controller: emailController,
                  decoration: const InputDecoration(label: Text("e-mail")),
                ),
                sizedBox,
                TextField(
                  textInputAction: TextInputAction.next,
                  controller: passController,
                  decoration: const InputDecoration(label: Text("password")),
                ),
                sizedBox,
                TextField(
                  textInputAction: TextInputAction.done,
                  controller: confirmPassController,
                  decoration:
                      const InputDecoration(label: Text("confirm password")),
                ),
                sizedBox,
                CupertinoButton(
                    color: Colors.blueAccent,
                    child: const Text("sign up"),
                    onPressed: checkValue)
              ],
            ),
          )),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account ? "),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("log in"))
        ],
      ),
    );
  }
}
