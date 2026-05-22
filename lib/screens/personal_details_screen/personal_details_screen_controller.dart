import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/screens/interests_screen/interests_screen.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalDetailsScreenController extends GetxController {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  DateTime? selectedDate;
  List<String> genderList = ['Male', 'Female', 'Other'];
  String? selectedGender;
  File? image;
  List<File> extraImages2 = [];
  List<String> extraImagesUrl = [];
  final supabase = Supabase.instance.client;

  void onChange(String? value) {
    selectedGender = value;
    update();
  }

  void selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      currentDate: DateTime(2000),
    );
    if (pickedDate != null) {
      selectedDate = pickedDate;
      update();
    }
  }

  void pickImage() async {
    AppFunctions.showDialogToPickImage(
      onPickedImage: (pickedFile) {
        image = pickedFile;
        update();
      },
    );
    update();
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

  void pickImageAndAdddToList() async {
    AppFunctions.showDialogToPickImage(
      onPickedImage: (pickedImage) {
        if (pickedImage != null) {
          extraImages2.add(File(pickedImage.path));
          update();
          print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Added');
          print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${extraImages2.length}');
        }
      },
    );
  }

  Future<List<String>> uploadExtraProfileImages() async {
    if (extraImages2.isEmpty) {
      return [];
    } else {
      try {
        for (var e in extraImages2) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
          await supabase.storage
              .from('chatting_app_images')
              .upload(fileName, e);
          String imageUrl = supabase.storage
              .from('chatting_app_images')
              .getPublicUrl(fileName);
          print('-------------------------->>>>>>>>>>>>>>>>>>>>>>>>>$imageUrl');
          extraImagesUrl.add(imageUrl);
          print(
            '-------------------------->>>>>>>>>>>>>>>>>>>>>>>>>${extraImagesUrl.length}',
          );
        }
        return extraImagesUrl;
      } catch (e) {
        Get.dialog(
          AlertDialog(title: Text('Error!'), content: Text(e.toString())),
        );
        return [];
      }
    }
  }

  void signUp() async {
    if (image == null) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your image',
      );
    } else if (emailController.text.isEmpty) {
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
    } else if (firstNameController.text.isEmpty) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please enter your first name',
      );
    } else if (lastNameController.text.isEmpty) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please enter your last name',
      );
    } else if (selectedDate == null) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your date of birth',
      );
    } else if (selectedGender == null) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your gender',
      );
    } else if (extraImages2.isEmpty) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your profile images.',
      );
    } else {
      try {
        isLoading = true;
        update();
        String imageUrl2 = await uploadImage();
        final imagesList = await uploadExtraProfileImages();
        print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${imagesList.length}');
        final userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );
        final userModel = UserModel(
          uid: userCredential.user?.uid ?? "",
          imageUrl: imageUrl2,
          dateOfBirth: selectedDate,
          gender: selectedGender,
          name: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          profileImages: imagesList,
          page1: true,
          page2: false,
          page3: false,
          page4: false,
        );
        UserBaseController.updateUserModel(
          UserModel.fromMap(userModel.toMap()),
        );
        await fireStore
            .collection(UserModel.tableName)
            .doc(userModel.uid)
            .set(userModel.toMap());
        UserBaseController.updateUserModel(
          UserModel.fromMap(userModel.toMap()),
        );
        Get.to(() => InterestsScreen(), arguments: {'userModel': userModel});
        isLoading = false;
        update();
        emailController.clear();
        passwordController.clear();
        firstNameController.clear();
        lastNameController.clear();
        selectedDate == null;
        selectedGender == null;
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
}
