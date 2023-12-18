import 'package:flutter/material.dart';
import 'package:navi_diary/controller/release_controller.dart';
import 'package:navi_diary/model/release_model.dart';

class ReleaseWidget extends StatefulWidget {
  const ReleaseWidget({super.key});

  @override
  State<ReleaseWidget> createState() => _ReleaseWidgetState();
}

class _ReleaseWidgetState extends State<ReleaseWidget> {
  final ReleaseController _releaseController = ReleaseController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ReleaseModel>>(
        future: _releaseController.getReleases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Data is still loading
            return const Center(child: CircularProgressIndicator());
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
