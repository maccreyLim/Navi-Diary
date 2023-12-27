import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/scr/login_screen.dart';
import 'package:validators/validators.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  // Property
  // Text controllers
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController pnController = TextEditingController();
  //obscureText 패스워드 보이게 하는 옵션
  bool _obscureText = true;

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//AuthController의 인스턴스를 얻기
  AuthController authController = AuthController.instance;

  //Gender
  String? gender = "male";

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
                      height: 1100.h,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(40.0)),
                        color: Colors.white.withOpacity(0.25),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
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
                              SizedBox(height: 20.h),
                              Flexible(
                                child: TextFormField(
                                    controller: pnController,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.pets_outlined),
                                      labelText: 'Profile Name',
                                      hintText: 'Enter your Profile Name',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '프로필이름은 필수항목입니다';
                                      }
                                      return null;
                                    }),
                              ),
                              SizedBox(height: 25.h),
                              Row(
                                children: [
                                  Radio(
                                    value: 'male',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value.toString();
                                      });
                                    },
                                  ),
                                  const Text('남성'),
                                  SizedBox(width: 20.w),
                                  Radio(
                                    value: 'female',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value.toString();
                                      });
                                    },
                                  ),
                                  const Text('여성'),
                                ],
                              ),
// Todo: 추후 프로필 이미지 추가 기능 구현
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //     ClipRRect(
                              //       borderRadius: BorderRadius.circular(15.0),
                              //       child: Image.asset('assets/image.jpeg',
                              //           width: 50,
                              //           height: 50,
                              //           fit: BoxFit.cover),
                              //     ),
                              //     const SizedBox(width: 50),
                              //     const Icon(
                              //       Icons.photo_camera,
                              //       color: Colors.white54,
                              //     ),
                              //     TextButton(
                              //       onPressed: () {},
                              //       child: const Text(
                              //         'Upload Profile Picture',
                              //         style: TextStyle(color: Colors.white54),
                              //       ),
                              //     ),
                              //   ],
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 300.h,
                  left: 50.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
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
                                    'Join',
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
                          SizedBox(
                            width: 500.w,
                            // height: MediaQuery.of(context).size.height * 0.16.w,
                          ),
                          IconButton(
                            onPressed: () {
                              //Todo: 뒤로가기
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
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
                                //validate Check!!
                                if (_formKey.currentState!.validate()) {
                                  // Sign Up 버튼이 눌렸을 때 수행할 작업을 여기에 추가
                                  authController.signUp(
                                    idController.text,
                                    pwController.text,
                                    pnController.text,
                                    gender.toString(),
                                  );
                                }
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 60.sp),
                              ),
                            ),
                          ),
                          // const SizedBox(height: 30),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width * 0.9,
                          //   height: MediaQuery.of(context).size.height * 0.07,
                          //   child: ElevatedButton(
                          //     style: ButtonStyle(
                          //       backgroundColor:
                          //           MaterialStateProperty.all<Color>(
                          //         const Color.fromARGB(255, 213, 140, 231),
                          //       ),
                          //     ),
                          //     onPressed: () {
                          //       Get.offAll(const LoginScreen());
                          //     },
                          //     child: const Text(
                          //       '< Create an account later.',
                          //       style: TextStyle(
                          //           color: Colors.white, fontSize: 18),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
