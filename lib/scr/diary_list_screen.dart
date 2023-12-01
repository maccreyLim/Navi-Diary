import 'package:flutter/material.dart';

class diaryListScrren extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 500), () {
      // 일정 시간이 지난 후에 실행될 코드
    });
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.star),
          title: Text('아이템 1'),
          subtitle: Text('부제목 1'),
          // onTap: () {
          //   // 탭되었을 때 수행할 동작
          //   print('아이템 1이 선택되었습니다.');
          // },
        ),
        ListTile(
          leading: Icon(Icons.star),
          title: Text('아이템 2'),
          subtitle: Text('부제목 2'),
          // onTap: () {
          //   // 탭되었을 때 수행할 동작
          //   print('아이템 2가 선택되었습니다.');
          // },
        ),
        ListTile(
          leading: Icon(Icons.star),
          title: Text('아이템 3'),
          subtitle: Text('부제목 3'),
          // onTap: () {
          //   // 탭되었을 때 수행할 동작
          //   print('아이템 3이 선택되었습니다.');
          // },
        ),
        // 추가적인 아이템을 원하는 만큼 나열할 수 있습니다.
      ],
    );
  }
}
