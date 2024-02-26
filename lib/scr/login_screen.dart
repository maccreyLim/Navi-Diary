import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/scr/find_password_screen.dart';
import 'package:navi_diary/scr/join_screen.dart';
import 'package:validators/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Property
  // Text controllers
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  String userInfo = ""; //user으ㅣ 정보를 저장하기 위한 변수

  static final storage =
      new FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //obscureText 패스워드 보이게 하는 옵션
  bool _obscureText = true;

  //AuthController의 인스턴스를 얻기
  AuthController authController = AuthController.instance;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    userInfo = await storage.read(key: "login") ?? ""; // null이면 빈 문자열로 설정
    print(userInfo);

    //user의 정보가 있다면 바로 로그아웃 페이지로 넝어가게 합니다.
    // if (userInfo != null) {
    authController.signOut();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    pwController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Center(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple,
                  Colors.purpleAccent,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 1020.w,
                      height: 720.h,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(40.0)),
                        color: Colors.white.withOpacity(0.25),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18.w, 110.h, 18.w, 10.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: TextFormField(
                                  controller: idController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.email),
                                    labelText: 'E-Mail',
                                    hintText: 'Enter your e-mail',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '이메일 주소를 입력 해주세요.';
                                    } else if (!isEmail(value)) {
                                      return "이메일 형식에 맞지 않습니다.";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Flexible(
                                child: TextFormField(
                                  controller: pwController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                      icon: const Icon(Icons.lock),
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      suffixIcon: Semantics(
                                        label: _obscureText
                                            ? '비밀번호 표시'
                                            : '비밀번호 숨김',
                                        child: IconButton(
                                          icon: Icon(
                                            _obscureText
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.black54,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                        ),
                                      )),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "비밀번호를 입력 해주세요.";
                                    } else if (value.isEmpty) {
                                      return "패스워드에는 빈칸이 들어갈 수 없습니다.";
                                    } else if (value.length > 12) {
                                      return "패스워드의 최대길이는 12자입니다.";
                                    } else if (value.length < 6) {
                                      return "패스워드의 최소길이는 6자입니다.";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 60.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: Colors.white54,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      //Todo: 파이어베이스 Password찾기 구현
                                      Get.to(() => FindPasswordScreen());
                                    },
                                    child: const Text(
                                      'Find Your Password',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 480.h,
                  left: 80.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please',
                        style: GoogleFonts.pacifico(
                          fontSize: 120.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(width: 140.w),
                          Text(
                            '     log in',
                            style: GoogleFonts.pacifico(
                              fontSize: 120.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 100.h,
                  left: 40.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: 1000.w,
                            height: 150.h,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.purple),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  // write 함수를 통하여 key에 맞는 정보를 적게 됩니다.
                                  //{"login" : "id id_value password password_value"}
                                  //와 같은 형식으로 저장이 된다고 생각을 하면 됩니다.
                                  await storage.write(
                                      key: "login",
                                      value: "id " +
                                          idController.text.toString() +
                                          " " +
                                          "password " +
                                          pwController.text.toString());
                                  //Todo: 파이어베이스 Login 구현
                                  await authController.signIn(
                                    idController.text,
                                    pwController.text,
                                  );
                                  print(authController.userData);
                                }
                              },
                              child: Text(
                                'LogIn',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 60.sp),
                              ),
                            ),
                          ),
                          SizedBox(height: 60.h),
                          SizedBox(
                            width: 1000.w,
                            height: 150.h,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                    const Color.fromARGB(255, 213, 140, 231)),
                              ),
                              onPressed: () {
                                Get.to(
                                  () => const JoinScreen(),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(
                                      milliseconds: 1500), // 1.5초로 수정
                                );
                              },
                              child: Text(
                                'Create an Account',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 60.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
