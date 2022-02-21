class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastmessage;

  ChatRoomModel(
      {required this.chatroomid,
      required this.participants,
      required this.lastmessage});
  ChatRoomModel.fromJson(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastmessage = map["lastmessage"];
  }
  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastmessage
    };
  }
}
