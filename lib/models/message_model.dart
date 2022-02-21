class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  MessageModel(
      {required this.text,
      required this.createdon,
      required this.seen,
      required this.sender,
      required this.messageid});
  MessageModel.fromJson(Map<String, dynamic> map) {
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
    messageid = map["messageid"];
  }
  Map<String, dynamic> toMap() {
    return {
      "messageId": messageid,
      "sender": sender,
      "seen": seen,
      "text": text,
      "createdon": createdon
    };
  }
}
