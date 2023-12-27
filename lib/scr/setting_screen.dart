import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:navi_diary/model/release_model.dart';
import 'package:navi_diary/scr/my_page_screen.dart';
import 'package:navi_diary/scr/notice_screen.dart';
import 'package:navi_diary/scr/release_setting_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key, required this.selectedReleases});
  final List<ReleaseModel>? selectedReleases;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  //Property
  // AuthController _authController = AuthController.instance;

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
              top: 230.h,
              left: 20.w,
              child: Center(
                child: Container(
                  width: 1040.w,
                  height: 1790.h,
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
              left: 40.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Setting',
                        style: GoogleFonts.pacifico(
                          fontSize: 150.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 400.w,
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
                ],
              ),
            ),
            Positioned(
              bottom: 120.h,
              left: 100.w,
              child: Container(
                width: 880.w,
                height: 150.h,
                child: ElevatedButton(
                  onPressed: () {
                    //E-mail 문의 구현
                    _sendEmail();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.indigo),
                  ),
                  // 추가된 child 매개변수
                  child: Container(
                    alignment: Alignment.center, // Text를 가운데로 정렬
                    padding:
                        const EdgeInsets.symmetric(vertical: 8), // 상하 여백 조절
                    child: Text(
                      '광고 보기',
                      style: TextStyle(fontSize: 50.sp, color: Colors.white),
                    ),
                  ), // 원하는 텍스트를 넣어주세요
                  // 나머지 위젯 속성들...
                ),
              ),
            ),
            Positioned(
              top: 200.h,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 100.h),
                    TextButton(
                      onPressed: () {
                        Get.to(() => MypageScreen());
                      },
                      child: Text(
                        '마이페이지',
                        style: TextStyle(color: Colors.white, fontSize: 60.sp),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const ReleaseSettingScrren());
                      },
                      child: Text(
                        '출소일 설정',
                        style: TextStyle(color: Colors.white, fontSize: 60.sp),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const NoticeScreen());
                      },
                      child: Text(
                        '공지사항',
                        style: TextStyle(color: Colors.white, fontSize: 60.sp),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    TextButton(
                      onPressed: () {
                        _sendEmail();
                      },
                      child: Text(
                        '문의 및 제휴',
                        style: TextStyle(color: Colors.white, fontSize: 60.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail() async {
    final Email email = Email(
        body:
            '아래 내용을 함께 보내주시면 큰 도움이 됩니다.\n 아이디 : \n OS 버전: \n기기 : \n 아래에 문의 내용을 적어주세요.\n',
        subject: 'Navi diary 문의 및 제휴문의',
        recipients: ['maccrey@naver.com'],
        cc: ['navi.project2023@gmail.com'],
        isHTML: false);

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      String title =
          '기본 메일 앱을 사용할 수 없기 때문에 \n앱에서 바로 문의를 전송하기 어려운 상태입니다.\n\n사용하시는 메일을 이용하여\nmaccrey@naver.com으로 문의부탁드립니다.';
      Get.defaultDialog(
        title: '안내',
        content: Text(title),
        textConfirm: '확인',
        confirmTextColor: Colors.white54,
        onConfirm: Get.back,
      );
    }
  }
}
