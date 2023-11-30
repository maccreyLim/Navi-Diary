import 'package:flutter/material.dart';
import 'package:navi_diary/controller/release_calculator_firebase.dart';
import 'package:navi_diary/model/release_model.dart';

class releaseWidget extends StatefulWidget {
  const releaseWidget({super.key});

  @override
  State<releaseWidget> createState() => _releaseWidgetState();
}

class _releaseWidgetState extends State<releaseWidget> {
  final ReleaseFirestore _releaseFirestore = ReleaseFirestore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ReleaseModel>>(
        future: _releaseFirestore.getReleases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Data is still loading
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // An error occurred while fetching data
            return Text('Error: ${snapshot.error}');
          } else {
            // Data has been successfully loaded
            List<ReleaseModel>? releases = snapshot.data;

            if (releases == null || releases.isEmpty) {
              // No release information available
              return const Center(
                child: Text('출소 정보가 없습니다.'),
              );
            }

            // Use the releases data in your UI
            return ListView.builder(
              itemCount: releases.length,
              itemBuilder: (context, index) {
                var release = releases[index];

                return ListTile(
                  title: Text(release.name),
                  // Add more widgets to display other release information
                );
              },
            );
          }
        },
      ),
    );
  }
}
