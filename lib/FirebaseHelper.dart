import 'package:chatapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static Future<UserModel?> fetchUserModel(String uId) async {
    UserModel? userModel;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").doc(uId).get();
    if (snapshot.data() != null) {
      userModel = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
