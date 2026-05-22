import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/screens/location_screen/location_screen.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadIdScreenController extends GetxController {
  late UserModel userModel;
  bool showUploadImage = false;
  File? image;
  String? imageUrl;
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  void toggleImage() {
    showUploadImage = !showUploadImage;
    update();
  }

  void pickImage() async {
    AppFunctions.showDialogToPickImage(
      onPickedImage: (pickedImage) {
        image = pickedImage;
        update();
      },
    );
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

  void updateUserInFirebase() async {
    if (image == null) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your image.',
      );
    } else {
      isLoading = true;
      update();
      String imageUrl2 = await uploadImage();
      print('---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$imageUrl2');
      final userModel2 = userModel.copyWith(uploadedId: imageUrl2, page3: true);
      await FirebaseFirestore.instance
          .collection(UserModel.tableName)
          .doc(userModel.uid)
          .set(userModel2.toMap(), SetOptions(merge: true));
      UserBaseController.updateUserModel(UserModel.fromMap(userModel2.toMap()));
      Get.offAll(() => LocationScreen(), arguments: {'userModel': userModel2});
      isLoading = false;
      update();
    }
  }

  @override
  void onInit() {
    userModel = Get.arguments['userModel'];
    super.onInit();
  }
}
