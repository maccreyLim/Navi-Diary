import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: Stack(
          children: [
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
          ],
        ),
      ),
    );
  }
}
