import 'package:cached_network_image/cached_network_image.dart';
import 'package:destined_app/screens/user_details_screen/user_details_screen_controller.dart';
import 'package:destined_app/screens/widgets/primary_gradient.dart';
import 'package:destined_app/screens/widgets/users_details_head_row.dart';
import 'package:destined_app/services/app_functions.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:destined_app/utils/app_images.dart';
import 'package:destined_app/utils/app_strings.dart';
import 'package:destined_app/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDetailsScreen extends StatelessWidget {
  UserDetailsScreen({super.key});

  final UserDetailsScreenController controller = Get.put(
    UserDetailsScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrimaryGradient(
        child: GetBuilder<UserDetailsScreenController>(
          builder: (context) {
            return controller.isLoading == true
                ? Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UsersDetailsHeadRow(
                      firstColor: AppColors.pinkColorSec,
                      secondColor: AppColors.lightPink,
                      child: Image.asset(AppImages.backIconWhite, height: 20),
                      onTapChild: () => Navigator.of(Get.context!).pop(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                width: double.infinity,
                                color: Color(0xff21154D),
                                child: CachedNetworkImage(
                                  imageUrl: controller.userData?.imageUrl ?? "",
                                  height: 300,
                                ),
                              ),
                            ),
                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.userData?.name ?? "",
                                              style: AppTextStyle.whiteMedium
                                                  .copyWith(
                                                    fontSize: 32,
                                                    color:
                                                        AppColors.darkBlueColor,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color:
                                                          AppColors.lightPurple,
                                                    ),
                                                    AppFunctions.width(8),
                                                    RichText(
                                                      text: TextSpan(
                                                        text:
                                                            AppFunctions.calculateDistance(
                                                              UserBaseController
                                                                  .userData
                                                                  .lat!,
                                                              UserBaseController
                                                                  .userData
                                                                  .lng!,
                                                              controller
                                                                  .userData!
                                                                  .lat!,
                                                              controller
                                                                  .userData!
                                                                  .lng!,
                                                            ),
                                                        children: [
                                                          TextSpan(
                                                            text: 'km away',
                                                          ),
                                                        ],
                                                        style: AppTextStyle
                                                            .whiteMedium
                                                            .copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors
                                                                      .lightPurple,
                                                            ),
                                                      ),
                                                    ),
                                                    AppFunctions.width(16),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.favorite_sharp,
                                                      color:
                                                          AppColors.lightPurple,
                                                    ),
                                                    AppFunctions.width(8),
                                                    Text(
                                                      controller
                                                          .userData!
                                                          .likedBy!
                                                          .length
                                                          .toString(),
                                                      style: AppTextStyle
                                                          .whiteMedium
                                                          .copyWith(
                                                            fontSize: 14,
                                                            color:
                                                                AppColors
                                                                    .lightPurple,
                                                          ),
                                                    ),
                                                    AppFunctions.width(16),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    AppFunctions.height(25),
                                    /*SizedBox(
                                      height: 40,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: controller.choiceList.length,
                                        itemBuilder: (context, index) {
                                          final data =
                                              controller.choiceList[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 15,
                                            ),
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                controller
                                                    .selectChoiceListOption(
                                                      index,
                                                    );
                                              },
                                              child: Column(
                                                spacing: 8,
                                                children: [
                                                  Text(
                                                    data,
                                                    style: AppTextStyle
                                                        .whiteMedium
                                                        .copyWith(
                                                          color:
                                                              controller.selectedChoice ==
                                                                      data
                                                                  ? AppColors
                                                                      .purpleColor
                                                                  : AppColors
                                                                      .pinkColor,
                                                        ),
                                                  ),
                                                  Container(
                                                    height: 3,
                                                    width: 70,
                                                    color:
                                                        controller.selectedChoice ==
                                                                data
                                                            ? AppColors
                                                                .whiteColor
                                                            : AppColors
                                                                .transparentColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),*/
                                    Text(
                                      'Pictures',
                                      style: AppTextStyle.whiteMedium.copyWith(
                                        color: AppColors.pinkColor,
                                      ),
                                    ),
                                    AppFunctions.height(30),
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics: BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        primary: true,
                                        itemCount:
                                            controller
                                                .userData!
                                                .profileImages!
                                                .length,
                                        itemBuilder: (context, index) {
                                          final user =
                                              controller
                                                  .userData!
                                                  .profileImages![index];
                                          return Container(
                                            height: 90,
                                            width: 90,
                                            margin: EdgeInsets.only(right: 20),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                                color: AppColors.lightPurpleSec,
                                              ),
                                              borderRadius:
                                                  AppFunctions.borderRadius(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  AppFunctions.borderRadius(12),
                                              child: CachedNetworkImage(
                                                // width: double.infinity,
                                                fit: BoxFit.fill,
                                                imageUrl: user,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.image),
                                                placeholder:
                                                    (context, url) => Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    AppFunctions.height(30),
                                    Text(
                                      AppStrings.interest,
                                      style: AppTextStyle.whiteMedium.copyWith(
                                        color: AppColors.pinkColor,
                                      ),
                                    ),
                                    AppFunctions.height(16),
                                    SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            controller
                                                .userData!
                                                .interestList!
                                                .length,
                                        itemBuilder: (context, index) {
                                          final interest =
                                              controller
                                                  .userData!
                                                  .interestList![index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 15,
                                            ),
                                            child: Text(
                                              '$interest,',
                                              style: AppTextStyle.whiteRegular
                                                  .copyWith(
                                                    color:
                                                        AppColors.purpleColor,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
          },
        ),
      ),
    );
  }
}
