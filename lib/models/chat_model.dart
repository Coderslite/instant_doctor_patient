class ChatModel {
  String? message;
  bool? isSender;
  String type;
  String? fileUrl;
  ChatModel({
    this.isSender,
    this.message,
    required this.type,
    this.fileUrl,
  });
}
