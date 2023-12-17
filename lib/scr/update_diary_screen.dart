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
  final DiaryModel diary;

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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _initializeForm();
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
              _buildFormContainer(),
              _buildTitleText(),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

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
                  _buildTitleTextField(),
                  const SizedBox(height: 10),
                  _buildContentsTextField(),
                  _buildCameraIconButton(),
                  const SizedBox(height: 14),
                  _buildImageListView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            '수정',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
          onPressed: () async {
            // await showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return const Center(
            //       child: CircularProgressIndicator(),
            //     );
            //   },
            //   barrierDismissible: false,
            // );

            try {
              await _saveDiary(images);

              Get.offAll(() => const HomeScreen());
            } catch (e) {
              print('Error saving diary: $e');
            } finally {
              Get.back();
            }
          },
          onLongPress: () {
            Get.to(() => const HomeScreen());
          },
        ),
      ),
    );
  }

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

  Widget _buildCameraIconButton() {
    return IconButton(
      onPressed: _pickMultiImage,
      icon: Icon(
        Icons.camera_alt_outlined,
        size: 40,
      ),
    );
  }

  void _pickMultiImage() async {
    try {
      List<XFile>? selectedImages = await ImagePicker().pickMultiImage();

      if (selectedImages.isNotEmpty) {
        images.addAll(selectedImages);
        setState(() {});
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

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

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickMultiImage,
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

  Widget _buildImageContainer(int index) {
    return Container(
      height: 80,
      width: 80,
      // color: Colors.red,
      child: Stack(
        children: [
          Positioned(
            top: 6,
            child:
                // 이미지 표시
                ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: images[index]!.path.startsWith('http')
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
                  deleteImage(index);
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
  }

  Future _saveDiary(List<XFile?> updatedImages) async {
    if (_formKey.currentState!.validate()) {
      if (_authController.userData != null) {
        try {
          List<String> deletedImageUrls = widget.diary.photoURL!
              .where((existingImageUrl) => !updatedImages
                  .any((newImage) => newImage?.path == existingImageUrl))
              .toList();

          await _deleteImagesFromFirestore(deletedImageUrls);

          print('새 이미지 업로드 중...');
          List<String> newImageUrls = await _uploadNewImages(updatedImages);
          print('새 이미지 URL: $newImageUrls');

          await _diaryController.updateDiary(
            widget.diary,
            images,
            deletedImageUrls,
            newImageUrls,
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

  Future<List<String>> _uploadNewImages(List<XFile?> newImages) async {
    List<String> updatedImageUrls = [];

    for (XFile? newImage in newImages) {
      if (newImage != null) {
        if (newImage.path.startsWith('http')) {
          updatedImageUrls.add(newImage.path);
        } else {
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

  Future<void> _deleteImagesFromFirestore(List<String> deletedImageUrls) async {
    for (String deletedImageUrl in deletedImageUrls) {
      print('Firestore에서 이미지 삭제 중...');
      await _diaryController.deleteImageFromFirestore(
          widget.diary, deletedImageUrl);
    }
    print('이미지가 성공적으로 삭제되었습니다.');
  }

  Future<File> _compressAndGetFile(File file) async {
    int quality = 60;

    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      file.readAsBytesSync(),
      quality: quality,
    );

    File compressedFile = File('${file.path}_compressed.jpg')
      ..writeAsBytesSync(compressedBytes);

    return compressedFile;
  }

  void deleteImage(int index) async {
    try {
      String imageUrl = images[index]!.path;
      FirebaseStorage storage = FirebaseStorage.instance;
      await storage.refFromURL(imageUrl).delete();
      await _diaryController.deleteImageFromFirestore(widget.diary, imageUrl);

      setState(() {
        images.removeAt(index);
      });

      print('이미지가 성공적으로 삭제되었습니다.');
    } catch (error) {
      print('이미지 삭제 오류: $error');
    }
  }
}
