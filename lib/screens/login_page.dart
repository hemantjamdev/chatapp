import 'package:chatapp/Constants/widgets.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  checkValue() {
    String email = emailController.text.trim();
    String pass = passController.text.trim();

    if (email == "" || pass == "") {
      Fluttertoast.showToast(msg: "enter correct detail");
    }
    /* else if (pass.length < 6) {
      Fluttertoast.showToast(msg: "enter correct pass");
    }*/
    else {
      login(email, pass);
    }
  }

  login(String email, String pass) async {
    loader(context: context, isShow: true);
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
    } catch (e) {
      loader(context: context, isShow: false);
      Fluttertoast.showToast(msg: e.toString());
    }
    if (credential != null) {
      String uId = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uId).get();

      UserModel _userModel =
          UserModel.fromJson(userData.data() as Map<String, dynamic>);

      Fluttertoast.showToast(msg: "login success");
      loader(context: context, isShow: false);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    userModel: _userModel,
                    user: credential!.user!,
                  )));
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
                  textInputAction: TextInputAction.done,
                  controller: passController,
                  decoration: const InputDecoration(label: Text("password")),
                ),
                sizedBox,
                CupertinoButton(
                    color: Colors.blueAccent,
                    child: const Text("log in"),
                    onPressed: () {
                      checkValue();
                    })
              ],
            ),
          )),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("don't have an account ? "),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()));
            },
            child: const Text("sign up"),
          )
        ],
      ),
    );
  }
}
