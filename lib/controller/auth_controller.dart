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
    if (user == null) {
      //로그아웃이 되어 있는 상태에서 페이지이동 구현
      Get.off(() => const LoginScreen());
    } else {
      //로그인이 되어 있는 상태에서 페이지이동 구현
      Get.offAll(() => const HomeScreen());
    }
  }

  //isReleaseFirebase 토글
  isReleaseChange() {
    isReleaseFirebase.toggle();
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
        // 이메일이 인증되지 않았다면 예외 던지기
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: '이메일이 인증되지 않았습니다.',
        );
      }

      // Firestore에서 사용자 정보 가져오기
      DocumentSnapshot<Map<String, dynamic>> userDocument =
          await _firestore.collection('users').doc(user?.uid).get();
      if (userDocument.exists) {
        // 사용자 정보가 존재하는 경우
        Map<String, dynamic> userData = userDocument.data()!;
        // _userData 업데이트
        _userData.value = userData;
        print("User Data: $userData");
      } else {
        // 사용자 정보가 없는 경우
        print("사용자 정보가 없습니다.");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      // FirebaseAuthException에서 발생한 특정 오류처리
      switch (e.code) {
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

      // 로그아웃 성공 시 추가적인 작업이 필요하다면 여기에 추가
    } catch (e) {
      // 로그아웃 중 에러 발생 시
      print('로그아웃 중 오류 발생: $e');
      // 에러를 사용자에게 알리거나 추가적인 조치를 취할 수 있음
      // 예를 들어, 에러 메시지를 사용자에게 보여주는 토스트 메시지 표시 등
    }
  }
}
