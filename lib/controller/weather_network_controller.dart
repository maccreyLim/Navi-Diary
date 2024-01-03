import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherNetWorkController {
  final String url;
  final String url2;
  WeatherNetWorkController(this.url, this.url2);

  Future<dynamic> getJsonData() async {
    try {
      http.Response response = await http.get(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var parsingData = jsonDecode(jsonData);
        return parsingData;
      }
      // 200 상태 코드가 아닌 경우 처리
      print('데이터를 불러오지 못했습니다. 상태 코드: ${response.statusCode}');
      return null; // 예외를 던지거나 특정 값 반환 선택 가능
    } catch (e) {
      // 네트워크 또는 기타 오류 처리
      print('날씨 요청 중 오류 발생: $e');
      return null; // 예외를 던지거나 특정 값 반환 선택 가능
    }
  }

  Future<dynamic> getAirData() async {
    try {
      // HTTP 요청을 보냅니다.
      http.Response response = await http.get(Uri.parse(url2));

      // 응답 상태 코드가 200(성공)인 경우 데이터를 파싱하여 반환합니다.
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var parsingData = jsonDecode(jsonData);
        return parsingData;
      } else {
        // 상태 코드가 200이 아닌 경우, 오류 메시지를 출력하고 null을 반환합니다.
        print('대기 데이터를 불러오지 못했습니다. 상태 코드: ${response.statusCode}');
        return null; // 예외를 던지거나 특정 값 반환 선택 가능
      }
    } catch (e) {
      // 네트워크 또는 기타 오류가 발생하면 해당 오류 메시지를 출력하고 null을 반환합니다.
      print('대기 데이터 요청 중 오류 발생: $e');
      return null; // 예외를 던지거나 특정 값 반환 선택 가능
    }
  }
}
