import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/controller/release_calculator_firebase.dart';
import 'package:navi_diary/model/release_model.dart';
import 'package:navi_diary/scr/home_screen.dart';
import 'package:navi_diary/widget/show_toast.dart';

class UpdateReleaseScreen extends StatefulWidget {
  final ReleaseModel release;
  const UpdateReleaseScreen({Key? key, required this.release})
      : super(key: key);

  @override
  State<UpdateReleaseScreen> createState() => _UpdateReleaseScreenState();
}

class _UpdateReleaseScreenState extends State<UpdateReleaseScreen> {
  //Property
  //'widget.release'를 반환하는 getter
  ReleaseModel get releaseData => widget.release;
  //AuthController의 인스턴스를 얻기
  AuthController authController = AuthController.instance;

  // Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Delete 방법 안내
  bool isdelete = false;
  //datePicket 변수
  late DateTime selectedDate; // 초기 선택 날짜
  var years = 0;
  var months = 0;

  final yearformatter = DateFormat('yyyy');
  final monthformatter = DateFormat('MM');
  final dayformatter = DateFormat('dd');
  DateTime releaseDate = DateTime(2023, 11, 14); // 초기 출소일

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.release.name;
    messageController.text = widget.release.message;
    selectedDate = releaseData.inputDate;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
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
                top: 70,
                left: 10,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.952,
                    height: MediaQuery.of(context).size.height * 0.70,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // 그림자의 색상과 투명도
                            spreadRadius: 5, // 그림자의 확산 범위
                            blurRadius: 7, // 그림자의 흐림 정도
                            offset: const Offset(0, 3), // 그림자의 위치 조정 (가로, 세로)
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30)),
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.title),
                                labelText: 'Name',
                                hintText: 'Please write the Name"',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '필수항목 입니다'; // Return the error message if the field is empty
                                }
                                return null; // Return null if the input is valid
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 0),
                                const Text(
                                  '입소일',
                                  style: TextStyle(fontSize: 16),
                                ),
                                // SizedBox(width: 2),
                                Text(
                                  '${yearformatter.format(selectedDate)} 년 ${monthformatter.format(selectedDate)} 월 ${dayformatter.format(selectedDate)} 일',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.date_range_outlined),
                                  onPressed: () => _selectDate(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 42),
                                const Text(
                                  '형량 설정',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 26),
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          // 여기서는 release 객체의 years 필드에 직접 값을 할당하는 것으로 가정합니다.
                                          releaseData.years = int.parse(value);
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '필수';
                                        }
                                        return null; // 유효한 경우에는 null을 반환
                                      },
                                      decoration: const InputDecoration(
                                        hintText: '년',
                                      ),
                                      // release.years가 null이 아니면 초기값으로 표시합니다.
                                      initialValue:
                                          releaseData.years.toString()),
                                ),
                                const SizedBox(width: 30),
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          releaseData.months = int.parse(value);
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '필수';
                                        }
                                        return null; // 유효한 경우에는 null을 반환
                                      },
                                      decoration: const InputDecoration(
                                        hintText: '개월',
                                      ),
                                      // release.years가 null이 아니면 초기값으로 표시합니다.
                                      initialValue:
                                          releaseData.months.toString()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              maxLength: 400,
                              maxLines: 10,
                              controller: messageController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.content_paste),
                                  labelText: 'Message',
                                  hintText: 'Please write the Message"',
                                  border: OutlineInputBorder()),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '필수항목 입니다'; // Return the error message if the field is empty
                                }
                                return null; // Return null if the input is valid
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 10,
                child: Text(
                  'Update Release',
                  style: GoogleFonts.pacifico(
                    fontSize: 54,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 50,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    child: isdelete == false
                        ? const Text(
                            'Delete',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white60),
                          )
                        : const Text(
                            '삭제를 원하시면 버튼을 길게 눌러주세요',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white60),
                          ),
                    onPressed: () {
                      //Todo : 삭제방법 안내
                      setState(() {
                        isdelete = !isdelete;
                      });
                    },
                    onLongPress: () {
                      //Todo : 파이어베이스에 출소일 삭제 구현
                      print('삭제되었습니다.');
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60),
                    ),
                    onPressed: () async {
                      //Todo : 파이어베이스에 일기 저장 구현

                      if (_formKey.currentState?.validate() ?? false) {
                        final _release = ReleaseFirestore();
                        await _release.updateRelease(
                          ReleaseModel(
                            id: releaseData.id,
                            name: nameController.text,
                            inputDate: selectedDate,
                            years: years,
                            months: months,
                            message: messageController.text,
                          ),
                        );
                        showToast('저장되었습니다.', 1);
                        Get.back();
                      }
                    },
                    onLongPress: () {
                      Get.to(() => const HomeScreen());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
