import 'package:destined_app/screens/archived_screen/archived_screen_controller.dart';
import 'package:destined_app/screens/chat_screen/chat_screen.dart';
import 'package:destined_app/screens/widgets/message_widget.dart';
import 'package:destined_app/screens/widgets/primary_gradient.dart';
import 'package:destined_app/services/user_base_controller.dart';
import 'package:destined_app/utils/app_colors.dart';
import 'package:destined_app/utils/app_images.dart';
import 'package:destined_app/utils/app_strings.dart';
import 'package:destined_app/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArchivedScreen extends StatelessWidget {
  ArchivedScreen({super.key});

  final controller = Get.put(ArchivedScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrimaryGradient(
        // firstColor: Colors.black,
        // secondColor: Colors.black,
        child: GetBuilder<ArchivedScreenController>(
          builder: (context) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Row(
                      spacing: 15,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(Get.context!).pop();
                          },
                          child: Image.asset(AppImages.backIcon, height: 20),
                        ),
                        Text(
                          'Archived Chats',
                          style: AppTextStyle.whiteMedium.copyWith(
                            color: AppColors.darkBlueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: AppColors.lightPurpleFour),
                  if (controller.isLoading == true)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.purpleColorNew,
                        ),
                      ),
                    )
                  else if (controller.threadList.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          AppStrings.noChatFound.tr,
                          style: AppTextStyle.whiteBold.copyWith(
                            fontSize: 25,
                            color: AppColors.purpleColorNew,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ListView.builder(
                          itemCount: controller.threadList.length,
                          itemBuilder: (context, index) {
                            final thread = controller.threadList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Get.to(
                                    () => ChatScreen(),
                                    arguments: {
                                      'threadId': thread.id,
                                      'user': thread.userDetails,
                                      'threadModel': thread,
                                    },
                                  );
                                },
                                child: MessageWidget(
                                  isShowCount:
                                      thread.senderId ==
                                              UserBaseController.userData.uid
                                          ? false
                                          : true,
                                  name: thread.userDetails?.name ?? "",
                                  lastMessage: thread.lastMessage ?? "",
                                  image: thread.userDetails?.imageUrl ?? "",
                                  dateTime:
                                      '${thread.lastMessageTime!.hour}:${thread.lastMessageTime!.minute}',
                                  count: '3',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
