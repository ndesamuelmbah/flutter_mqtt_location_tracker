import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        host = host.toLowerCase();
        var res = RegExp(r"[a-z]+").allMatches(host).map((m) => m[0]).toList();
        return res.contains('villagecredit') ||
            res.contains('googleapis') ||
            res.contains('wa') ||
            res.contains('me') ||
            res.contains('s3') ||
            res.contains('amazon') ||
            host.contains('firebase');
      };
  }
}
