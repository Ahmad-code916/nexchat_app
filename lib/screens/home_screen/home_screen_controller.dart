import 'dart:async';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  int selectedIndex = 0;
  UserModel? userData;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subscription;

  getUserData() {
    final id = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      subscription = FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(id)
          .snapshots()
          .listen((event) {
            if (event.exists) {
              userData = UserModel.fromMap(event.data()!);
              UserBaseController.updateUserModel(
                UserModel.fromMap(event.data()!),
              );
              print('^^^^^^^^^^^^^^^^^^^^${UserBaseController.userData.name}');
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

  void changeIndex(int index) {
    selectedIndex = index;
    update();
  }

  @override
  void onClose() async {
    await subscription?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    getUserData();
    super.onInit();
  }
}
