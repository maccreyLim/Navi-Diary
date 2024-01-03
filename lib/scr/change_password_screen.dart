import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/scr/setting_screen.dart';
import 'package:validators/validators.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  //Property
  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //TextEditingController
  final TextEditingController _email = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();

  //obscureText 패스워드 보이게 하는 옵션
  bool _obscureText = true;
  //AuthController의 인스턴스를 얻기
  final AuthController _authController = AuthController.instance;

  @override
  void dispose() {
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.blue,
            ],
          ),
        ),
        child: Stack(
          children: [
            //네이밍
            Positioned(
              top: 420.h,
              left: 50.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ' Change',
                                style: GoogleFonts.pacifico(
                                  fontSize: 120.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 400.w,
                              ),
                              IconButton(
                                onPressed: () {
                                  // 뒤로가기
                                  Get.to(() => const SettingScreen(
                                        selectedReleases: [],
                                      ));
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 120.w),
                              Text(
                                ' Password',
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
                    ],
                  ),
                ],
              ),
            ),
            //화면구성
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 1020.w,
                  height: 1000.h,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(40.0)),
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
                              controller: _email,
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
                          SizedBox(height: 100.h),
                          Flexible(
                            child: TextFormField(
                              controller: _currentPassword,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                icon: const Icon(Icons.lock),
                                labelText: 'Current Password',
                                hintText: 'Enter your current password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black26,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "현재 비밀번호를 입력 해주세요.";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 100.h),
                          Flexible(
                            child: TextFormField(
                              controller: _newPassword,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                icon: const Icon(Icons.lock),
                                labelText: 'New Password',
                                hintText: 'Enter your new password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black26,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "새로운 비밀번호를 입력 해주세요.";
                                } else if (value.isEmpty) {
                                  return "패스워드에는 빈칸이 들어갈 수 없습니다.";
                                } else if (value.length > 12) {
                                  return "패스워드의 최대 길이는 12자입니다.";
                                } else if (value.length < 6) {
                                  return "패스워드의 최소 길이는 6자입니다.";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 60.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100.h,
              left: 20.w,
              height: 150.h,
              width: 1040.w,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _authController.changePassword(
                        _email.text, _currentPassword.text, _newPassword.text);
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.indigo),
                ),
                child: Text(
                  '패스워드 변경',
                  style: TextStyle(fontSize: 50.sp, color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
