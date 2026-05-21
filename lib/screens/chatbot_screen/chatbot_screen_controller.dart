import 'dart:async';
import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/chatbot_message_model.dart';
import 'package:destined_app/models/chatbot_model.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatbotScreenController extends GetxController {
  TextEditingController messageText = TextEditingController();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
  List<ChatBotMessageModel> chatMessages = [];
  bool isLoading = false;
  late String threadId;

  final String apiKey = '123';
  final String url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  Future<String> sendMessage() async {
    try {
      String id = AppFunctions.generateRandomId();
      isLoading = true;
      update();
      final model = ChatBotMessageModel(
        isSender: true,
        message: messageText.text.trim(),
        timestamp: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection(ChatBotModel.tableName)
          .doc(threadId)
          .collection(ChatBotMessageModel.tableName)
          .doc(id)
          .set(model.toMap());
      print('^^^^^^^Send');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'X-goog-api-key': apiKey},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": messageText.text.trim()},
              ],
            },
          ],
        }),
      );
      if (response.statusCode == 200) {
        String id2 = AppFunctions.generateRandomId();
        print('Status code 200');
        final data = jsonDecode(response.body);
        print(
          '^^^^^^^^^^^^^^^${data['candidates'][0]['content']['parts'][0]['text']}',
        );
        final model2 = ChatBotMessageModel(
          isSender: false,
          message: data['candidates'][0]['content']['parts'][0]['text'],
          timestamp: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection(ChatBotModel.tableName)
            .doc(threadId)
            .collection(ChatBotMessageModel.tableName)
            .doc(id2)
            .set(model2.toMap());
        messageText.clear();
        isLoading = false;
        update();
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Status code Error');
        final errorData = jsonDecode(response.body);
        print('Error $errorData');
        messageText.clear();
        isLoading = false;
        update();
        return errorData['error']['message'] ?? 'Unknown error';
      }
    } catch (e) {
      messageText.clear();
      isLoading = false;
      update();
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
      return '';
    }
  }

  void listenChatMessages() {
    try {
      subscription = FirebaseFirestore.instance
          .collection(ChatBotModel.tableName)
          .doc(threadId)
          .collection(ChatBotMessageModel.tableName)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((event) {
            if (event.docs.isNotEmpty) {
              chatMessages =
                  event.docs.map((e) {
                    return ChatBotMessageModel.fromMap(e.data());
                  }).toList();
              update();
            }
          });
    } catch (e) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  @override
  void onInit() {
    threadId = Get.arguments['threadId'];
    print('^^^^^^^^^^^^^^^^^^^^$threadId');
    listenChatMessages();
    super.onInit();
  }
}
