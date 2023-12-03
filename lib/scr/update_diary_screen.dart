import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/%08diary_controller.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/model/diary_model.dart';
import 'package:navi_diary/scr/home_screen.dart';
import 'package:navi_diary/widget/show_toast.dart';
import 'package:image_picker/image_picker.dart';

class UpdateDiaryScreen extends StatefulWidget {
  final DiaryModel diary; // 단일 일기 모델

  const UpdateDiaryScreen({Key? key, required this.diary}) : super(key: key);

  @override
  State<UpdateDiaryScreen> createState() => _UpdateDiaryScreenState();
}

class _UpdateDiaryScreenState extends State<UpdateDiaryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController.instance;
  final DiaryController _diaryController = DiaryController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentsController = TextEditingController();

  List<XFile?> images = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    titleController.text = widget.diary.title;
    contentsController.text = widget.diary.contents;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      onHorizontalDragEnd: (details) {
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
              // 폼 컨테이너를 그리는 함수
              _buildFormContainer(),
              // 'Update a diary' 텍스트를 그리는 함수
              _buildTitleText(),
              // 저장 버튼을 그리는 함수
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 폼 컨테이너를 그리는 함수
  Widget _buildFormContainer() {
    return Positioned(
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
                  // 제목 입력 필드를 그리는 함수
                  _buildTitleTextField(),
                  const SizedBox(height: 10),
                  // 내용 입력 필드를 그리는 함수
                  _buildContentsTextField(),
                  // 카메라 아이콘 버튼을 그리는 함수
                  _buildCameraIconButton(),
                  const SizedBox(height: 14),
                  // 이미지 리스트 뷰를 그리는 함수
                  _buildImageListView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 'Update a diary' 텍스트를 그리는 함수
  Widget _buildTitleText() {
    return Positioned(
      top: 25,
      left: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update a diary',
            style: GoogleFonts.pacifico(
              fontSize: 54,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 저장 버튼을 그리는 함수
  Widget _buildSaveButton() {
    return Positioned(
      bottom: 40,
      left: 10,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
          ),
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
          onPressed: () async {
            // 일기 저장 함수 호출
            _saveDiary();
          },
          onLongPress: () {
            // 홈 화면으로 이동
            Get.to(() => const HomeScreen());
          },
        ),
      ),
    );
  }

  // 제목 입력 필드를 그리는 함수
  Widget _buildTitleTextField() {
    return TextFormField(
      controller: titleController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        icon: Icon(Icons.title),
        labelText: 'Title',
        hintText: 'Please write the title"',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required field';
        }
        return null;
      },
    );
  }

  // 내용 입력 필드를 그리는 함수
  Widget _buildContentsTextField() {
    return TextFormField(
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
          return 'Required field';
        }
        return null;
      },
    );
  }

  // 카메라 아이콘 버튼을 그리는 함수
  Widget _buildCameraIconButton() {
    return IconButton(
      onPressed: () async {
        // 이미지 가져오기
        await _diaryController.pickMultiImage(images);
        setState(() {});
      },
      icon: Icon(
        Icons.camera_alt_outlined,
        size: 40,
      ),
    );
  }

  // 이미지 리스트 뷰를 그리는 함수
  Widget _buildImageListView() {
    return Row(
      children: [
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width * 0.85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              if (index < images.length) {
                // 이미지 컨테이너를 그리는 함수
                return _buildImageContainer(index);
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }

  // 이미지 컨테이너를 그리는 함수
  Widget _buildImageContainer(int index) {
    return Container(
      height: 80,
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
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
              width: 100,
              height: 140,
              child: IconButton(
                onPressed: () {
                  // 이미지 삭제 함수 호출
                  deleteImage(index);
                },
                icon: Icon(
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
  }

  // 일기 저장 함수
  void _saveDiary() async {
    if (_formKey.currentState!.validate()) {
      if (_authController.userData != null) {
        _diaryController.updateDiary(
          DiaryModel(
            uid: _authController.userData!['uid'],
            createdAt: DateTime.now(),
            title: titleController.text,
            contents: contentsController.text,
            photoURL: images.map((image) => image!.path).toList(),
          ),
        );
        showToast('Diary updated successfully', 1);
      } else {
        showToast('User data not found', 2);
      }
    }
  }

  // 이미지 삭제 함수
  void deleteImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }
}
