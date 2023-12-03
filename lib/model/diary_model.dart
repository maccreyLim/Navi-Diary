import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  String? id; //문서 ID
  String uid; // 사용자 ID
  DateTime? createdAt; //문서 생성날짜
  DateTime? updatedAt; //문서 수정 날짜
  String title; // 일기장 제목
  String contents; //일기장 내용
  List<String>? photoURL; // 사진 URL

  //생성자
  DiaryModel({
    this.id,
    required this.uid,
    this.createdAt,
    this.updatedAt,
    required this.title,
    required this.contents,
    this.photoURL,
  });

  // DiaryModel 객체를 Firebase 문서로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'title': title,
      'contents': contents,
      'photoURL': photoURL,
    };
  }

  // Firebase 문서에서 DiaryModel 객체로 변환
  factory DiaryModel.fromMap(Map<String, dynamic> data) {
    return DiaryModel(
      id: data['id'],
      uid: data['uid'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      title: data['title'],
      contents: data['contents'],
      photoURL: (data['photoURL'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
