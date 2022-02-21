import 'dart:io';
import 'package:chatapp/Constants/widgets.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'login_page.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User? firebaseUser;
  const CompleteProfile(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController fullNameController = TextEditingController();
  File? image;
  showPickerOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text("gallery"),
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("camera"),
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
            )
          ],
        );
      },
    );
  }

  selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  cropImage(XFile file) async {
    File? croppedImage = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 50);
    if (croppedImage != null) {
      setState(() {});
      image = croppedImage;
    }
  }

  checkValue() {
    String fullName = fullNameController.text.trim();
    if (fullName.isNotEmpty && image != null) {
      submit();
    } else {
      Fluttertoast.showToast(msg: "enter correct data");
    }
  }

  submit() async {
    loader(context: context, isShow: true);
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePictures")
        .child(widget.userModel.uid!)
        .putFile(image!);

    TaskSnapshot snapshot = await uploadTask;

    String? profilePictureUrl = await snapshot.ref.getDownloadURL();

    String? fullName = fullNameController.text.trim();

    widget.userModel.fullname = fullName;
    widget.userModel.profilepic = profilePictureUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      loader(context: context, isShow: false);
      Fluttertoast.showToast(msg: "user uploaded");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: ListView(
            children: [
              sizedBox,
              GestureDetector(
                onTap: showPickerOption,
                child: CircleAvatar(
                  backgroundImage: image != null ? FileImage(image!) : null,
                  radius: 50,
                  child: image == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                        )
                      : const SizedBox(),
                ),
              ),
              sizedBox,
              TextField(
                autofocus: false,
                controller: fullNameController,
                decoration: const InputDecoration(label: Text("full name")),
              ),
              sizedBox,
              CupertinoButton(
                color: Colors.blue,
                child: const Text("submit"),
                onPressed: () {
                  checkValue();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
