import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/scr/create_release_screen.dart';

class ReleaseSettingScrren extends StatelessWidget {
  const ReleaseSettingScrren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.blue,
            ],
          ),
        ),
        child: Stack(children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.10,
            left: 10,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.952,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // 그림자의 색상과 투명도
                      spreadRadius: 5, // 그림자의 확산 범위
                      blurRadius: 7, // 그림자의 흐림 정도
                      offset: const Offset(0, 3), // 그림자의 위치 조정 (가로, 세로)
                    ),
                  ],
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Release',
                              style: GoogleFonts.pacifico(
                                fontSize: 54,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                            ),
                            IconButton(
                              onPressed: () {
                                //Todo: 뒤로가기
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 120),
                            Text(
                              'Setting',
                              style: GoogleFonts.pacifico(
                                fontSize: 54,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      Get.to(() => const CreateReleaseScreen())!.then((value) {
                        // CreateReleaseScreen이 닫힌 후 실행되는 코드
                        if (value == true) {
                          // 화면이 성공적으로 닫혔을 때, 상위 화면 다시 그리기
                          AuthController.instance.update();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// Obx(() => AuthController.instance.isReleaseFirebase.value
//           ? IconButton(
//               icon: const Icon(
//                 Icons.close,
//                 size: 20,
//                 color: Colors.white38,
//               ),
//               onPressed: () {
//                 if (widget.selectedReleases != null &&
//                     widget.selectedReleases!.isNotEmpty) {
//                   // 변경된 부분

//                   Get.to(() => UpdateReleaseScreen(
//                       release: widget.selectedReleases!.first))?.then((value) {
//                     if (value == true) {
//                       setState(() {});
//                       ;
//                     }
//                   });
//                 }
//               },
//             )
//           : IconButton(
//               icon: const Icon(
//                 Icons.add,
//                 size: 30,
//                 color: Colors.white38,
//               ),
//               onPressed: () {
//                 Get.to(() => const CreateReleaseScreen())!.then((value) {
//                   // CreateReleaseScreen이 닫힌 후 실행되는 코드
//                   if (value == true) {
//                     // 화면이 성공적으로 닫혔을 때, 상위 화면 다시 그리기
//                     AuthController.instance.update();
//                   }
//                 });
//               },
//             ),),
