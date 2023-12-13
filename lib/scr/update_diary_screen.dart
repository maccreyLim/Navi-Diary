import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/diary_controller.dart';
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

  // Firebase Storage 인스턴스
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    // 기존 이미지로 images를 초기화합니다.
    images = widget.diary.photoURL!
        .map((path) => XFile(path))
        .toList(growable: true);
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
          setState(() {});
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
          child: const Text(
            '저장',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
          onPressed: () async {
            // 일기 저장 함수 호출
            _saveDiary(images);

            Get.back();
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
      onPressed: _pickMultiImage, // 이미지 추가 함수로 변경
      icon: Icon(
        Icons.camera_alt_outlined,
        size: 40,
      ),
    );
  }

  void _pickMultiImage() async {
    try {
      // ImagePicker를 사용하여 여러 이미지를 선택합니다.
      List<XFile>? selectedImages = await ImagePicker().pickMultiImage();

      // 선택된 이미지를 기존 리스트에 추가합니다.
      if (selectedImages.isNotEmpty) {
        images.addAll(selectedImages);
        setState(() {});
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  // 이미지 리스트 뷰를 그리는 함수
  Widget _buildImageListView() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width * 0.85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildImageContainer(index);
        },
      ),
    );
  }

  // 이미지 추가 버튼을 그리는 함수
  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickMultiImage, // 이미지 추가 함수 호출
      child: Container(
        height: 80,
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 이미지 컨테이너를 그리는 함수
  Widget _buildImageContainer(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child:
              images[index]!.path.startsWith('http') // 기존 이미지는 네트워크 이미지로 가정합니다.
                  ? Image.network(
                      images[index]!.path,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(images[index]!.path),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
        ),
        Positioned(
          bottom: 2,
          left: 2,
          child: GestureDetector(
            onTap: () {
              // 이미지 삭제 함수 호출
              deleteImage(index);
            },
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveDiary(List<XFile?> updatedImages) async {
    if (_formKey.currentState!.validate()) {
      if (_authController.userData != null) {
        try {
          // 업데이트된 이미지 목록에서 기존 이미지 목록을 제외한 이미지 목록을 가져옴
          List<String> deletedImageUrls = widget.diary.photoURL!
              .where((existingImageUrl) => !updatedImages
                  .any((newImage) => newImage?.path == existingImageUrl))
              .toList();

          // Firestore에서 삭제된 이미지 제거
          await _deleteImagesFromFirestore(deletedImageUrls);

          // 새로 추가된 이미지를 Firebase Storage에 업로드
          List<String> newImageUrls = await _uploadNewImages(updatedImages);
          print(newImageUrls);

          // Firestore에서 일기 업데이트
          await _diaryController.updateDiary(
              widget.diary, // 기존 DiaryModel
              images,
              deletedImageUrls,
              newImageUrls // 삭제된 이미지 목록
              );

          showToast('일기가 성공적으로 업데이트되었습니다', 1);
        } catch (e) {
          print('일기 업데이트 오류: $e');
          showToast('일기 업데이트 중 오류가 발생했습니다', 2);
        }
      } else {
        showToast('사용자 데이터를 찾을 수 없습니다', 2);
      }
    }
  }

// 새로 추가된 이미지를 Firebase Storage에 업로드하는 메서드
  Future<List<String>> _uploadNewImages(List<XFile?> newImages) async {
    List<String> updatedImageUrls = [];

    for (XFile? newImage in newImages) {
      if (newImage != null) {
        if (newImage.path.startsWith('http')) {
          // If the image is from a network URL, use it directly
          updatedImageUrls.add(newImage.path);
        } else {
          // If the image is local, compress and upload it
          File compressedImage = await _compressAndGetFile(File(newImage.path));

          final ref =
              _storage.ref().child('images/${DateTime.now().toString()}');
          await ref.putFile(compressedImage);

          final url = await ref.getDownloadURL();
          updatedImageUrls.add(url);
        }
      }
    }

    return updatedImageUrls;
  }

// Firestore에서 이미지 삭제
  Future<void> _deleteImagesFromFirestore(List<String> deletedImageUrls) async {
    for (String deletedImageUrl in deletedImageUrls) {
      await _diaryController.deleteImageFromFirestore(
          widget.diary, deletedImageUrl);
    }
  }

// 이미지 압축
  Future<File> _compressAndGetFile(File file) async {
    // 압축 품질 설정 (0에서 100까지)
    int quality = 60;

    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      file.readAsBytesSync(),
      quality: quality,
    );

    // 압축된 바이트를 새 파일에 저장
    File compressedFile = File('${file.path}_compressed.jpg')
      ..writeAsBytesSync(compressedBytes);

    return compressedFile;
  }

  // 이미지 삭제 함수
  void deleteImage(int index) async {
    try {
      // 이미지 URL 가져오기
      String imageUrl = images[index]!.path;

      // Firebase Storage 인스턴스 생성
      FirebaseStorage storage = FirebaseStorage.instance;

      // StorageReference를 사용하여 이미지 삭제
      await storage.refFromURL(imageUrl).delete();

      // Firestore에서도 해당 이미지 삭제
      await _diaryController.deleteImageFromFirestore(widget.diary, imageUrl);

      // 이미지 리스트에서 해당 이미지 제거
      setState(() {
        images.removeAt(index);
      });

      // 삭제 성공 메시지 또는 다른 작업 추가
      print('이미지가 성공적으로 삭제되었습니다.');
    } catch (error) {
      // 삭제 중 오류 발생 시 오류 메시지 출력
      print('이미지 삭제 오류: $error');
    }
  }

  // _uploadNewImages 메서드 추가
}
