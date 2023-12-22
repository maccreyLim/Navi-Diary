import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/controller/release_controller.dart';
import 'package:navi_diary/model/release_model.dart';
import 'package:navi_diary/scr/create_diary_screen.dart';
import 'package:navi_diary/scr/create_release_screen.dart';
import 'package:navi_diary/widget/diary_list_widget.dart';
import 'package:navi_diary/scr/login_screen.dart';
import 'package:navi_diary/scr/setting_screen.dart';
import 'package:navi_diary/scr/update_release_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ReleaseModel>? selectedReleases; // 여기에 선언하세요.
  //AuthController의 인스턴스를 얻기
  final AuthController _authController = AuthController.instance;

  //Release 생성 / 삭제 /수정 구분을 위한 버튼

  //파이어베이스 Release
  final _release = ReleaseController.instance;

  // daysPassed 변수 추가
  int daysPassed = 0;

  // 출소일 계산 함수
  DateTime calculateReleaseDate(DateTime inputDate, int years, int months) {
    // 1월의 날 수를 결정하기 위해 윤년 여부 확인
    final int daysInJanuary = isLeapYear(inputDate.year) ? 31 : 30;

    // 년과 개월을 Duration으로 변환하여 더하기
    final Duration duration = Duration(days: years * 365 + months * 30);

    // inputDate에 duration을 더하여 출소일 계산
    DateTime releaseDate = inputDate.add(duration);

    // 출소일이 1월이면서 윤년 여부에 따라 조정
    if (releaseDate.month == 1) {
      releaseDate = releaseDate.add(Duration(days: daysInJanuary - 1));
    }
    dayPassedCalculate(inputDate);
    // 출소일을 반환
    return releaseDate;
  }

  // 윤년 여부 확인 함수
  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  // Timestamp를 DateTime으로 변환하는 함수
  DateTime convertTimestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  // Function to calculate the percentage
  double calculatePercentage(DateTime inputDate, DateTime releaseDate) {
    DateTime currentDate = DateTime.now();
    int totalDays = releaseDate.difference(inputDate).inDays;
    int daysPassed = currentDate.difference(inputDate).inDays;

    double percentage = (daysPassed / totalDays) * 100;
    return percentage.isFinite ? percentage : 0.0;
  }

//입소일로부터 몇일이 지났는지 계산하는 함수
  dayPassedCalculate(DateTime inputDate) {
    DateTime currentDate = DateTime.now();

// daysPassed 변수에는 inputDate부터 현재까지의 일수가 저장됩니다.
    daysPassed = currentDate.difference(inputDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            //위쪽 화면 Stack
            Positioned(
              top: 70,
              left: 10,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.952,
                  height: MediaQuery.of(context).size.height * 0.28,
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
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<List<ReleaseModel>>(
                          stream: _release.getReleasesStream(),
                          builder: (context,
                              AsyncSnapshot<List<ReleaseModel>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('출소 정보가 없습니다.'),
                              );
                            } else {
                              List<ReleaseModel>? releases = snapshot.data;
                              selectedReleases = releases;
                              _authController.isReleaseChange(true);
                              print(AuthController
                                  .instance.isReleaseFirebase.value);
                              Map<String, double> percentageMap = {};
                              return ListView.builder(
                                itemCount: releases?.length ?? 0,
                                itemBuilder: (context, index) {
                                  var release = releases![index];
                                  DateTime releaseDate = calculateReleaseDate(
                                    releases.first.inputDate,
                                    releases.first.years,
                                    releases.first.months,
                                  );
                                  // percentageMap 업데이트
                                  percentageMap[release.name] =
                                      calculatePercentage(
                                          release.inputDate, releaseDate);

                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(18, 0, 18, 0),
                                    child: ListTile(
                                      title: Text(
                                        release.name,
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70),
                                      ),
                                      subtitle: GestureDetector(
                                        onLongPress: () {
                                          print(release.message);
                                          _showGetXDialog(release);
                                        },
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 24),
                                              Text(
                                                '입소일:  ${DateFormat('yyyy-MM-dd').format(release.inputDate).toString()}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white38,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '형   량:  ${release.years}년 ${release.months}개월',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white38,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '출소일: ${DateFormat('yyyy-MM-dd').format(releaseDate)}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white38,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${percentageMap[release.name]?.toStringAsFixed(0) ?? "0"}%',
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 8, 0, 4),
                                                child: LinearProgressIndicator(
                                                  minHeight: 20,
                                                  value: percentageMap[
                                                                  release.name]
                                                              ?.isFinite ==
                                                          true
                                                      ? percentageMap[
                                                              release.name]! /
                                                          100
                                                      : 0.0,
                                                  backgroundColor:
                                                      Colors.white38,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    percentageMap[release.name]
                                                                ?.isFinite ==
                                                            true
                                                        ? daysPassed < 7
                                                            ? Colors
                                                                .red // Red for 0-7%
                                                            : daysPassed <= 30
                                                                ? Colors
                                                                    .yellow // Yellow for 7-30%
                                                                : percentageMap[release
                                                                            .name]! <
                                                                        80
                                                                    ? Colors
                                                                        .purple // Purple for 30-80%
                                                                    : Colors
                                                                        .green // Green for 80-100%
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ReleaseTipText(
                                                      daysPassed: daysPassed,
                                                      percentageMap:
                                                          percentageMap,
                                                      release: release),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 다른 출소 정보를 표시하기 위한 추가 위젯 추가
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //아래에 있는 화면
            const DownScreenForm(),
            // 타이틀 표시위젯
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Home',
                        style: GoogleFonts.pacifico(
                          fontSize: 54,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.31,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {});
                          //Todo: 설정화면 구현
                          Get.to(() => SettingScreen(
                              selectedReleases: selectedReleases));
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white54,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          //Todo: 파이어베이스 로그아웃 구현
                          _authController.signOut();
                          Get.to(() => const LoginScreen());
                        },
                        icon: const Icon(
                          Icons.logout_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 일기장 영역
            DiaryScreenForm(),
            //일기장 작성 버튼
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.pink,
                tooltip: '일기쓰기',
                onPressed: () {
                  Get.to(() => const CreateDiaryScreen());
                  setState(() {});
                },
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white60,
                ),
              ),
            ),
            // 출소일 데이타가 있으면 수정 버튼으로 바뀌고 수정페이지에서 수정과 삭제를 구현
            // ReleaseChangeButton(
            //   isRelease: _authController.isReleaseFirebase.value,
            //   selectedReleases: selectedReleases,
            // ),
          ],
        ),
      ),
    );
  }
}

//출소일에 따른 Tip 안내멘트
class ReleaseTipText extends StatelessWidget {
  const ReleaseTipText({
    super.key,
    required this.daysPassed,
    required this.percentageMap,
    required this.release,
  });

  final int daysPassed;
  final Map<String, double> percentageMap;
  final ReleaseModel release;

  @override
  Widget build(BuildContext context) {
    return Text(
      daysPassed <= 7
          ? "Tip: 신경이 극도로 예민해요 [입소${daysPassed}일째]"
          : daysPassed <= 30
              ? "Tip: 점점 적응되어 가고 있는 시기입니다.[입소${daysPassed}일째]"
              : daysPassed <= 100
                  ? "Tip: 방식구들과 싸우지 않도록 주의 [입소${daysPassed}일째]"
                  : percentageMap[release.name]! < 50
                      ? "Tip: 50%가 지났습니다.힘냅시다 [입소${daysPassed}일째]"
                      : percentageMap[release.name]! < 80
                          ? "Tip: 세심한 가족의 관심이 필요할 시기 [입소${daysPassed}일째]"
                          : "가석방 가능 기간입니다. [입소${daysPassed}일째]",
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white54,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

//출소일 데이타가 있으면 수정 버튼으로 바뀌고 수정페이지에서 수정과 삭제를 구현
class ReleaseChangeButton extends StatefulWidget {
  const ReleaseChangeButton({
    Key? key,
    required this.isRelease,
    required this.selectedReleases,
  }) : super(key: key);

  final bool isRelease;
  final List<ReleaseModel>? selectedReleases;

  @override
  State<ReleaseChangeButton> createState() => _ReleaseChangeButtonState();
}

class _ReleaseChangeButtonState extends State<ReleaseChangeButton> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      // top: MediaQuery.of(context).size.height * 0.5,
      // right: 20,
      child: Obx(() => AuthController.instance.isReleaseFirebase.value
          ? IconButton(
              icon: const Icon(
                Icons.close,
                size: 20,
                color: Colors.white38,
              ),
              onPressed: () {
                if (widget.selectedReleases != null &&
                    widget.selectedReleases!.isNotEmpty) {
                  // 변경된 부분

                  Get.to(() => UpdateReleaseScreen(
                      release: widget.selectedReleases!.first))?.then(
                    (value) {
                      if (value == true) {
                        setState(() {});
                        ;
                      }
                    },
                  );
                }
              },
            )
          : IconButton(
              icon: const Icon(
                Icons.add,
                size: 30,
                color: Colors.white38,
              ),
              onPressed: () {
                Get.to(() => const CreateReleaseScreen())!.then((value) {
                  // CreateReleaseScreen이 닫힌 후 실행되는 코드
                  if (value == true) {
                    // 화면이 성공적으로 닫혔을 때, 상위 화면 다시 그리기
                    AuthController.instance.update();
                  }
                });
              },
            )),
    );
  }
}

// 일기장 영역
class DiaryScreenForm extends StatelessWidget {
  const DiaryScreenForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.42, // 조정 가능한 값
      left: MediaQuery.of(context).size.width * 0.054, // 조정 가능한 값
      child: Container(
        // color: Colors.transparent,
        width: MediaQuery.of(context).size.height * 0.45,
        height: MediaQuery.of(context).size.width * 1.08,
        //일기장 리스트
        child: DiaryListWidget(),
      ),
    );
  }
}

//아래에 있는 화면 Stack
class DownScreenForm extends StatelessWidget {
  const DownScreenForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.40,
      left: MediaQuery.of(context).size.width * 0.025,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.952,
          height: MediaQuery.of(context).size.height * 0.58,
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
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

//출소정보 디테일 다이얼로그
void _showGetXDialog(ReleaseModel release) {
  Get.defaultDialog(
    title: release.name, titleStyle: TextStyle(color: Colors.white),
    content: Text(
      release.message,
      style: TextStyle(color: Colors.white54, fontSize: 20),
    ),
    backgroundColor: Colors.deepPurple, // 배경색 변경
    actions: [
      ElevatedButton(
        onPressed: () {
          // Handle the entered value here

          Get.back(); // Close the dialog
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink, // 버튼 색상 변경
        ),
        child: Text(
          '확인',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    ],
  );
}
