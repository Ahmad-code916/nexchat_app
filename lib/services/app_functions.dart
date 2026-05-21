import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'package:destined_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AppFunctions {
  static Widget height(double height) {
    return SizedBox(height: height);
  }

  static Widget width(double width) {
    return SizedBox(width: width);
  }

  static BorderRadius borderRadius(double radius) {
    return BorderRadius.all(Radius.circular(radius));
  }

  // static SnackbarController showSnakBar(String title, String message) {
  //   return Get.snackbar(title, message, backgroundColor: AppColors.whiteColor);
  // }

  static int calculateAge(DateTime dateOfBirth) {
    DateTime today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  static String generatedThreadId(String currentUserId, String otherUserId) {
    return currentUserId.compareTo(otherUserId) >= 0
        ? "${currentUserId}__$otherUserId"
        : "${otherUserId}__$currentUserId";
  }

  static String generateRandomId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final math.Random random = math.Random();
    return List.generate(
      15,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static String calculateDistance(
    double currentUserLat,
    double currentUserLng,
    double otherUserLat,
    double otherUserLng,
  ) {
    const earthRadiusKm = 6371; // Radius of the Earth in km

    final dLat = _degreesToRadians(otherUserLat - currentUserLat);
    final dLng = _degreesToRadians(otherUserLng - currentUserLng);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(currentUserLat)) *
            cos(_degreesToRadians(otherUserLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c; // distance in km

    return distance.toStringAsFixed(1); // return as String with 1 decimal place
  }

  static double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }

  static Future<File?> pickImage() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      print('status-------------->>>>>>>>>>>>.>$status');
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        return File(pickedImage.path);
        // image = File(pickedImage.path);
        // update();
      }
    } else {
      Get.dialog(
        AlertDialog(title: Text('Error!'), content: Text('No Image Selected.')),
      );
      return null;
    }
    return null;
  }
}
