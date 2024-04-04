import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/model/schedule_model.dart';
import 'package:navi_diary/widget/show_toast.dart';

class ScheduleFirestore {
  final controller = Get.put(AuthController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create (데이터 추가)
  Future<void> addSchedule(FirebaseScheduleModel schedule) async {
    try {
      await _firestore
          .collection('Users')
          .doc(controller.userData!['uid'])
          .collection('schedules')
          .add(schedule.toMap());
      showToast('일정이 등록되었습니다.', 1);
    } catch (e) {
      showToast('일정등록에 실패했습니다.', 1);
    }
  }

  // Read (데이터 읽기)
  Stream<List<FirebaseScheduleModel>> getScheduleList() {
    return _firestore
        .collection('Users')
        .doc(controller.userData!['uid'])
        .collection('schedules')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((QueryDocumentSnapshot document) {
        return FirebaseScheduleModel.fromFirestore(document);
      }).toList();
    });
  }

  // Update (데이터 업데이트)
  Future<void> updateSchedule(String id, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('Users')
          .doc(controller.userData!['uid'])
          .collection('schedules')
          .doc(id)
          .update(data);
    } catch (e) {
      print('Error updating schedule: $e');
    }
  }

  // Delete (데이터 삭제)
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(controller.userData!['uid'])
          .collection(
              'schedules') // 'schedules'는 파이어베이스 컬렉션의 이름입니다. 필요에 따라 수정하세요.
          .doc(scheduleId) // 스케줄의 고유 ID
          .delete();
    } catch (e) {
      showToast('일정을 삭제하지 못했습니다.', 1);
    }
  }
}

class ShowToast {}
