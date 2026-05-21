import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/chatbot_model.dart';
import 'package:destined_app/models/thread_model.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/screens/personal_details_screen/personal_details_screen.dart';
import 'package:destined_app/screens/widgets/confirm_dialog.dart';
import 'package:destined_app/screens/widgets/text_form_field_widget.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:destined_app/utils/app_text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreenController extends GetxController {
  String selectedChoice = 'Pictures';
  List<String> choiceList = ['Pictures', 'Videos'];
  List<String> interestList = ['Music', 'Gaming'];
  bool isLoading = false;
  String selectedLanguage = 'English';
  List<ThreadModel> threads = [];
  List<ThreadModel> threadsFiltered = [];
  List<ChatBotModel> chatsWithAi = [];
  List<UserModel> users = [];
  bool isDeletingAccount = false;
  TextEditingController passwordController = TextEditingController();
  bool isPrivateMood =
      UserBaseController.userData.isPrivateMood == null
          ? false
          : UserBaseController.userData.isPrivateMood!;

  void updateSwitchValue(bool value) {
    isPrivateMood = !isPrivateMood;
    updatePrivateMood();
    update();
  }

  void updatePrivateMood() async {
    try {
      await FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(UserBaseController.userData.uid)
          .update({'isPrivateMood': isPrivateMood});
      update();
    } catch (e) {
      Get.dialog(
        AlertDialog(title: Text('Error!'), content: Text(e.toString())),
      );
    }
  }

  void showDialogeToDeleteAccount() async {
    Get.dialog(
      ConfirmDialog(
        title: 'Delete Account',
        subTitle: 'Do you want to delete account?',
        onTapCancel: () {
          Navigator.of(Get.context!).pop();
        },
        onTapConfirm: () {
          Navigator.of(Get.context!).pop();

          showDialogeToReLogin();
        },
      ),
    );
  }

  void deleteAccount() async {
    try {
      isDeletingAccount = true;
      update();
      final currentUserId = UserBaseController.userData.uid ?? "";
      final thread =
          await FirebaseFirestore.instance
              .collection(ThreadModel.tableName)
              .get();
      if (thread.docs.isNotEmpty) {
        threadsFiltered =
            threads =
                thread.docs.map((e) {
                  return ThreadModel.fromMap(e.data());
                }).toList();
      }
      threadsFiltered =
          threads.where((element) {
            return element.participantsList!.contains(currentUserId);
          }).toList();
      await FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(currentUserId)
          .delete();
      for (var user in threadsFiltered) {
        await FirebaseFirestore.instance
            .collection(ThreadModel.tableName)
            .doc(user.id)
            .delete();
      }
      getChatBotChatAndDelete();
      await FirebaseAuth.instance.currentUser!.delete();
      print('^^^^^^^^^^^^^^^^^^^^^^Deleted All Docs');
      isDeletingAccount = false;
      update();
      Navigator.of(Get.context!).pop();
      Get.offAll(() => PersonalDetailsScreen());
      update();
    } catch (e) {
      isDeletingAccount = false;
      update();
      Get.dialog(
        AlertDialog(title: Text('Error!'), content: Text(e.toString())),
      );
    }
  }

  void getChatBotChatAndDelete() async {
    final currentUserId = UserBaseController.userData.uid ?? "";
    String chatbotId = 'gemini_2_flash_bot';
    String id = AppFunctions.generatedThreadId(currentUserId, chatbotId);
    print('^^^^^^^^^^^^^^^^^^$id');
    final chatWithAi =
        await FirebaseFirestore.instance
            .collection(ChatBotModel.tableName)
            .doc(id)
            .get();
    if (chatWithAi.exists) {
      print('^^^^^^^^^^^^^^^^^^^^^^Chat exist');
      await FirebaseFirestore.instance
          .collection(ChatBotModel.tableName)
          .doc(id)
          .delete();
    }
  }

  Future showDialogeToReLogin() async {
    Get.dialog(
      AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Password to delete account',
              style: AppTextStyle.whiteMedium.copyWith(color: Colors.black),
            ),
            AppFunctions.height(18),
            Text(
              'Password',
              style: AppTextStyle.whiteRegular.copyWith(color: Colors.black),
            ),
            AppFunctions.height(8),
            TextFormFieldWidget(controller: passwordController),
            AppFunctions.height(20),
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(Get.context!).pop();
                  },
                  child: Text('Cancel'),
                ),
                GetBuilder<ProfileScreenController>(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () async {
                        isLoading = true;
                        update();
                        if (passwordController.text.trim().isNotEmpty) {
                          try {
                            final user = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email:
                                      UserBaseController.userData.email ?? "",
                                  password: passwordController.text.trim(),
                                );
                            if (user.user!.uid.isNotEmpty) {
                              deleteAccount();
                              removeIdFromLikedByofOtherUsers();
                              isLoading = false;
                              update();
                              Navigator.of(Get.context!).pop();
                            }
                          } catch (e) {
                            isLoading = false;
                            update();
                            Get.dialog(
                              AlertDialog(
                                title: Text('Error!'),
                                content: Text(e.toString()),
                              ),
                            );
                          }
                        } else {
                          isLoading = false;
                          update();
                          Get.dialog(
                            AlertDialog(
                              title: Text('Error!'),
                              content: Text('Please enter password to delete.'),
                            ),
                          );
                        }
                      },
                      child:
                          isLoading == true
                              ? CircularProgressIndicator(
                                color: AppColors.redColor,
                              )
                              : Text(
                                'Ok',
                                style: AppTextStyle.whiteRegular.copyWith(
                                  color: AppColors.redColor,
                                ),
                              ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void removeIdFromLikedByofOtherUsers() async {
    final currentUserId = UserBaseController.userData.uid ?? "";
    final user =
        await FirebaseFirestore.instance.collection(UserModel.tableName).get();
    if (user.docs.isNotEmpty) {
      users =
          user.docs.map((e) {
            return UserModel.fromMap(e.data());
          }).toList();
    }
    for (var user in users) {
      if (user.likedBy!.contains(currentUserId)) {
        user.likedBy!.remove(currentUserId);
        await FirebaseFirestore.instance
            .collection(UserModel.tableName)
            .doc(user.uid)
            .update({'likedBy': user.likedBy});
      }
    }
  }

  void showDialogToLogout() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Logout',
          style: AppTextStyle.whiteMedium.copyWith(color: AppColors.redColor),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Do you want to logout?'),
            AppFunctions.height(20),
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(Get.context!).pop();
                  },
                  child: Text('Cancel'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(Get.context!).pop();
                    logOut();
                  },
                  child: Text(
                    'Ok',
                    style: AppTextStyle.whiteRegular.copyWith(
                      color: AppColors.redColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void logOut() async {
    isLoading = true;
    update();
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => PersonalDetailsScreen());
    isLoading = false;
    update();
  }

  void selectChoiceListOption(int index) {
    selectedChoice = choiceList[index];
    update();
  }
}
