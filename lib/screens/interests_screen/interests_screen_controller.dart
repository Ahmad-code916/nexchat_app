import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destined_app/models/local_list_model.dart';
import 'package:destined_app/models/user_model.dart';
import 'package:destined_app/screens/upload_id_screen/upload_id_screen.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:destined_app/utils/app_images.dart';
import 'package:destined_app/utils/app_strings.dart';
import 'package:get/get.dart';

class InterestsScreenController extends GetxController {
  late UserModel userModel;
  bool isLoading = false;
  List<LocalListModel> selectedItems = [];
  List<String> selectedInterestList = [];
  List<LocalListModel> interestList = [
    LocalListModel(
      interest: AppStrings.photography.tr,
      image: AppImages.cameraImage,
    ),
    LocalListModel(
      interest: AppStrings.cooking.tr,
      image: AppImages.cookingImage,
    ),
    LocalListModel(
      interest: AppStrings.videoGames.tr,
      image: AppImages.videoGameImage,
    ),
    LocalListModel(interest: AppStrings.music.tr, image: AppImages.musicImage),
    LocalListModel(
      interest: AppStrings.travelling.tr,
      image: AppImages.travellingImage,
    ),
    LocalListModel(
      interest: AppStrings.shopping.tr,
      image: AppImages.shoppingImage,
    ),
    LocalListModel(
      interest: AppStrings.speeches.tr,
      image: AppImages.speecheImage,
    ),
    LocalListModel(
      interest: AppStrings.artCrafts.tr,
      image: AppImages.artCreaftImage,
    ),
    LocalListModel(
      interest: AppStrings.swimming.tr,
      image: AppImages.swimmingImage,
    ),
    LocalListModel(
      interest: AppStrings.drinking.tr,
      image: AppImages.drinkingImage,
    ),
    LocalListModel(
      interest: AppStrings.extremeSports.tr,
      image: AppImages.sportsImage,
    ),
    LocalListModel(
      interest: AppStrings.fitness.tr,
      image: AppImages.fitnessImage,
    ),
  ];

  void addInterestToList(int index) {
    if (selectedItems.contains(interestList[index])) {
      selectedItems.remove(interestList[index]);
    } else {
      selectedItems.add(interestList[index]);
    }
    update();
  }

  void selectList(int index) {
    if (selectedInterestList.contains(interestList[index].interest)) {
      selectedInterestList.remove(interestList[index].interest);
    } else {
      selectedInterestList.add(interestList[index].interest);
    }
    update();
  }

  void updateUserInFirebase() {
    if (selectedInterestList.isEmpty) {
      showOkAlertDialog(
        context: Get.context!,
        title: 'Error',
        message: 'Please select your list',
      );
    } else {
      try {
        isLoading = true;
        update();
        final userModel2 = userModel.copyWith(
          interestList: selectedInterestList,
          page2: true,
        );
        FirebaseFirestore.instance
            .collection(UserModel.tableName)
            .doc(userModel.uid)
            .set(userModel2.toMap(), SetOptions(merge: true));
        UserBaseController.updateUserModel(
          UserModel.fromMap(userModel2.toMap()),
        );
        print('^^^^^^^^^^^^^^^^^^^^^^^^^${UserBaseController.userData.page2}');
        print('^^^^^^^^^^^^^^^^^^^^^^^^^${UserBaseController.userData.page3}');
        Get.to(() => UploadIdScreen(), arguments: {'userModel': userModel2});
        isLoading = false;
        update();
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

  @override
  void onInit() {
    userModel = Get.arguments['userModel'];
    super.onInit();
  }
}
