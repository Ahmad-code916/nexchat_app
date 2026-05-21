import 'dart:async';
import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/chat_model.dart';
import 'package:destined_app/models/thread_model.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/screens/widgets/confirm_dialog.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:destined_app/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreenController extends GetxController {
  late String threadId;
  late UserModel user;
  late ThreadModel threadModel;
  List<ChatModel> messages = [];
  String? message;
  TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  threadSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
  final supabase = Supabase.instance.client;
  File? image;
  bool isSendingMessage = false;
  bool showMenuCard = false;
  bool isDeletingChat = false;

  @override
  updateValue(String? value) {
    message = value;
    update();
  }

  Future getThread() async {
    try {
      threadSubscription = FirebaseFirestore.instance
          .collection(ThreadModel.tableName)
          .doc(threadId)
          .snapshots()
          .listen((event) {
            threadModel = ThreadModel.fromMap(event.data()!);
            update();
          });
    } catch (e) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  Future createChat() async {
    if (messageController.text.trim().isEmpty && image == null) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please enter your message',
      );
    } else {
      if (image == null) {
        isSendingMessage = true;
        update();
        String currentUserId = UserBaseController.userData.uid ?? "";
        String docId = AppFunctions.generateRandomId();
        message = messageController.text;
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .collection(ChatModel.tableName)
            .doc(docId)
            .set(
              ChatModel(
                id: docId,
                isSeen: false,
                message: message,
                messageType: 'text',
                receiverId: user.uid,
                senderId: currentUserId,
                timestamp: DateTime.now(),
              ).toMap(),
            );
        messageController.clear();
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .set(
              threadModel
                  .copyWith(
                    lastMessage: message,
                    lastMessageTime: DateTime.now(),
                    unseenMessageCount: threadModel.unseenMessageCount! + 1,
                    senderId: currentUserId,
                  )
                  .toMap(),
              SetOptions(merge: true),
            );
        isSendingMessage = false;
        update();
      } else {
        isSendingMessage = true;
        update();
        String currentUserId = UserBaseController.userData.uid ?? "";
        String imageUrl = await uploadImage();
        String docId = AppFunctions.generateRandomId();
        message = messageController.text;
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .collection(ChatModel.tableName)
            .doc(docId)
            .set(
              ChatModel(
                id: docId,
                isSeen: false,
                message: message,
                messageType: 'media',
                receiverId: user.uid,
                senderId: currentUserId,
                timestamp: DateTime.now(),
                imageUrl: imageUrl,
              ).toMap(),
            );
        messageController.clear();
        image == null;
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .set(
              threadModel
                  .copyWith(
                    lastMessage: message!.isEmpty ? 'Image' : message,
                    lastMessageTime: DateTime.now(),
                    unseenMessageCount: threadModel.unseenMessageCount! + 1,
                    senderId: currentUserId,
                  )
                  .toMap(),
              SetOptions(merge: true),
            );
        isSendingMessage = false;
        update();
      }
    }
  }

  Future getMessages() async {
    try {
      subscription = FirebaseFirestore.instance
          .collection(ThreadModel.tableName)
          .doc(threadId)
          .collection(ChatModel.tableName)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((event) async {
            if (event.docs.isNotEmpty) {
              messages =
                  event.docs.map((e) {
                    return ChatModel.fromMap(e.data());
                  }).toList();
              if (messages.first.senderId != UserBaseController.userData.uid) {
                await FirebaseFirestore.instance
                    .collection(ThreadModel.tableName)
                    .doc(threadId)
                    .update({'unseenMessageCount': 0});
              }
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

  Future deleteMessage(int index) async {
    String messageId = messages[index].id ?? "";
    await Get.defaultDialog(
      textCancel: 'Cancel',
      textConfirm: 'Ok',
      title: 'Delete!',
      middleText: 'Do you want to delete this message?',
      titleStyle: AppTextStyle.whiteBold.copyWith(
        color: AppColors.blackColor,
        fontSize: 22,
      ),
      middleTextStyle: AppTextStyle.whiteRegular.copyWith(
        color: AppColors.blackColor,
      ),
      cancelTextColor: AppColors.blackColor,
      confirmTextColor: AppColors.whiteColor,
      onCancel: () {},
      onConfirm: () async {
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .collection(ChatModel.tableName)
            .doc(messageId)
            .delete();
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .update({'lastMessage': 'Message Deleted!'});
        Get.back();
        // AppFunctions.showSnakBar('Deleted', 'This message has deleted.');
        update();
      },
    );
  }

  void pickImage() async {
    image = await AppFunctions.pickImage();
    update();
    // final picker = ImagePicker();
    // final pickedImage = await picker.pickImage(source: ImageSource.camera);
    // if (pickedImage != null) {
    //   image = File(pickedImage.path);
    //   updateValue('');
    //   update();
    // } else {
    //   Get.dialog(
    //     AlertDialog(title: Text('Error!'), content: Text('No Image Selected.')),
    //   );
    // }
  }

  Future<String> uploadImage() async {
    if (image == null) {
      return "";
    } else {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
        await supabase.storage
            .from('chatting_app_images')
            .upload(fileName, image!);
        String imageUrl = supabase.storage
            .from('chatting_app_images')
            .getPublicUrl(fileName);
        print('-------------------------->>>>>>>>>>>>>>>>>>>>>>>>>$imageUrl');
        return imageUrl;
      } catch (e) {
        Get.dialog(
          AlertDialog(title: Text('Error!'), content: Text(e.toString())),
        );
        return "";
      }
    }
  }

  void showChatMenuOnTapIcon() {
    if (showMenuCard == false) {
      showMenuCard = true;
      update();
    } else {
      showMenuCard = false;
      update();
    }
  }

  void showDialogToBlockUser() {
    Get.dialog(
      GetBuilder<ChatScreenController>(
        builder: (context) {
          return ConfirmDialog(
            title:
                threadModel.isBlocked == true ? 'Unblock User' : 'Block User',
            subTitle:
                threadModel.isBlocked == true
                    ? 'Do you want to unblock this user?'
                    : 'Do you want to block this user?',
            onTapCancel: () {
              Get.back();
            },
            onTapConfirm: () {
              blockUser();
            },
          );
        },
      ),
    );
  }

  void blockUser() async {
    try {
      if (threadModel.isBlocked != true) {
        final model = threadModel.copyWith(
          isBlocked: threadModel.isBlocked == true ? false : true,
          senderId: UserBaseController.userData.uid,
          lastMessage: threadModel.isBlocked == false ? 'Blocked' : 'Unblock',
          lastMessageTime: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .set(model.toMap(), SetOptions(merge: true));
        update();
        Get.back();
        Get.snackbar(
          threadModel.isBlocked == true ? 'Blocked' : 'Unblock',
          threadModel.isBlocked == true
              ? 'User has been blocked.'
              : 'User has been unblocked.',
        );
      } else if (threadModel.isBlocked == true &&
          threadModel.senderId == UserBaseController.userData.uid) {
        final model = threadModel.copyWith(
          isBlocked: threadModel.isBlocked == true ? false : true,
          senderId: UserBaseController.userData.uid,
          lastMessage: threadModel.isBlocked == false ? 'Blocked' : 'Unblock',
          lastMessageTime: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .set(model.toMap(), SetOptions(merge: true));
        update();
        Get.back();
        Get.snackbar(
          threadModel.isBlocked == true ? 'Blocked' : 'Unblock',
          threadModel.isBlocked == true
              ? 'User has been blocked.'
              : 'User has been unblocked.',
        );
      } else {
        Get.back();
        showOkAlertDialog(
          context: Get.context!,
          title: 'Error',
          message: 'You cannot unblock this user.',
        );
      }
    } catch (e) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void clearChat() async {
    try {
      showMenuCard = false;
      isDeletingChat = true;
      update();
      for (var message in messages) {
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .collection(ChatModel.tableName)
            .doc(message.id)
            .delete();
      }
      final model = threadModel.copyWith(
        lastMessage: 'Start Chat',
        lastMessageTime: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection(ThreadModel.tableName)
          .doc(threadId)
          .set(model.toMap(), SetOptions(merge: true));
      messages.clear();
      isDeletingChat = false;
      update();
    } catch (e) {
      isDeletingChat = false;
      update();
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void addChatToArchived() async {
    try {
      final currentUserId = UserBaseController.userData.uid ?? "";
      if (threadModel.archivedUsersList!.contains(currentUserId)) {
        threadModel.archivedUsersList!.remove(currentUserId);
      } else {
        threadModel.archivedUsersList!.add(currentUserId);
      }
      final model = threadModel.copyWith(
        archivedUsersList: threadModel.archivedUsersList,
        senderId: currentUserId,
        lastMessageTime: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection(ThreadModel.tableName)
          .doc(threadId)
          .set(model.toMap(), SetOptions(merge: true));
      Get.back();
      update();
    } catch (e) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  @override
  void onClose() async {
    subscription?.cancel();
    threadSubscription?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    threadId = Get.arguments['threadId'];
    user = Get.arguments['user'];
    threadModel = Get.arguments['threadModel'];
    getMessages();
    getThread();
    super.onInit();
  }
}
