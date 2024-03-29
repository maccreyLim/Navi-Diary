import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/diary_controller.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/model/diary_model.dart';
import 'package:navi_diary/scr/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navi_diary/widget/show_toast.dart';
import 'package:navi_diary/widget/w.interstitle_ad_example.dart';

class CreateDiaryScreen extends StatefulWidget {
  const CreateDiaryScreen({super.key});

  @override
  State<CreateDiaryScreen> createState() => _CreateDiaryScreenState();
}

class _CreateDiaryScreenState extends State<CreateDiaryScreen> {
  // Property
  List<XFile?> images = []; // 이미지 File을 저장할 리스트
  DiaryController diaryController =
      DiaryController(); // DiaryController 인스턴스 생성
  final AuthController _authController = AuthController.instance;
  TextEditingController titleController =
      TextEditingController(); // Text controllers
  TextEditingController contentsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key
  final InterstitialAdController adController = InterstitialAdController();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      onHorizontalDragEnd: (details) {
        // 왼쪽에서 오른쪽으로 스와이프를 하면 전페이지로 이동
        if (details.primaryVelocity! > 0) {
          Get.back();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple,
                Colors.purpleAccent,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 300.h,
                left: 20.w,
                child: Center(
                  child: Container(
                    width: 1040.w,
                    height: 1450.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // 제목 입력 필드
                            Flexible(
                              child: TextFormField(
                                controller: titleController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.title),
                                  labelText: 'Title',
                                  hintText: 'Please write the title"',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '필수항목 입니다';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 60.h),
                            // 내용 입력 필드
                            TextFormField(
                              maxLength: 500,
                              maxLines: 6,
                              controller: contentsController,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.content_paste),
                                labelText: 'Contents',
                                hintText: 'Please write the contents"',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '필수항목 입니다';
                                }
                                return null;
                              },
                            ),
                            // 카메라 아이콘 버튼
                            IconButton(
                              onPressed: () async {
                                // 이미지 가져오기
                                await diaryController.pickMultiImage(images);
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.camera_alt_outlined,
                                size: 140.sp,
                              ),
                            ),
                            SizedBox(height: 40.h),
                            Row(
                              children: [
                                Container(
                                  height: 280.h,
                                  width: 1000.w,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index < images.length) {
                                        return Container(
                                          height: 100.h,
                                          width: 280.w,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: Container(
                                            height: 180.h,
                                            width: 180.w,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 50.h,
                                                  left: 40.w,
                                                  child:
                                                      // 이미지 표시
                                                      ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    child: Image.file(
                                                      File(images[index]!.path),
                                                      width: 220.w,
                                                      height: 220.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 8.h,
                                                  left: 120.w,
                                                  child: Container(
                                                    width: 270.w,
                                                    height: 440.h,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        // 이미지 삭제
                                                        diaryController
                                                            .deleteImage(
                                                                index, images);
                                                        setState(() {});
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.black54,
                                                        size: 70.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 140.h,
                left: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Write Diary',
                      style: GoogleFonts.pacifico(
                        fontSize: 120.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 200.w),
                    IconButton(
                      onPressed: () {
                        Get.off(() => const HomeScreen());
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 100.h,
                left: 20.w,
                child: SizedBox(
                  width: 1040.w,
                  height: 150.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                    onPressed: () async {
                      //전면광고

                      adController.loadAndShowAd();
                      // 제목과 내용이 비어있지 않은지 확인
                      if (titleController.text.isNotEmpty &&
                          contentsController.text.isNotEmpty) {
                        // 로딩 인디케이터 표시

                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          barrierDismissible:
                              false, // 사용자가 다이얼로그 외부를 터치해도 닫히지 않도록 설정
                        );

                        try {
                          // 이미지 업로드
                          List<String> imagePaths =
                              images.map((image) => image!.path).toList();
                          List<String> uploadedImageUrls =
                              await diaryController.uploadImages(imagePaths);

                          // 파이어베이스에 일기 저장
                          if (_authController.userData != null) {
                            await diaryController.addDiary(
                              DiaryModel(
                                uid: _authController.userData!['uid'],
                                createdAt: DateTime.now(),
                                title: titleController.text,
                                contents: contentsController.text,
                                photoURL: uploadedImageUrls,
                              ),
                            );
                            showToast('일기가 저장되었습니다.', 1);
                            Get.back(); // 로딩 인디케이터 닫기
                            // 홈으로 돌아온 후에 화면 다시 그리기
                            Get.off(() => const HomeScreen());
                          } else {
                            // _authController.userData가 null인 경우에 대한 처리
                            // 예를 들어, 에러 메시지를 표시하거나 다른 조치를 취할 수 있습니다.
                            showToast('사용자 데이터를 찾을 수 없습니다.', 2);
                            Get.back(); // 로딩 인디케이터 닫기
                          }
                        } catch (e) {
                          // 저장 중에 발생한 오류 처리
                          print('저장 중 오류 발생: $e');
                          showToast('오류가 발생했습니다. 다시 시도해주세요.', 2);
                          Get.back(); // 로딩 인디케이터 닫기
                        }
                      } else {
                        // 제목 또는 내용이 비어있을 때 메시지 표시
                        showToast('제목과 내용은 필수 항목입니다.', 2);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
