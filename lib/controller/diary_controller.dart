import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/model/diary_model.dart';
import 'package:navi_diary/scr/home_screen.dart';

class DiaryController {
  AuthController authController = AuthController.instance;

  // Firestore 데이터 서비스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Storage 서비스
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // // 이미지 URL을 저장할 리스트
  List<String> imageUrls = [];

  // Firebase에 새로운 일기 추가
  Future<void> addDiary(DiaryModel diaryModel) async {
    try {
      // 현재 로그인한 사용자의 UID 가져오기
      String userUid = authController.userData!['uid'];

      // Firebase Storage에 이미지 업로드
      for (String imagePath in diaryModel.photoURL!) {
        File compressedImage = await compressAndGetFile(File(imagePath));
        final ref = _storage.ref().child('images/${DateTime.now().toString()}');
        await ref.putFile(compressedImage);
        final url = await ref.getDownloadURL();
        print(url); //삭제
        imageUrls.add(url);
      }

      // 다운로드된 이미지 URL 목록을 DiaryModel의 photoURL 필드에 할당
      diaryModel.photoURL = imageUrls;

      // Firestore에 새로운 일기 추가
      DocumentReference diaryRef = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('diaries')
          .add(diaryModel.toMap());
      // 문서 ID를 사용자가 지정한 ID로 업데이트
      await diaryRef.update({'id': diaryRef.id});
      Get.to(() => HomeScreen());
    } catch (e) {
      print('일기 추가 오류: $e');
    }
  }

  // Firebase에서 일기 읽어오기
  Future<List<DiaryModel>> getDiaries() async {
    try {
      String userUid = authController.userData!['uid'];

      // Firestore에서 일기 읽어오기
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('diaries')
          .get();
      List<DiaryModel> diaries = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        diaries.add(DiaryModel.fromMap(doc.data() as Map<String, dynamic>));
      }

      return diaries;
    } catch (e) {
      print('일기 읽어오기 오류: $e');
      return [];
    }
  }

// Firebase에서 타이틀이나 날짜를 기준으로 일기들을 검색
  Future<List<DiaryModel>> getDiariesByTitleOrDate(String searchTerm) async {
    try {
      String userUid = authController.userData!['uid'];

      // Firestore에서 타이틀 또는 날짜를 기준으로 일기들 검색
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('diaries')
          .where('title', isEqualTo: searchTerm)
          .where('createdAt',
              isGreaterThanOrEqualTo: DateTime.parse(searchTerm))
          .get();

      // 검색된 일기들을 List<DiaryModel>로 변환
      List<DiaryModel> diaries = querySnapshot.docs
          .map((documentSnapshot) => DiaryModel.fromMap(
              documentSnapshot.data() as Map<String, dynamic>))
          .toList();

      return diaries;
    } catch (e) {
      print('일기 검색 오류: $e');
      return [];
    }
  }

  // Firebase에서 일기 업데이트
  Future<void> updateDiary(DiaryModel diaryModel) async {
    try {
      // 현재 로그인한 사용자의 UID 가져오기
      String userUid = authController.userData!['uid'];

      // Firebase Storage에 이미지 업로드
      List<String> updatedImageUrls = [];
      for (String imagePath in diaryModel.photoURL!) {
        File compressedImage = await compressAndGetFile(File(imagePath));
        final ref = _storage.ref().child('images/${DateTime.now().toString()}');
        await ref.putFile(compressedImage);
        final url = await ref.getDownloadURL();
        updatedImageUrls.add(url);
      }

      // Firestore에서 일기 업데이트
      await _firestore
          .collection('users')
          .doc(userUid)
          .collection('diaries')
          .doc(diaryModel.id)
          .update({
        'updatedAt': FieldValue.serverTimestamp(),
        'title': diaryModel.title,
        'contents': diaryModel.contents,
        'photoURL': updatedImageUrls,
      });
    } catch (e) {
      print('일기 업데이트 오류: $e');
    }
  }

  // Firebase에서 일기 삭제
  Future<void> deleteDiary(String diaryId) async {
    try {
      String userUid = authController.userData!['uid'];

      // Firestore에서 일기 삭제
      await _firestore
          .collection('users')
          .doc(userUid)
          .collection('diaries')
          .doc(diaryId)
          .delete();
    } catch (e) {
      print('일기 삭제 오류: $e');
    }
  }

// 갤러리에서 이미지 선택
  Future<void> pickMultiImage(List<XFile?> images) async {
    List<XFile?> pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages.isNotEmpty) {
      // null을 필터링하여 선택한 이미지를 이미지 리스트에 추가
      images.addAll(pickedImages);
    }
  }

  // 이미지 피커 이미지 삭제
  void deleteImage(int index, List<XFile?> images) {
    // 리스트에서 해당 인덱스의 이미지 삭제
    images.removeAt(index);
  }

  // 이미지 압축
  Future<File> compressAndGetFile(File file) async {
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

  // 이미지를 Firebase Storage에서 삭제하는 메서드
  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      // 이미지 URL에서 gs:// 형태의 Bucket 이름과 Path 추출
      RegExp regex = RegExp(r'gs://([^/]+)/(.*?)\?.*');
      Match? match = regex.firstMatch(imageUrl);

      if (match != null && match.groupCount == 2) {
        String bucket = match.group(1)!;
        String path = match.group(2)!;

        // Firebase Storage에서 해당 이미지의 참조를 얻어옴
        Reference imageRef = FirebaseStorage.instance.ref(bucket).child(path);

        // Firebase Storage에서 이미지 삭제
        await imageRef.delete();
      } else {
        print('이미지 URL 형식이 잘못되었습니다.');
      }
    } catch (e) {
      print('Firebase Storage에서 이미지 삭제 오류: $e');
    }
  }
}
