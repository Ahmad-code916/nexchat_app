import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/screens/home_screen/home_screen.dart';
import 'package:destined_app/screens/interests_screen/interests_screen.dart';
import 'package:destined_app/screens/location_screen/location_screen.dart';
import 'package:destined_app/screens/personal_details_screen/personal_details_screen.dart';
import 'package:destined_app/screens/upload_id_screen/upload_id_screen.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginScreenController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void Login() async {
    try {
      if (emailController.text.isEmpty) {
        showOkAlertDialog(
          context: Get.context!,
          title: 'Error',
          message: 'Please enter your email',
        );
      } else if (passwordController.text.isEmpty) {
        showOkAlertDialog(
          context: Get.context!,
          title: 'Error',
          message: 'Please enter your password',
        );
      } else {
        isLoading = true;
        update();
        final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final currentUser =
            await FirebaseFirestore.instance
                .collection(UserModel.tableName)
                .doc(user.user?.uid ?? "")
                .get();
        if (currentUser.exists) {
          UserBaseController.updateUserModel(
            UserModel.fromMap(currentUser.data()!),
          );
          if (UserBaseController.userData.page1 == false) {
            Get.offAll(
              () => PersonalDetailsScreen(),
              arguments: {'userModel': UserBaseController.userData},
            );
          } else if (UserBaseController.userData.page2 == false) {
            Get.offAll(
              () => InterestsScreen(),
              arguments: {'userModel': UserBaseController.userData},
            );
          } else if (UserBaseController.userData.page3 == false) {
            Get.offAll(
              () => UploadIdScreen(),
              arguments: {'userModel': UserBaseController.userData},
            );
          } else if (UserBaseController.userData.page4 == false) {
            Get.offAll(
              () => LocationScreen(),
              arguments: {'userModel': UserBaseController.userData},
            );
          } else {
            // AppFunctions.showSnakBar(
            //   'Login',
            //   'Login to your account successfully!',
            // );
            isLoading = false;
            update();
            Get.offAll(HomeScreen());
          }
        } else {
          // AppFunctions.showSnakBar('Error!', 'User not found');
          isLoading = false;
          update();
          Get.to(() => PersonalDetailsScreen());
          emailController.clear();
          passwordController.clear();
        }
      }
    } catch (e) {
      isLoading = false;
      update();
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: e.toString(),
      );
    }
  }
}
