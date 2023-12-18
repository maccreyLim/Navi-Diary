import 'package:flutter/material.dart';
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
              top: 20,
              left: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Setting',
                        style: GoogleFonts.pacifico(
                          fontSize: 54,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40,
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
              bottom: MediaQuery.of(context).size.height * 0.07,
              left: MediaQuery.of(context).size.width * 0.13,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    //E-mail 문의 구현
                    print(widget.selectedReleases!.first.message); //데이타 사용법
                    _sendEmail();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.indigo),
                  ),
                  // 추가된 child 매개변수
                  child: Container(
                    alignment: Alignment.center, // Text를 가운데로 정렬
                    padding: EdgeInsets.symmetric(vertical: 8), // 상하 여백 조절
                    child: Text(
                      '     문의 및 제휴문의\nmaccrey@naver.com',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ), // 원하는 텍스트를 넣어주세요
                  // 나머지 위젯 속성들...
                ),
              ),
            ),
            Positioned(
                top: 100,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      TextButton(
                        onPressed: () {
                          Get.to(() => MypageScreen());
                        },
                        child: const Text(
                          '마이페이지',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const ReleaseSettingScrren());
                        },
                        child: const Text(
                          '출소일 설정',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const NoticeScreen());
                        },
                        child: Text(
                          '공지사항',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ))
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
          '기본 메일 앱을 사용할 수 없기 때문에 \n앱에서 바로 문의를 전송하기 어려운 상황입니다.\n\n사용하시는 메일을 이용하여\nmaccrey@naver.com으로 문의를 주세요!';
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
