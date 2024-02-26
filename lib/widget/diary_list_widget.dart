import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:navi_diary/controller/diary_controller.dart';
import 'package:navi_diary/model/diary_model.dart';
import 'package:navi_diary/scr/update_diary_screen.dart';
import 'package:navi_diary/widget/w.banner_ad.dart';

class DiaryListWidget extends StatefulWidget {
  const DiaryListWidget({Key? key}) : super(key: key);
  @override
  _DiaryListWidgetState createState() => _DiaryListWidgetState();
}

class _DiaryListWidgetState extends State<DiaryListWidget> {
  final DiaryController _diaryController = DiaryController();

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureBuilder<List<DiaryModel>>(
          future: _diaryController.getDiaries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<DiaryModel>? diaries = snapshot.data;

              if (diaries == null || diaries.isEmpty) {
                return const Center(
                  child: Text('일기가 없습니다.'),
                );
              }

              return Container(
                width: MediaQuery.of(context).size.width * 1,
                child: ListView.builder(
                  itemCount: diaries.length,
                  itemBuilder: (context, index) {
                    var diary = diaries[index];
                    DiaryModel currentDiary = diary;
                    String imageUrl = currentDiary.photoURL!.isNotEmpty
                        ? currentDiary.photoURL![0]
                        : '';

                    return GestureDetector(
                      onLongPress: () async {
                        //일기 삭제 구현
                        // 어떤 화면에서 이미지 삭제를 수행하는 예제 코드
                        await deleteImageExample(currentDiary, imageUrl);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //제목표시
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 30, 8, 0),
                            child: Text(
                              diary.title,
                              style: TextStyle(
                                  fontSize: 60.w, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //날짜 표시
                              Text(
                                ' ${_formatDate(diary.createdAt)}',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 60.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //수정 아이콘
                              IconButton(
                                onPressed: () {
                                  Get.to(() => UpdateDiaryScreen(diary: diary));
                                  setState(() {});
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 18.h,
                          ),
                          //시간 표시
                          Row(
                            children: [
                              SizedBox(width: 20.w),
                              Text(
                                ' 작성시간 : ${_formatTime(diary.createdAt)}',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // 이미지 표시 부분
                          for (int imgIndex = 0;
                              imgIndex < diary.photoURL!.length;
                              imgIndex++)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              //이미지 사이즈
                              width: MediaQuery.of(context).size.width * 1,
                              height: MediaQuery.of(context).size.height * 0.3,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      NetworkImage(diary.photoURL![imgIndex]),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),

                          SizedBox(height: 20.h),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              diary.contents,
                              style: TextStyle(fontSize: 40.sp),
                            ),
                          ),
                          SizedBox(
                            height: 4.w,
                          ),
                          SizedBox(
                              width: double.infinity, child: BannerAdExample()),
                          const Divider(),
                          SizedBox(
                            height: 60.w,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          },
        ));
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime != null) {
      // DateTime이 null이 아닌 경우에만 처리
      final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${weekdays[dateTime.weekday - 1]}';
    } else {
      return ''; // 또는 다른 기본값을 반환할 수 있음
    }
  }

  // DateTime을 받아서 시간만 표시하는 함수
  String _formatTime(DateTime? dateTime) {
    if (dateTime != null) {
      // DateTime이 null이 아닌 경우에만 처리
      String hourString = DateFormat.H().format(dateTime);
      String minuteString = DateFormat.m().format(dateTime);
      return '$hourString시 $minuteString분';
    } else {
      return ''; // 또는 다른 기본값을 반환할 수 있음
    }
  }

  Future<void> deleteImageExample(DiaryModel diary, String imageUrl) async {
    try {
      // DiaryController 인스턴스 생성
      DiaryController diaryController = DiaryController();

      // 이미지 삭제
      await diaryController.deleteImageFromFirestore(diary, imageUrl);

      // 삭제 성공 시 메시지 표시
      print('이미지가 성공적으로 삭제되었습니다.');
    } catch (error) {
      // 오류 발생 시 오류 메시지 출력
      print('이미지 삭제 중 오류 발생: $error');
    }
  }
}
