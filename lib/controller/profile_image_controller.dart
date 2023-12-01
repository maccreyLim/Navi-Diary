// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:navi_diary/controller/auth_controller.dart';

// ProfileImageController (){
//   //property
//   final CollectionReference _usersCollection =
//       FirebaseFirestore.instance.collection('users');
//   final FirebaseStorage storage = FirebaseStorage.instance;
//   //AuthController의 인스턴스를 얻기
//   AuthController authController = AuthController.instance;
//   XFile? _pickedFile;

//   _getPhotoLibraryImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       // 이미지를 압축
//       File compressedFile = await compressAndGetFile(File(pickedFile.path));

//       setState(
//         () {
//           // XFile을 그대로 사용합니다.
//           _pickedFile = XFile(compressedFile.path);
//         },
//       );

//       Reference ref = storage.ref('profileImage').child('$().jpg');
//       TaskSnapshot uploadTask = await ref.putFile(File(_pickedFile!.path));
//       authController.userData['photoUrl'] =
//           await uploadTask.ref.getDownloadURL();
//     } else {
//       if (kDebugMode) {
//         ShowToast('이미지를 선택해주세요', 1);
//       }
//     }
//   }

//   Future<File> compressAndGetFile(File file) async {
//     // 압축 품질 설정 (0에서 100까지)
//     int quality = 60;

//     List<int> compressedBytes = await FlutterImageCompress.compressWithList(
//       file.readAsBytesSync(),
//       quality: quality,
//     );

//     // 압축된 바이트를 새 파일에 저장
//     File compressedFile = File('${file.path}_compressed.jpg')
//       ..writeAsBytesSync(compressedBytes);

//     return compressedFile;
//   }
// }
