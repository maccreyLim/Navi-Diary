import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid; // 사용자 UID
  DateTime createdAt; // 계정 생성 일자
  String profilePhotoURL; // 프로필 사진 URL
  String profileName; // 프로필 이름
  String sex; // 성별
  bool isRelease; // 출소일 데이타 존재

  // 생성자
  User({
    required this.uid,
    required this.createdAt,
    required this.profilePhotoURL,
    required this.profileName,
    required this.sex,
    this.isRelease = false, // 기본값으로 false 설정
  });

  // User 객체를 Firestore 문서로 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'createdAt': Timestamp.fromDate(createdAt),
      'profilePhotoURL': profilePhotoURL,
      'profileName': profileName,
      'sex': sex,
      'isRelease': isRelease,
    };
  }

  // Firestore 문서에서 User 객체로 변환
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profilePhotoURL: data['profilePhotoURL'],
      profileName: data['profileName'],
      sex: data['sex'],
      isRelease: data['isRelease'],
    );
  }
}