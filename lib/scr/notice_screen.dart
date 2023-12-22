import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi_diary/model/notice_model.dart';
import 'package:navi_diary/scr/create_notice.dart';
import 'package:navi_diary/scr/home_screen.dart';
import 'package:navi_diary/scr/notice_detail_screen.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  //Property
  // DateTime 포멧팅
  // String formattedDate =
  //     DateFormat('yyyy년 MM월 dd일 HH:mm').format(comment.createdAt);
// Firebase Firestore로부터 공지사항을 가져오기 위한 쿼리
  final Query query = FirebaseFirestore.instance.collection('notice');
  //공지사항 리스트뷰빌더로 구현
  Widget buildCommentListView(List<NoticeModel> announcementList) {
    final now = DateTime.now();

    return Container(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width * 1,
        child: ListView.builder(
          itemCount: announcementList.length,
          itemBuilder: (context, index) {
            final comment = announcementList[index];
            //작성시간과 얼마나 지났는지 표시를 위한 함수 구현
            final DateTime created = comment.createdAt;
            final Duration difference = now.difference(created);

            String formattedDate;

            if (difference.inHours > 0) {
              formattedDate = '${difference.inHours}시간 전';
            } else if (difference.inMinutes > 0) {
              formattedDate = '${difference.inMinutes}분 전';
            } else {
              formattedDate = '방금 전';
            }
            //리스트 타이틀로 구현
            return ListTile(
              leading: const Icon(Icons.circle, size: 14, color: Colors.grey),
              title: Text(
                "${comment.title} ($formattedDate)",
                maxLines: 1, // 최대 줄 수를 1로 설정
                overflow: TextOverflow.ellipsis, // 오버플로우 처리 설정 (생략 부호 사용)),
              ),
              subtitle: Text(
                comment.content,
                maxLines: 3, // 최대 줄 수를 1로 설정
                overflow: TextOverflow.ellipsis, // 오버플로우 처리 설정 (생략 부호 사용)
              ),
              onTap: () {
                Get.to(() => const NoticeDetailScreen(), arguments: comment);
              },
            );
          },
        ),
      ),
    );
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
              Colors.blue,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.10,
              left: 10,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.952,
                  height: MediaQuery.of(context).size.height * 0.84,
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
            ),
            //네이밍
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
                        'Notice',
                        style: GoogleFonts.pacifico(
                          fontSize: 54,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40,
                      ),
                      IconButton(
                        onPressed: () {
                          Get.to(() => const HomeScreen());
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
            //FloatingActionButton 구현
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.pink,
                onPressed: () {
                  Get.to(() => CreateNoticeScreen());
                },
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white60,
                ),
              ),
            ),

            //화면구성
            Positioned(
              bottom: 80,
              left: 15,
              right: 15,
              child: Column(
                children: [
                  Container(
                      child: StreamBuilder<QuerySnapshot>(
                    stream: query.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('공지사항 데이터를 가져오는 중 오류가 발생했습니다.');
                      }

                      final querySnapshot = snapshot.data;
                      if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                        return const Text('공지사항이 없습니다.');
                      }

                      final announcementList = querySnapshot.docs
                          .map((doc) => NoticeModel.fromMap(
                              doc.data() as Map<String, dynamic>))
                          .toList();
                      announcementList.sort((a, b) =>
                          b.createdAt.compareTo(a.createdAt)); // 내림차순 정렬
                      return SingleChildScrollView(
                          child: buildCommentListView(announcementList));
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
