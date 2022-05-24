import 'package:dio/dio.dart';

class DioHelper {
  static Dio? dio;

  static Future init(String baseUrl) async {
    // var cookieJar = await getCookiePath();
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
      ),
    );
    // ..interceptors.add(
    //     CookieManager(cookieJar),
    //   );
    dio?.options.connectTimeout = 60 * 1000;
    dio?.options.receiveTimeout = 60 * 1000;
  }
}
