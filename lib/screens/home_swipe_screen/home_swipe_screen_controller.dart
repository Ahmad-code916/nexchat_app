import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/chatbot_model.dart';
import 'package:destined_app/models/thread_model.dart';
import 'package:destined_app/screens/chatbot_screen/chatbot_screen.dart';
import 'package:destined_app/screens/match_screen/match_sceen.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:destined_app/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../models/user_model.dart';

class HomeSwipeScreenController extends GetxController {
  int currentIndex = 0;
  bool isLoading = false;
  bool isCreatingChat = false;
  final CardSwiperController swiperController = CardSwiperController();
  List<UserModel> userList = [];
  int pageIndex = 0;
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();
  String chatbotId = 'gemini_2_flash_bot';

  void createChatWithAi() async {
    try {
      isCreatingChat = true;
      update();
      final threadId = AppFunctions.generatedThreadId(
        UserBaseController.userData.uid ?? "",
        chatbotId,
      );
      final getChatModel =
          await FirebaseFirestore.instance
              .collection(ChatBotModel.tableName)
              .doc(threadId)
              .get();
      if (getChatModel.exists) {
        isLoading = false;
        update();
        Get.to(() => ChatbotScreen(), arguments: {'threadId': threadId});
      } else {
        final model = ChatBotModel(
          id: threadId,
          message: 'Hello!',
          timeStamp: DateTime.now(),
          senderId: UserBaseController.userData.uid,
        );
        await FirebaseFirestore.instance
            .collection(ChatBotModel.tableName)
            .doc(threadId)
            .set(model.toMap());
        print('Created');
        Get.to(() => ChatbotScreen(), arguments: {'threadId': threadId});
      }
      isCreatingChat = false;
      update();
    } catch (e) {
      isCreatingChat = false;
      update();
      print('Error');
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void getUsers() async {
    try {
      isLoading = true;
      update();
      final snapShot =
          await FirebaseFirestore.instance
              .collection(UserModel.tableName)
              .where('uid', isNotEqualTo: UserBaseController.userData.uid)
              .get();
      if (snapShot.docs.isNotEmpty) {
        userList =
            snapShot.docs
                .map((e) {
                  return UserModel.fromMap(e.data());
                })
                .where((ele) {
                  return (ele.page4 == true &&
                      !((UserBaseController.userData.myLikes!.contains(
                            ele.uid,
                          )) ||
                          (UserBaseController.userData.myDislikes!.contains(
                            ele.uid,
                          ))));
                })
                .toList();
        isLoading = false;
        update();
      }
      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your image.',
      );
    }
  }

  Future onSwipeRight(int index, UserModel user) async {
    final currentUserId = UserBaseController.userData.uid ?? "";
    final updatedLikedBy = userList[index].likedBy;
    updatedLikedBy!.add(currentUserId);
    final updatedMyLikes = UserBaseController.userData.myLikes;
    updatedMyLikes!.add(userList[index].uid!);
    if (UserBaseController.userData.myLikes!.contains(userList[index].uid)) {
      final updateMyMatches = UserBaseController.userData.matches;
      updateMyMatches!.add(userList[index].uid!);
      final updateOtherMatches = userList[index].matches;
      updateOtherMatches!.add(currentUserId);
      await FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(userList[index].uid ?? "")
          .set(
            userList[index]
                .copyWith(likedBy: updatedLikedBy, matches: updateOtherMatches)
                .toMap(),
            SetOptions(merge: true),
          );
      await FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(currentUserId)
          .set(
            UserBaseController.userData
                .copyWith(myLikes: updatedMyLikes, matches: updateMyMatches)
                .toMap(),
            SetOptions(merge: true),
          );
      await createThread(user);
      // AppFunctions.showSnakBar('Congratulations', 'Your match created');
      update();
      Get.to(() => MatchSceen());
    } else {
      await FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(userList[index].uid ?? "")
          .set(
            userList[index].copyWith(likedBy: updatedLikedBy).toMap(),
            SetOptions(merge: true),
          );
      await FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(currentUserId)
          .set(
            UserBaseController.userData
                .copyWith(myLikes: updatedMyLikes)
                .toMap(),
            SetOptions(merge: true),
          );
      // AppFunctions.showSnakBar('Added', 'You liked this profile');
    }
    update();
  }

  Future onSwipeLeft(int index) async {
    final currentUserId = UserBaseController.userData.uid ?? "";
    final updatedMyDislike = UserBaseController.userData.myDislikes;
    updatedMyDislike!.add(userList[index].uid ?? "");
    await FirebaseFirestore.instance
        .collection(UserModel.tableName)
        .doc(currentUserId)
        .set(
          UserBaseController.userData
              .copyWith(myDislikes: updatedMyDislike)
              .toMap(),
          SetOptions(merge: true),
        );
    // AppFunctions.showSnakBar('Dislike!', 'You dislike this profile');
    update();
  }

  Future createThread(UserModel user) async {
    String currentUserId = UserBaseController.userData.uid ?? "";
    String threadId = AppFunctions.generatedThreadId(
      currentUserId,
      user.uid ?? "",
    );
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^$threadId');
    final doc =
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(threadId)
            .get();
    if (doc.exists) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'This chat is already present',
      );
    } else {
      await FirebaseFirestore.instance
          .collection(ThreadModel.tableName)
          .doc(threadId)
          .set(
            ThreadModel(
              id: threadId,
              lastMessage: 'Hy! How are you?',
              lastMessageTime: DateTime.now(),
              participantsList: [currentUserId, user.uid ?? ""],
              senderId: currentUserId,
            ).toMap(),
          );
    }
  }

  void showDialogOnProfileView() async {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Error!',
          style: AppTextStyle.whiteMedium.copyWith(color: AppColors.redColor),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You are not friend.So you cannot see the profile.'),
            AppFunctions.height(20),
            GestureDetector(
              onTap: () {
                // Get.back();
                Navigator.of(Get.context!).pop();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ok',
                  style: AppTextStyle.whiteRegular.copyWith(
                    color: AppColors.redColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollContainer() {
    scrollController.animateTo(
      pageIndex * 20.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void changePageIndex(int value) {
    pageIndex = value;
    update();
  }

  @override
  void onInit() {
    getUsers();
    print(
      '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${UserBaseController.userData.name}',
    );

    super.onInit();
  }
}
