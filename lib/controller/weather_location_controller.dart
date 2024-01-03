// 위치를 가져오는 함수
import 'package:geolocator/geolocator.dart';

class WeatherLocationController {
  //위도
  late double latitude2;
  //경도
  late double longitude2;

  Future<void> getMyCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      //위도
      latitude2 = position.latitude;
      //경도
      longitude2 = position.longitude;
      print('현재 위치: 위도($latitude2) , 경도($longitude2');
      // 여기에 위치를 이용한 추가적인 동작을 수행할 수 있습니다.
    } catch (e) {
      print('위치를 가져오는데 실패했습니다: $e');
    }
  }
}

// 위치 권한과 서비스 상태 확인 함수
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 위치 서비스가 활성화되어 있는지 확인
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // 위치 서비스가 비활성화된 경우 예외 처리
    throw Exception('위치 서비스가 비활성화되어 있습니다.');
  }

  // 위치 권한 확인
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // 권한이 거부된 경우 권한 요청
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 권한이 다시 거부된 경우 예외 처리
      throw Exception('위치 권한이 거부되었습니다.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // 권한이 영구적으로 거부된 경우 예외 처리
    throw Exception('위치 권한이 영구적으로 거부되었습니다. 권한을 설정에서 확인하세요.');
  }

  // 여기까지 오면 권한이 허용되었고 위치를 가져올 수 있습니다.
  return await Geolocator.getCurrentPosition();
}
