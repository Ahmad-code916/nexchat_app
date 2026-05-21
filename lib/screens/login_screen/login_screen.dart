import 'package:destined_app/screens/login_screen/login_screen_controller.dart';
import 'package:destined_app/screens/personal_details_screen/personal_details_screen.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/app_functions.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_text_style.dart';
import '../widgets/button_widget.dart';
import '../widgets/primary_gradient.dart';
import '../widgets/text_form_field_widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginScreenController controller = Get.put(LoginScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrimaryGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GetBuilder<LoginScreenController>(
              builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(Get.context!).pop();
                          },
                          child: Text(
                            AppStrings.createAccount.tr,
                            style: AppTextStyle.whiteBold.copyWith(
                              color: AppColors.lightPurpleSec,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      AppFunctions.height(30),
                      Text(
                        AppStrings.login.tr,
                        style: AppTextStyle.whiteBold.copyWith(
                          fontSize: 36,
                          color: AppColors.darkBlueColor,
                        ),
                      ),
                      AppFunctions.height(12),
                      Text(
                        AppStrings.filldetails.tr,
                        style: AppTextStyle.whiteBold.copyWith(
                          fontSize: 16,
                          color: AppColors.lightPurple,
                        ),
                      ),
                      AppFunctions.height(70),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.email.tr,
                          style: AppTextStyle.pinkMedium,
                        ),
                      ),
                      AppFunctions.height(10),
                      TextFormFieldWidget(
                        controller: controller.emailController,
                      ),
                      AppFunctions.height(22),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.password.tr,
                          style: AppTextStyle.pinkMedium,
                        ),
                      ),
                      AppFunctions.height(10),
                      TextFormFieldWidget(
                        controller: controller.passwordController,
                        icon: Icon(Icons.remove_red_eye_outlined, size: 20),
                      ),
                      AppFunctions.height(40),
                      ButtonWidget(
                        isLoading: controller.isLoading,
                        buttonText: AppStrings.login,
                        onTap: () {
                          controller.Login();
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
