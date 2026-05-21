import 'package:destined_app/screens/upload_id_screen/upload_id_screen_controller.dart';
import 'package:destined_app/screens/widgets/button_widget.dart';
import 'package:destined_app/screens/widgets/primary_gradient.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:destined_app/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/app_functions.dart';
import '../../utils/app_images.dart';
import '../../utils/app_strings.dart';

class UploadIdScreen extends StatelessWidget {
  UploadIdScreen({super.key});

  final UploadIdScreenController controller = Get.put(
    UploadIdScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrimaryGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GetBuilder<UploadIdScreenController>(
              builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(Get.context!).pop(),
                          child: Image.asset(AppImages.backIcon, height: 20),
                        ),
                      ),
                      AppFunctions.height(30),
                      Text(
                        AppStrings.uploadId.tr,
                        style: AppTextStyle.whiteBold.copyWith(
                          fontSize: 36,
                          color: AppColors.darkBlueColor,
                        ),
                      ),
                      AppFunctions.height(12),
                      Text(
                        textAlign: TextAlign.center,
                        AppStrings.uploadIdSubString.tr,
                        style: AppTextStyle.whiteMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.lightPurpleSec,
                        ),
                      ),
                      AppFunctions.height(36),
                      GestureDetector(
                        onTap: () {
                          controller.toggleImage();
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: AppFunctions.borderRadius(50),
                            border: Border.all(color: AppColors.blueColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.idProof.tr,
                                style: AppTextStyle.whiteMedium.copyWith(
                                  color: AppColors.darkBlueColor,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.darkBlueColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppFunctions.height(30),
                      if (controller.showUploadImage == true &&
                          controller.image == null)
                        GestureDetector(
                          onTap: () {
                            controller.pickImage();
                          },
                          child: Image.asset(AppImages.uploadDocImage),
                        ),
                      if (controller.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          child: Image(
                            image: FileImage(controller.image!),
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      AppFunctions.height(46),
                      ButtonWidget(
                        isLoading: controller.isLoading,
                        buttonText: AppStrings.continu.tr,
                        onTap: () {
                          controller.updateUserInFirebase();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
