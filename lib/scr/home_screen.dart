import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/controller/release_controller.dart';
import 'package:navi_diary/model/release_model.dart';
import 'package:navi_diary/scr/create_diary_screen.dart';
import 'package:navi_diary/scr/weather_loading.dart';
import 'package:navi_diary/widget/diary_list_widget.dart';
import 'package:navi_diary/scr/login_screen.dart';
import 'package:navi_diary/scr/setting_screen.dart';
import 'package:navi_diary/widget/w.banner_ad.dart';
import 'package:navi_diary/widget/w.fcm.dart';
import 'package:navi_diary/widget/w.interstitle_ad_example.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ReleaseModel>? selectedReleases; // 여기에 선언하세요.
  //AuthController의 인스턴스를 얻기
  final AuthController _authController = AuthController.instance;
  final InterstitialAdController adController = InterstitialAdController();

  //Release 생성 / 삭제 /수정 구분을 위한 버튼

  //파이어베이스 Release
  final _release = ReleaseController.instance;

  // daysPassed 변수 추가
  int daysPassed = 0;

  @override
  void initState() {
    //FCM Permission불러오기
    FcmManager.requestPermission();
    //FCM초기화
    FcmManager.initialize();
    super.initState();
  }

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
              top: 260.h,
              left: 20.w,
              child: Center(
                child: Container(
                  width: 1040.w,
                  height: 480.h,
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
                              return Center(
                                child: Text(
                                  '출소 정보가 없습니다.',
                                  style: TextStyle(
                                      fontSize: 60.sp, color: Colors.white54),
                                ),
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
                                        EdgeInsets.fromLTRB(18.w, 0, 18.w, 0),
                                    child: ListTile(
                                      title: Text(
                                        release.name,
                                        style: TextStyle(
                                            fontSize: 60.sp,
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
                                              SizedBox(height: 40.h),
                                              Row(
                                                children: [
                                                  Text(
                                                    '입소일:  ${DateFormat('yyyy-MM-dd').format(release.inputDate).toString()}',
                                                    style: TextStyle(
                                                      fontSize: 40.sp,
                                                      color: Colors.white38,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 80),
                                                  Text(
                                                    '[입소$daysPassed일째]',
                                                    style: TextStyle(
                                                      fontSize: 40.sp,
                                                      color: Colors.white38,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '출소일:  ${DateFormat('yyyy-MM-dd').format(releaseDate)}',
                                                    style: TextStyle(
                                                      fontSize: 40.sp,
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
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 8.h, 0, 4.h),
                                                child: LinearProgressIndicator(
                                                  minHeight: 20.h,
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
                                              SizedBox(height: 5.h),
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
              top: 100.h,
              right: 20.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Home',
                        style: GoogleFonts.pacifico(
                          fontSize: 160.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 50.w,
                      ),
                      IconButton(
                        onPressed: () {
                          //전면광고
                          adController.loadAndShowAd();
                          setState(() {});
                          //Todo: 날씨정보
                          Get.to(() => const WeatherLoading());
                          //   FlutterLocalNotification.showNotification(
                          //       "테스트중", "테스트 중입니다.");
                        },
                        icon: const Icon(Icons.sunny,
                            color: Colors.white54, size: 24),
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
                          size: 24,
                          color: Colors.white54,
                        ),
                      ),
                      //스케쥴러 들어갈곳
                      // IconButton(
                      //   onPressed: () {
                      //     setState(() {});
                      //     //Todo: 설정화면 구현
                      //     Get.to(() => ScheduleScreen());
                      //   },
                      //   icon: const Icon(
                      //     Icons.schedule,
                      //     size: 24,
                      //     color: Colors.white54,
                      //   ),
                      // ),
                      IconButton(
                        onPressed: () {
                          //Todo: 파이어베이스 로그아웃 구현
                          _authController.signOut();
                          Get.to(() => const LoginScreen());
                        },
                        icon: const Icon(
                          Icons.logout_outlined,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 일기장 영역
            const DiaryScreenForm(),
            //일기장 작성 버튼
            Positioned(
              bottom: 46.h,
              right: 40.w,
              child: FloatingActionButton(
                backgroundColor: Colors.pink,
                tooltip: '일기쓰기',
                onPressed: () {
                  Get.to(() => const CreateDiaryScreen());
                  setState(() {});
                },
                child: Icon(
                  Icons.add,
                  size: 80.sp,
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: BannerAdExample(),
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
          ? "Tip: 신경이 극도로 예민해요 [입소$daysPassed일째]"
          : daysPassed <= 30
              ? "Tip: 점점 적응되어 가고 있는 시기입니다.[입소$daysPassed일째]"
              : daysPassed <= 100
                  ? "Tip: 방식구들과 싸우지 않도록 주의 [입소$daysPassed일째]"
                  : percentageMap[release.name]! < 50
                      ? "Tip: 50%가 지났습니다.힘냅시다 [입소$daysPassed일째]"
                      : percentageMap[release.name]! < 80
                          ? "Tip: 세심한 가족의 관심이 필요할 시기입니다. [입소$daysPassed일째]"
                          : "가석방 가능 기간입니다. [입소$daysPassed일째]",
      style: TextStyle(
        fontSize: 30.sp,
        color: Colors.white54,
        fontWeight: FontWeight.bold,
      ),
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
      top: 800.h, // 조정 가능한 값
      left: 40.w, // 조정 가능한 값
      child: Container(
        width: 1000.w,
        height: 1220.h,
        //일기장 리스트
        child: const DiaryListWidget(),
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
      top: 760.h,
      left: 20.w,
      child: Center(
        child: Container(
          width: 1040.w,
          height: 1300.h,
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
    title: release.name, titleStyle: const TextStyle(color: Colors.white),
    content: Text(
      release.message,
      style: TextStyle(color: Colors.white54, fontSize: 60.sp),
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
          style: TextStyle(color: Colors.white, fontSize: 50.sp),
        ),
      ),
    ],
  );
}
