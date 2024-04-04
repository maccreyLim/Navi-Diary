import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/controller/schedule_firebase.dart';
import 'package:navi_diary/model/schedule_model.dart';
import 'package:navi_diary/scr/scheduleList.dart';
import 'package:navi_diary/widget/w.banner_ad.dart';
import 'package:navi_diary/widget/w.interstitle_ad_example.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
//Property
  final scheduleFirestore = ScheduleFirestore();
  final controller = Get.put(AuthController());
  TextEditingController scheduleTextController = TextEditingController();
  // Firebase Firestore 인스턴스 생성
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final InterstitialAdController adController = InterstitialAdController();
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime(
    //유저가 선택한 날짜
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now(); //선택한 날짜
  TimeOfDay selectedTime = TimeOfDay.now();

  get bottomNavigationBar => null; // 현재의 날짜
//카렌더 날짜선택
  Future<void> _selectTime(
      BuildContext context, Function(TimeOfDay) updateTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        updateTime(selectedTime); // Call the callback to update UI
      });
    }
  }

  //일정 입력을 위한 다이얼로그
  Future<void> _showScheduleDialog(
      BuildContext context, Function(TimeOfDay) updateTime) async {
    TimeOfDay newTime = selectedTime;
    final TextEditingController scheduleController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('일정을 입력해 주세요'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        '${newTime.format(context)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: newTime,
                          );
                          if (picked != null) {
                            setState(() {
                              newTime = picked;
                              updateTime(picked);
                            });
                          }
                        },
                        child: const Text('시간선택'),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: scheduleController,
                    decoration: const InputDecoration(labelText: 'Schedule'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      adController.loadAndShowAd();
                      final enteredSchedule = scheduleController.text;
                      final schedule = FirebaseScheduleModel(
                        id: 'unique_id',
                        title: enteredSchedule,
                        year: focusedDay.year,
                        month: focusedDay.month,
                        day: focusedDay.day,
                        date: focusedDay,
                        time: newTime.format(context),
                        finish: false,
                        createdAt: DateTime.now(),
                      );
                      final service = ScheduleFirestore();
                      await service.addSchedule(schedule);
                      // 현재 페이지를 닫고 이전 페이지로 이동
                      Get.back();
                    },
                    child: const Text('저장'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    scheduleTextController.dispose();
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
              Colors.purpleAccent,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: SizedBox(
                width: double.infinity,
                child: BannerAdExample(),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.10,
              left: 10,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.952,
                  height: MediaQuery.of(context).size.height * 0.83,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            //AppBar 부분 Logo
            Positioned(
              top: 26,
              right: 20,
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
                                ' Schedule',
                                style: GoogleFonts.pacifico(
                                  fontSize: 54,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.24,
                              ),
                              IconButton(
                                onPressed: () {
                                  // 뒤로가기
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
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height:
                        MediaQuery.of(context).size.height * 0.51, // 예시로 높이를 설정
                    child: TableCalendar(
                      locale: 'ko_Kr',
                      firstDay: DateTime.utc(2010, 1, 1),
                      lastDay: DateTime.utc(2050, 12, 31),
                      focusedDay: focusedDay,
                      calendarFormat: format,
                      onFormatChanged: (CalendarFormat format) {
                        setState(() {
                          this.format = format;
                        });
                      },
                      onDaySelected:
                          (DateTime selectedDay, DateTime focusedDay) {
                        setState(() {
                          this.selectedDay = selectedDay;
                          this.focusedDay = focusedDay;
                        });
                      },
                      selectedDayPredicate: (DateTime day) {
                        return isSameDay(selectedDay, day);
                      },
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 460,
              left: 20,
              right: 20,
              bottom: 70,
              child: ScheduleList(
                scheduleStream: scheduleFirestore.getScheduleList(),
                selectedDay: selectedDay,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          _showScheduleDialog(
            context,
            (TimeOfDay updatedTime) {
              setState(() {
                selectedTime = updatedTime;
              });
            },
          );
        },
      ),
    );
  }
}
