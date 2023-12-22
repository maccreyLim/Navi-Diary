import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/controller/notice_controller.dart';
import 'package:navi_diary/model/notice_model.dart';
import 'package:navi_diary/scr/notice_screen.dart';
import 'package:navi_diary/widget/show_toast.dart';

class CreateNoticeScreen extends StatefulWidget {
  CreateNoticeScreen({Key? key}) : super(key: key);

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  //Property
  final _formkey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentsController = TextEditingController();
  final AuthController _authController = AuthController.instance;

//TextEditingController dispose
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentsController.dispose();
  }

//저장 버튼
  Widget saveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
          ),
          onPressed: () async {
            NoticeModel announcetList = NoticeModel(
              uid: _authController.userData!['uid'],
              profileName: _authController.userData!['profileName'] ?? "",
              isLiked: false,
              likeCount: 0,
              title: titleController.text, // 입력 필드의 값 사용
              content: contentsController.text, // 입력 필드의 값 사용
              createdAt: DateTime.now(),
              id: "", // 문서 아이디
            );

            await NoticeController().createNotice(announcetList);

            showToast('게시물이 성공적으로 저장되었습니다.', 1);
            setState(() {
              Get.off(NoticeScreen());
            });
          },
          child: const Text(
            'SAVE',
            style: TextStyle(fontSize: 24, color: Colors.white54),
          ),
        ),
      ),
    );
  }

//입력폼( 컨트롤러 , 텍스트필트 이름,텍스트필드 라인수)
  Widget inputText(TextEditingController name, String nametext, int line) {
    return Row(
      children: [
        Text(
          '${nametext}',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.63,
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            controller: name,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              hintText: "",
            ),
            keyboardType:
                TextInputType.multiline, // Use multiline keyboard type
            maxLines: line, // Allow multiple lines
            validator: (value) {
              if (value!.isEmpty) {
                return "${nametext}을 입력해주세요";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ' Create',
                                style: GoogleFonts.pacifico(
                                  fontSize: 54,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.38,
                              ),
                              IconButton(
                                onPressed: () {
                                  // 뒤로가기
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
                              const SizedBox(width: 40),
                              Text(
                                'Notice',
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
              bottom: 40,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  Form(
                    key: _formkey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          inputText(titleController, "제목", 1),
                          SizedBox(
                            height: 5,
                          ),
                          inputText(contentsController, "내용", 8),
                          SizedBox(height: 180),
                          SizedBox(
                              height: 60,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: saveButton()),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
