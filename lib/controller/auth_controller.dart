import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:navi_diary/scr/home_screen.dart';
import 'package:navi_diary/scr/login_screen.dart';
import 'package:navi_diary/scr/wellcome_join_message_scren.dart';
import 'package:navi_diary/widget/show_toast.dart';

class AuthController extends GetxController {
  //Firebase Authentication 인스턴스
  final FirebaseAuth authentication = FirebaseAuth.instance;
  //Firebase Firestore  인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //static AuthCotroller Type으로 GetX를 Global 함수로 설정
  static AuthController instance = Get.find();

  //_user.value.??? 로 전역적으로 사용가능
  late Rx<User?> _user;
  // Firestore에서 가져온 사용자 정보를 저장하는 Rx 변수
  late Rx<Map<String, dynamic>?> _userData;

  // 현재 사용자 정보를 반환하는 getter
  User? get currentUser => _user.value;
  // 현재 사용자 정보를 반환하는 getter
  Map<String, dynamic>? get userData => _userData.value;

  RxBool isReleaseFirebase = false.obs;

  @override
  void onReady() {
    super.onReady();

    // 현재 사용자 정보를 감시할 Rx 변수 초기화
    _user = Rx<User?>(authentication.currentUser);
    // Firestore에서 가져온 사용자 정보를 감시할 Rx 변수 초기화
    _userData = Rx<Map<String, dynamic>?>(null);

    // 사용자 정보가 변경될 때마다 스트림을 업데이트하도록 바인딩
    _user.bindStream(authentication.userChanges());

    // _user(로그인 상태)를 항상 감시
    // _moveToPage 함수는 사용자 정보에 따라 적절한 페이지로 이동하는 로직을 담당합니다.
    ever(_user, _moveToPage);
  }

//user가 LogOut되면 즉시 로그인으로 이동 , LogIn이면 홈으로 이동
  _moveToPage(User? user) {
    if (user == null || userData == null) {
      Get.off(() => const LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  //isReleaseFirebase 토글
  isReleaseChange(bool a) {
    isReleaseFirebase = a.obs;
  }

  // 회원가입
  Future<void> signUp(
      String email, String password, String profileName, String sex) async {
    try {
      await authentication.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 인증 E-mail 보내기
      await _user.value?.sendEmailVerification();

      // Firestore에 사용자 정보 저장
      await _firestore.collection('users').doc(_user.value?.uid).set(
        {
          'uid': _user.value?.uid,
          'createdAt': DateTime.now(),
          'profileName': profileName,
          'sex': sex,
        },
      );

      // 회원가입 성공 시, 여기에서 다른 동작을 추가할 수 있습니다.
      Get.to(() => const WellcomeJoinMessageScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      // FirebaseAuthException에서 발생한 특정 오류처리
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = '이미 사용 중인 이메일 주소입니다.';
          break;
        case 'network-request-failed':
          errorMessage = '네트워크 오류가 발생했습니다.';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 주소입니다.';
          break;
        case 'user-not-found':
          errorMessage = '사용자를 찾을 수 없습니다.';
          break;
        // 추가적인 FirebaseAuthException 코드에 대한 처리
        default:
          errorMessage = '알 수 없는 오류가 발생했습니다: ${e.code}';
      }
      // 오류 메시지를 보여주는 토스트 또는 다른 방식의 알림을 사용할 수 있습니다.
      showToast(errorMessage, 2);

      // 회원가입 실패 시, 여기에서 다른 동작을 추가할 수 있습니다.
    }
  }

  //로그인
  Future<void> signIn(String email, String password) async {
    try {
      await authentication.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 로그인이 성공한 경우, 이메일 인증 여부 확인
      User? user = authentication.currentUser;
      if (user != null && user.emailVerified == false) {
        // 이메일이 인증되지 않았다면 인즈 안내페이지로 이동
        Get.to(() => const WellcomeJoinMessageScreen());
      }

      // Firestore에서 사용자 정보 가져오기
      DocumentSnapshot<Map<String, dynamic>> userDocument =
          await _firestore.collection('users').doc(user?.uid).get();
      if (userDocument.exists) {
        // 사용자 정보가 존재하는 경우
        Map<String, dynamic> userData = userDocument.data()!;
        // _userData 업데이트
        _userData.value = userData;
        // 사용자 정보가 로드되면 홈 화면으로 이동
        Get.offAll(() => const HomeScreen());
        print("User Data: ${_userData.value!['uid']}");
      } else {
        // 사용자 정보가 없는 경우
        print("사용자 정보가 없습니다.");
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: $e");
      String errorMessage = "로그인 되었습니다.";
      // FirebaseAuthException에서 발생한 특정 오류처리
      switch (e.code) {
        case 'email-not-verified':
          errorMessage = '이메일이 인증되지 않았습니다. 인증 이메일을 다시 보내시겠습니까?';
          // 사용자에게 확인 다이얼로그 또는 메시지를 표시하여 인증 이메일 재전송 기능 추가
          Get.to(() => const WellcomeJoinMessageScreen());
          break;
        case 'user-not-found':
          errorMessage = '등록되지 않은 이메일 주소입니다.';
          break;
        case 'wrong-password':
          errorMessage = '잘못된 비밀번호입니다.';
          break;
        case 'network-request-failed':
          errorMessage = '네트워크 오류가 발생했습니다. 인터넷 연결을 확인하세요.';
          break;
        default:
          errorMessage = '로그인 중 오류가 발생했습니다.';
          break;
      }
      // 오류 메시지를 보여주는 토스트 또는 다른 방식의 알림을 사용할 수 있습니다.
      showToast(errorMessage, 2);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // Firebase Authentication을 사용하여 로그아웃
      await authentication.signOut();

      // 로그아웃 성공 시 _user 값을 갱신
      _user.value = null;

      // 로그아웃 성공 시 추가적인 작업이 필요하다면 여기에 추가
    } catch (e) {
      // 로그아웃 중 에러 발생 시
      print('로그아웃 중 오류 발생: $e');
      // 에러를 사용자에게 알리거나 추가적인 조치를 취할 수 있음
      // 예를 들어, 에러 메시지를 사용자에게 보여주는 토스트 메시지 표시 등
    }
  }

  // 회원 탈퇴
  Future<void> deleteAccount() async {
    try {
      // 현재 사용자 정보를 가져옴
      User? user = authentication.currentUser;

      // Firestore에서 사용자 데이터 가져오기
      DocumentSnapshot<Map<String, dynamic>> userDocument =
          await _firestore.collection('users').doc(user?.uid).get();

      // 사용자 데이터가 있는 경우
      if (userDocument.exists) {
        // 사용자 정보를 Rx 변수에 저장
        _userData.value = userDocument.data();
      }

      // Firestore에서 사용자 데이터 삭제 (필요한 경우)
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
      }

      // 사용자 계정 삭제
      await user?.delete();

      // 계정 삭제 후 로그인 화면으로 이동
      Get.off(() => const LoginScreen());

      // 계정 삭제 이후 추가 작업이 필요한 경우 여기에 수행
    } catch (e) {
      // 오류 처리
      print('계정 삭제 중 오류 발생: $e');
      // 사용자에게 오류 메시지 표시 또는 필요한 추가 작업 수행
    }
  }
}
