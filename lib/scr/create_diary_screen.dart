import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/%08diary_controller.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/model/diary_model.dart';
import 'package:navi_diary/scr/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navi_diary/widget/show_toast.dart';

class CreateDiaryScreen extends StatefulWidget {
  const CreateDiaryScreen({super.key});

  @override
  State<CreateDiaryScreen> createState() => _CreateDiaryScreenState();
}

class _CreateDiaryScreenState extends State<CreateDiaryScreen> {
  // Property
// 이미지 File을 저장할 리스트
  List<XFile?> images = [];
  // DiaryController 인스턴스 생성
  DiaryController diaryController = DiaryController();
  AuthController _authController = AuthController.instance;
  // Text controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController contentsController = TextEditingController();
  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                top: 70,
                left: 10,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.952,
                    height: MediaQuery.of(context).size.height * 0.70,
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
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextFormField(
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
                            const SizedBox(height: 10),
                            TextFormField(
                              maxLength: 400,
                              maxLines: 8,
                              controller: contentsController,
                              keyboardType: TextInputType.emailAddress,
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
                            IconButton(
                              onPressed: () async {
                                // 이미지 가져오기
                                await diaryController.pickMultiImage(images);
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                              ),
                            ),
                            SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                    // color: Colors.black,
                                    height: 100,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < images.length) {
                                          return Container(
                                            // color: Colors.red,
                                            height: 80,
                                            width: 100,
                                            margin: EdgeInsets.only(right: 10),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Image.file(
                                                    File(images[index]!.path),
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 18,
                                                  left: 20,
                                                  child: Container(
                                                    // color: Colors.amber,
                                                    width: 100,
                                                    height: 140,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        // 이미지 삭제
                                                        diaryController
                                                            .deleteImage(
                                                                index, images);
                                                        setState(() {});
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.black54,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    )),
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
                top: 25,
                left: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Write a diary',
                      style: GoogleFonts.pacifico(
                        fontSize: 54,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                    onPressed: () async {
                      // 파이어베이스에 일기 저장
                      if (_authController.userData != null) {
                        diaryController.addDiary(
                          DiaryModel(
                            uid: _authController.userData!['uid'],
                            createdAt: DateTime.now(),
                            title: titleController.text,
                            contents: contentsController.text,
                            photoURL:
                                images.map((image) => image!.path).toList(),
                          ),
                        );
                        showToast('${_authController.userData?['uid']}', 1);
                      } else {
                        // _authController.userData가 null인 경우에 대한 처리
                        // 예를 들어, 에러 메시지를 표시하거나 다른 조치를 취할 수 있습니다.
                        showToast('사용자 데이터를 찾을 수 없습니다.', 2);
                      }
                    },
                    onLongPress: () {
                      Get.to(() => const HomeScreen());
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
