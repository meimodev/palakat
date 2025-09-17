// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/core/constants/constants.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");


  group("Test API connection", () {

    String token ="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRJZCI6InNlY3JldC1mcm9udGVuZC11c2VybmFtZSIsInNvdXJjZSI6ImNsaWVudC1zdHJhdGVneSIsImlhdCI6MTc1MTQ1MTM0Mn0.exCPxe0omhF4dwuWQFFL29X9U77S43B57x6EQUa8_nE";
    final headers = {"Authorization": "Bearer $token"};

    test("Should return 200 from /auth/signing", () async {
      final headers = {
        "x-username": dotenv.env['X_USERNAME'],
        "x-password": dotenv.env['X_PASSWORD'],
      };
      final dio = Dio(BaseOptions(headers: headers));
      final res = await dio.get(Endpoint.signing);

      final data = res.data["data"];
      expect(res.statusCode, 200);
      expect(data, hasLength(greaterThan(5)));
      token = data.toString();
    });

    test("Should return 200 from /membership", () async {

      final dio = Dio(BaseOptions(headers: headers));
      final res = await dio.get(Endpoint.membership);

      final data = res.data["data"];
      expect(res.statusCode, 200);
      expect(data, isList);
    });

  },);

}
