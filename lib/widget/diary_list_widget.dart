import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navi_diary/controller/diary_controller.dart';
import 'package:navi_diary/model/diary_model.dart';
import 'package:navi_diary/scr/update_diary_screen.dart';

class DiaryListWidget extends StatefulWidget {
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

                    return GestureDetector(
                      onLongPress: () {
                        //일기 삭제 구현
                        // 어떤 화면에서 이미지 삭제를 수행하는 예제 코드
                        void deleteImageExample(
                            DiaryModel diary, String imageUrl) async {
                          try {
                            // DiaryController 인스턴스 생성
                            DiaryController diaryController = DiaryController();

                            // 이미지 삭제
                            await diaryController.deleteImageFromFirestore(
                                diary, imageUrl);

                            // 삭제 성공 시 메시지 표시
                            print('이미지가 성공적으로 삭제되었습니다.');
                          } catch (error) {
                            // 오류 발생 시 오류 메시지 출력
                            print('이미지 삭제 중 오류 발생: $error');
                          }
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ' ${_formatDate(diary.createdAt)}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.to(() => UpdateDiaryScreen(diary: diary));
                                  setState(() {});
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 18,
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

                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 30, 8, 0),
                            child: Text(
                              diary.title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              diary.contents,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(),
                          SizedBox(
                            height: 20,
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
}
