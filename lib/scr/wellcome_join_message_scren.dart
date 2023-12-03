import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/scr/login_screen.dart';

class WellcomeJoinMessageScreen extends StatefulWidget {
  const WellcomeJoinMessageScreen({super.key});

  @override
  State<WellcomeJoinMessageScreen> createState() =>
      _WellcomeJoinMessageScreenState();
}

class _WellcomeJoinMessageScreenState extends State<WellcomeJoinMessageScreen> {
  AuthController _authController = AuthController.instance;
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
                Positioned(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(40.0)),
                        color: Colors.white.withOpacity(0.25),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(28.0),
                        child: Column(
                          children: [
                            Text(
                              'wellcome',
                              style: TextStyle(
                                  fontSize: 42,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 30),
                            Text(
                              '회원 가입을 해주셔서 감사합니다.\n\n-- 중 요 -- \n\n가입시 입력하신  E-mail주소로 \n인증메일을 보내드렸습니다.\n인증메일을 확인하시고 \n로그인은 반드시 인증절차를 \n완료하셔야 가능합니다.',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.15,
                  left: MediaQuery.of(context).size.width * 0.08,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.purple),
                      ),
                      onPressed: () {
                        _authController.signOut();
                        Get.to(() => const LoginScreen());
                      },
                      child: const Text(
                        '확 인',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
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
