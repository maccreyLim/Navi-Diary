import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FcmTokenScreen extends StatelessWidget {
  final String token;

  const FcmTokenScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text('FCM Token Screen'),
        ),
        body: Text(token),
      ),
    );
  }
}
