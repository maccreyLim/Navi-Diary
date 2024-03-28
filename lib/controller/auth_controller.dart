import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  // Firebase Storage 인스턴스
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static final storage =
      new FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화

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
  bool isLogin = false; //로그인 상태 확인

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
  _moveToPage(User? user) async {
    if (user == null) {
      // 로그아웃 상태일 때 로그인 화면으로 이동
      Get.off(() => const LoginScreen());
    } else {
      if (user.emailVerified) {
        // 이메일이 인증된 경우에만 사용자 데이터 가져오기 시도
        Map<String, dynamic>? userData = await _getUserData(user.uid);

        if (userData != null) {
          // 사용자 데이터가 존재하면 업데이트하고 홈 화면으로 이동
          _userData.value = userData;
          Get.offAll(() => const HomeScreen());
        } else {
          // 사용자 데이터가 없는 경우
          print("사용자 정보가 없습니다.");
        }
      } else {
        // 이메일이 인증되지 않은 경우에는 이메일 인증 안내페이지로 이동
        Get.off(() => const WellcomeJoinMessageScreen());
      }
    }
  }

  // 사용자 데이터 가져오기
  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      // Firestore에서 사용자 데이터 가져오기
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      // 사용자 데이터가 존재하면 Map으로 변환하여 반환
      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>?;
      } else {
        // 사용자 데이터가 없는 경우 null 반환
        return null;
      }
    } catch (e) {
      // 사용자 데이터를 가져오는 중에 오류 발생 시
      print('사용자 데이터를 가져오는 중 오류 발생: $e');
      return null;
    }
  }

  //isReleaseFirebase 토글
  isReleaseChange(bool a) {
    isReleaseFirebase = a.obs;
  }

  // //Login 및 로그아웃 변경을 위한 스위칭
  void loginChange() {
    isLogin = !isLogin;

    update();
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
          'point': 1000,
          'isAdmin': false,
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
        signOut();
        // 이메일이 인증되지 않았다면 인증 안내페이지로 이동
        Get.to(() => const WellcomeJoinMessageScreen());
      } else {
        // Firestore에서 사용자 정보 가져오기
        DocumentSnapshot<Map<String, dynamic>> userDocument =
            await _firestore.collection('users').doc(user?.uid).get();
        if (userDocument.exists) {
          // 사용자 정보가 존재하는 경우
          Map<String, dynamic> userData = userDocument.data()!;
          // _userData 업데이트
          _userData.value = userData;
          // 사용자 정보가 존재하는 경우
          loginChange();
          // 사용자 정보가 로드되면 홈 화면으로 이동
          Get.offAll(() => const HomeScreen());
          print("User Data: ${_userData.value!['uid']}");
        } else {
          // 사용자 정보가 없는 경우
          print("사용자 정보가 없습니다.");
        }
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
      //delete 함수를 통하여 key 이름이 login인것을 완전히 폐기 시켜 버린다.
      //이를 통하여 다음 로그인시에는 로그인 정보가 없어 정보를 불러 올 수가 없게 된다.
      storage.delete(key: "login");
      // Firebase Authentication을 사용하여 로그아웃
      await authentication.signOut();

      // 로그아웃 성공 시 _user 값을 갱신
      _user.value = null;
      // 로그아웃 성공 시 추가적인 작업이 필요하다면 여기에 추가
      loginChange();
    } catch (e) {
      // 로그아웃 중 에러 발생 시
      print('로그아웃 중 오류 발생: $e');
      // 에러를 사용자에게 알리거나 추가적인 조치를 취할 수 있음
      // 예를 들어, 에러 메시지를 사용자에게 보여주는 토스트 메시지 표시 등
    }
  }

//회원어카운트 삭제
  Future<void> deleteAccount() async {
    try {
      // 현재 사용자 정보를 가져옴
      User? user = authentication.currentUser;
      // Firestore에서 참조를 만듭니다.
      final userRef = _firestore.collection('users').doc(user?.uid);

      // 최근에 로그인한 상태인지 확인
      if (user != null && user.metadata.lastSignInTime != null) {
        // Firestore에서 사용자 데이터 가져오기
        DocumentSnapshot<Map<String, dynamic>> userDocument =
            await _firestore.collection('users').doc(user.uid).get();

        // 사용자 데이터가 있는 경우
        if (userDocument.exists) {
          // 사용자 정보를 Rx 변수에 저장
          _userData.value = userDocument.data();
        }

        // Firestore에서 사용자 데이터 삭제 (필요한 경우)
        //파이어스토어 삭제
        await userRef.delete();
        //파이어 스토어 하위 파일 삭제
        await _deleteCollection(userRef.collection('diaries'));
        await _deleteCollection(userRef.collection('release'));
        //파이어스토리지 하위 삭제
        await deleteUserDataFromStorage(user.uid);

        // 사용자 계정 삭제
        await user.delete();

        // 계정 삭제 후 로그인 화면으로 이동
        Get.off(() => const LoginScreen());

        // 계정 삭제 이후 추가 작업이 필요한 경우 여기에 수행
      } else {
        // 최근에 로그인하지 않은 경우에 대한 처리
        // 예를 들어, 사용자에게 로그인을 유도하는 메시지를 표시하거나, 다시 로그인 페이지로 이동
        showToast("다시 로그인한 후에 시도해주세요.", 2);
        Get.off(() => const LoginScreen());
      }
    } catch (e) {
      // 오류 처리
      print('계정 삭제 중 오류 발생: $e');
      // 사용자에게 오류 메시지 표시 또는 필요한 추가 작업 수행
    }
  }

//스토리지 전체 삭제
  Future<void> deleteUserDataFromStorage(String userId) async {
    try {
      // Firebase Storage에서 데이터에 대한 참조를 만듭니다.
      final ref = _storage.ref().child('images/$userId');

      // 디렉터리 내의 모든 파일에 대한 참조 목록을 가져옵니다.
      final ListResult result = await ref.listAll();

      // 모든 파일을 삭제합니다.
      await Future.forEach(result.items, (Reference item) async {
        await item.delete();
      });

      // 데이터를 삭제합니다.
      await ref.delete();
      print("회원탈퇴 이미지가 삭제되었습니다.");
    } catch (e) {
      // 오류를 처리합니다. 예를 들어 오류 메시지를 출력할 수 있습니다.
      print('Firebase Storage에서 데이터를 삭제하는 중 오류 발생: $e');
    }
  }

//콜렉션 삭제
  Future<void> _deleteCollection(
      CollectionReference collectionReference) async {
    // 컬렉션에 대한 모든 문서를 가져옵니다.
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collectionReference.get() as QuerySnapshot<Map<String, dynamic>>;

    // 만약 문서가 하나도 없으면 함수를 종료합니다.
    if (snapshot.docs.isEmpty) {
      print('컬렉션에 문서가 없습니다.');
      return;
    }

    // 각 문서에 대해 삭제 작업을 수행합니다.
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  //패스워드 찾기
  Future<void> forgotPassword(String email) async {
    // 사용자 인증
    final auth = FirebaseAuth.instance;
    // 비밀번호 재설정 메일 전송
    await auth.sendPasswordResetEmail(email: email);
  }

//패스워드 변경
  Future<void> changePassword(
      String email, String currentPassword, String newPassword) async {
    try {
      // 현재 로그인한 사용자 가져오기
      User? user = FirebaseAuth.instance.currentUser;

      // 현재 사용자가 null이 아니면서 이메일이 일치할 경우에만 비밀번호 변경 수행
      if (user != null && user.email == email) {
        // 사용자의 현재 비밀번호를 사용하여 로그인
        AuthCredential credential = EmailAuthProvider.credential(
            email: email, password: currentPassword);
        await user.reauthenticateWithCredential(credential);

        // 새 비밀번호로 변경
        await user.updatePassword(newPassword);

        print('비밀번호가 성공적으로 변경되었습니다.');
      } else {
        print('사용자 정보가 일치하지 않습니다.');
      }
    } catch (e) {
      print('비밀번호 변경 중 오류 발생: $e');
    }
  }
}
