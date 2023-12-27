import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/controller/diary_controller.dart';
import 'package:navi_diary/model/diary_model.dart';
import 'package:navi_diary/scr/change_password_screen.dart';
import 'package:navi_diary/scr/login_screen.dart';
import 'package:navi_diary/scr/member_terminator_notice.dart';

// ignore: must_be_immutable
class MypageScreen extends StatelessWidget {
  MypageScreen({super.key});
  late int diaryTotalCount; // diaryCount를 클래스 필드로 선언
  //Property
  final AuthController _authController = AuthController.instance;
  // DiaryController의 인스턴스 생성
  final DiaryController diaryController = DiaryController();

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
              top: 250.h,
              left: 20.w,
              child: Center(
                child: Container(
                  width: 1040.w,
                  height: 1680.h,
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
                        'My Page',
                        style: GoogleFonts.pacifico(
                          fontSize: 150.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 220.w,
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
              top: 300.h,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    Container(
                      width: 930.w,
                      height: 1440.h,
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "프로필이름",
                                    style: TextStyle(
                                        fontSize: 80.sp, color: Colors.white54),
                                  ),
                                  SizedBox(
                                    height: 40.h,
                                  ),
                                  Text(
                                    "${_authController.userData!["profileName"]}",
                                    style: TextStyle(
                                        fontSize: 80.sp, color: Colors.black54),
                                  ),
                                  SizedBox(
                                    height: 60.h,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "성          별",
                                    style: TextStyle(
                                        fontSize: 60.sp, color: Colors.white54),
                                  ),
                                  SizedBox(
                                    height: 40.h,
                                  ),
                                  Text(
                                    _authController.userData!["sex"] == 'male'
                                        ? "남성"
                                        : "여성",
                                    style: TextStyle(
                                        fontSize: 60.sp, color: Colors.black54),
                                  ),
                                  SizedBox(
                                    height: 60.h,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "보유포인트 : ",
                                    style: TextStyle(
                                        fontSize: 60.sp, color: Colors.white54),
                                  ),
                                  SizedBox(width: 40.h),
                                  Text(
                                    "${_authController.userData!["point"]}  point",
                                    style: TextStyle(
                                        fontSize: 60.sp, color: Colors.black54),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 60.h,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "가   입   일",
                                    style: TextStyle(
                                        fontSize: 60.sp, color: Colors.white54),
                                  ),
                                  SizedBox(
                                    height: 40.h,
                                  ),
                                  Text(
                                    "${_formatDate(_authController.userData!["createdAt"])}",
                                    style: TextStyle(
                                        fontSize: 60.sp, color: Colors.black54),
                                  ),
                                  SizedBox(
                                    height: 60.h,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "일기장사용량",
                                    style: TextStyle(
                                        fontSize: 60.sp, color: Colors.white54),
                                  ),
                                  SizedBox(height: 40.h),
                                  FutureBuilder<List<DiaryModel>>(
                                    future: diaryController.getDiaries(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child:
                                                CircularProgressIndicator()); // 데이터 로딩 중이면 로딩 표시기 표시
                                      } else if (snapshot.hasError) {
                                        return Text("에러 발생: ${snapshot.error}");
                                      } else {
                                        List<DiaryModel> diaries =
                                            snapshot.data ?? [];
                                        int diaryCount =
                                            diaries.length; // 일기 수를 가져옴
                                        diaryTotalCount = diaryCount;

                                        return Text(
                                          "회원님은 현재까지 $diaryCount개의 \n일기를 작성하셨습니다.",
                                          style: TextStyle(
                                              fontSize: 60.sp,
                                              color: Colors.black54),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
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
            ),
            Positioned(
              bottom: 220.h,
              left: 90.w,
              child: Container(
                height: 150.h,
                width: 900.w,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(
                      () => MemberTerminatorNotice(
                        diarytotalCount: diaryTotalCount.toString(),
                      ),
                    );
                    // Get.to(() => LoginScreen);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueGrey),
                  ),
                  child: Text(
                    "회원 탈퇴하기",
                    style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 50.h,
              left: 90.w,
              child: Container(
                height: 150.h,
                width: 900.w,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(
                      () => MemberTerminatorNotice(
                        diarytotalCount: diaryTotalCount.toString(),
                      ),
                    );
                    Get.to(() => const ChangePasswordScreen());
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.indigo),
                  ),
                  child: Text(
                    "비밀번호 변경",
                    style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(dateTime);
    return formattedDate;
  }
}
