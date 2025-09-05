import 'package:uuid/uuid.dart';

var uuid = Uuid();

String generateID() {
    String id = uuid.v4();
    return id;
  }

String title(String str) {
  String firstChar = str[0];
  String otherChars = str.substring(1, str.length);
  return '${firstChar.toUpperCase()}$otherChars';
}