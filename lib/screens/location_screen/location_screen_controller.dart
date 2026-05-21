import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/screens/home_screen/home_screen.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreenController extends GetxController {
  late UserModel userModel;
  Position? currentPosition;
  LocationPermission? locationPermission;
  CameraPosition? newPickedLocation;
  Placemark? currentUserData;

  final TextEditingController locationController = TextEditingController();
  bool isLoading = false;
  bool isUpdatingData = false;

  Future<Position> getPosition() async {
    isLoading = true;
    update();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.dialog(
        AlertDialog(
          title: Text('Error!'),
          content: Text('Location services are disabled.'),
        ),
      );
      isLoading = false;
      update();
    }
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    if (locationPermission == LocationPermission.denied) {
      Get.dialog(
        AlertDialog(
          title: Text('Error!'),
          content: Text('Location permissions were denied.'),
        ),
      );
      isLoading = false;
      update();
    }
    if (locationPermission == LocationPermission.deniedForever) {
      Get.dialog(
        AlertDialog(
          title: Text('Error!'),
          content: Text(
            'Location permissions are permanently denied.We cannot request for permissions.',
          ),
        ),
      );
      isLoading = false;
      update();
    }
    currentPosition = await Geolocator.getCurrentPosition();
    newPickedLocation = CameraPosition(
      target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
      bearing: 192.8334901395799,
      zoom: 19.151926040649414,
    );
    isLoading = false;
    update();
    print(
      '------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>${currentPosition!.latitude}',
    );
    currentUserData = await getCurrentUserDetails(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );
    update();
    return currentPosition!;
  }

  Future<Placemark> getCurrentUserDetails(double lat, double lng) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, lng);
    if (placeMarks.isNotEmpty) {
      Placemark place = placeMarks.first;
      print("FULL PLACE DATA: ${place.toString()}");
      print("Country: ${place.country}");
      print("Locality: ${place.locality}");
      print("Administrative Area: ${place.administrativeArea}");
      print("Postal Code: ${place.postalCode}");
      print("Street: ${place.street}");
      return place;
    } else {
      throw Exception("No placemark found for given coordinates");
    }
  }

  void updateUserInFirebase() async {
    if (currentUserData == null) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your location.',
      );
    } else {
      try {
        isUpdatingData = true;
        update();
        final userModel2 = userModel.copyWith(
          location:
              '${currentUserData!.subLocality},${currentUserData!.locality},${currentUserData!.country}',
          lat: currentPosition!.latitude.toDouble(),
          lng: currentPosition!.longitude.toDouble(),
          page4: true,
        );
        await FirebaseFirestore.instance
            .collection(UserModel.tableName)
            .doc(userModel.uid)
            .set(userModel2.toMap(), SetOptions(merge: true));
        UserBaseController.updateUserModel(
          UserModel.fromMap(userModel2.toMap()),
        );
        // AppFunctions.showSnakBar('Updaed!', 'Location added to your data.');
        Get.offAll(HomeScreen());
        isUpdatingData = false;
        update();
      } catch (e) {
        isUpdatingData = false;
        update();
        showOkAlertDialog(
          context: Get.context!,
          title: 'Error',
          message: e.toString(),
        );
      }
    }
  }

  @override
  void onInit() {
    userModel = Get.arguments['userModel'];
    super.onInit();
  }
}
