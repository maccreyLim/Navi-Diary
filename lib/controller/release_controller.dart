import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/model/release_model.dart';

class ReleaseController {
  //Firebase Firestore의 인스턴스 얻기
  FirebaseFirestore db = FirebaseFirestore.instance;
//AuthController의 인스턴스 얻기
  AuthController authController = AuthController.instance;
  // 정적 getter로 인스턴스에 접근할 수 있도록 함
  static ReleaseController get instance => _instance;
  // private static 인스턴스
  static final ReleaseController _instance = ReleaseController._internal();

  // private 생성자
  ReleaseController._internal();

//파이어베이스 Create
  Future<String> createRelease(ReleaseModel model) async {
    // 'release' 컬렉션에 대한 참조를 가져옵니다.
    CollectionReference collectionRef = db
        .collection('users')
        .doc(authController.currentUser!.uid)
        .collection('release');

    try {
      // 모델 데이터를 컬렉션에 추가하고 문서 참조를 얻습니다.
      DocumentReference docRef = await collectionRef.add(model.toMap());

      // 문서의 'id' 필드를 문서 ID로 업데이트합니다.
      String id = docRef.id;
      await docRef.update({'id': id});

      // 성공 메시지를 반환합니다.
      return '예제 생성이 되었습니다.';
    } catch (e) {
      // 오류를 처리하고 해당 오류를 던집니다.
      print('Example 생성 에러 : $e');
      rethrow;
    }
  }

// 파이어베이스 Read
  Future<List<ReleaseModel>> getReleases() async {
    // 사용자의 'release' 컬렉션에 대한 참조 생성
    CollectionReference collectionRef = db
        .collection('users')
        .doc(authController.currentUser?.uid)
        .collection('release');

    try {
      // 컬렉션에서 문서들을 가져옴
      QuerySnapshot querySnapshot = await collectionRef.get();
      print("Release Data = ${querySnapshot}");
      // 컬렉션에 문서가 있는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 데이터가 있을 때만 isReleaseChange 호출
        authController.isReleaseChange(true);
      }

      // 문서들을 ReleaseModel로 변환하여 리스트로 반환
      List<ReleaseModel> releases = querySnapshot.docs
          .map(
              (doc) => ReleaseModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return releases;
    } catch (e) {
      // 오류 발생 시 로그 출력 후 다시 던지기
      print('출소 정보 가져오기 오류: $e');
      rethrow;
    }
  }

  Stream<List<ReleaseModel>> getReleasesStream() {
    CollectionReference collectionRef = db
        .collection('users')
        .doc(authController.currentUser?.uid)
        .collection('release');

    // snapshot을 ReleaseModel로 변환하는 함수
    Stream<List<ReleaseModel>> stream = collectionRef.snapshots().map(
      (querySnapshot) {
        return querySnapshot.docs.map(
          (doc) {
            return ReleaseModel.fromMap(doc.data() as Map<String, dynamic>);
          },
        ).toList();
      },
    );

    return stream;
  }

//파이어베이스 Update
  Future<String> updateRelease(ReleaseModel model) async {
    CollectionReference collectionRef = db
        .collection('users')
        .doc(authController.currentUser?.uid)
        .collection('release');

    try {
      await collectionRef.doc(model.id).update(model.toMap());
      return '출소 정보가 성공적으로 업데이트되었습니다.';
    } catch (e) {
      print('Update Release Error: $e');
      rethrow;
    }
  }

//파이어베이스 Delete
  Future<String> deleteRelease(String releaseId) async {
    CollectionReference collectionRef = db
        .collection('users')
        .doc(authController.currentUser?.uid)
        .collection('release');

    try {
      await collectionRef.doc(releaseId).delete();
      return '출소 정보가 성공적으로 삭제되었습니다.';
    } catch (e) {
      print('Delete Release Error: $e');
      rethrow;
    }
  }
}
