import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseScheduleModel {
  final String id;
  final String title;
  final int year;
  final int month;
  final int day;
  final DateTime date;
  final String time;
  final bool finish;
  final DateTime createdAt;

  FirebaseScheduleModel({
    required this.id,
    required this.title,
    required this.year,
    required this.month,
    required this.day,
    required this.date,
    required this.time,
    required this.finish,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'month': month,
      'day': day,
      'date': date,
      'time': time,
      'finish': finish,
      'createdAt': createdAt,
    };
  }

  factory FirebaseScheduleModel.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseScheduleModel(
      id: doc.id,
      title: data['title'] ?? '',
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      day: data['day'] ?? 0,
      date: data['date'] != null
          ? DateTime(
              data['year'] ?? 0,
              data['month'] ?? 0,
              data['day'] ?? 0,
            )
          : DateTime.now(), // date가 null일 경우 현재 날짜를 사용
      time: data['time'] ?? '',
      finish: data['finish'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
