import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/scr/login_screen.dart';

// ignore: must_be_immutable
class MemberTerminatorNotice extends StatefulWidget {
  final String diarytotalCount;

  const MemberTerminatorNotice({Key? key, required this.diarytotalCount})
      : super(key: key);

  @override
  State<MemberTerminatorNotice> createState() => _MemberTerminatorNoticeState();
}

class _MemberTerminatorNoticeState extends State<MemberTerminatorNotice> {
  final AuthController authController = AuthController.instance;

  bool isPress = false;

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
              top: 70.h,
              left: 50.w,
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
                                'Terminator',
                                style: GoogleFonts.pacifico(
                                  fontSize: 120.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 290.w,
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
                              const SizedBox(width: 80),
                              Text(
                                'Notice',
                                style: GoogleFonts.pacifico(
                                  fontSize: 120.sp,
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
              top: 360.h,
              right: 20.w,
              left: 20.w,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: 1000.w,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          '${authController.userData!['profileName']}님',
                          style: TextStyle(
                              fontSize: 100.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        SizedBox(height: 60.h),
                        Text(
                          "우리 커뮤니티를 떠나기로 결정하셔서 \n안타깝게 생각합니다.\n계정 해지를 진행하기 전에 중요한 정보를 안내해 드리고자 합니다.\n",
                          style: TextStyle(
                              fontSize: 50.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54),
                        ),
                        Text(
                          "-- 데이터 손실 주의 안내 --\n",
                          style: TextStyle(
                              fontSize: 70.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54),
                        ),
                        Text(
                          '회원님은 현재 소중한 ${widget.diarytotalCount}개의 일기장이 \n존재합니다.',
                          style: TextStyle(
                              fontSize: 50.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          '계정 해지 시 계정과 관련된 모든 데이터,\n일기 및 저장된 모든 정보가 영구적으로\n삭제됩니다.\n이 작업은 되돌릴 수 없으며 손실된 \n데이터는 복구가 불가능합니다.',
                          style: TextStyle(
                              fontSize: 50.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: MediaQuery.of(context).size.height * 0.06,
                left: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPress = !isPress;
                        });
                      },
                      onLongPress: () async {
                        await AuthController.instance.deleteAccount();
                        Get.to(const LoginScreen());
                      },
                      style: ButtonStyle(
                        backgroundColor: isPress
                            ? MaterialStateProperty.all<Color>(Colors.red)
                            : MaterialStateProperty.all<Color>(Colors.blueGrey),
                      ),
                      child: Text(
                        isPress
                            ? '회원을 탈퇴를 원하시면\n     길게 눌러주세요'
                            : '정말 회원을 탈퇴하시겠습니까?',
                        style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54),
                      )),
                ))
          ],
        ),
      ),
    );
  }
}
