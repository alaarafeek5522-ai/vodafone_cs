import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createHttpClient() {
  final context = SecurityContext.defaultContext;
  final httpClient = HttpClient(context: context)
    ..badCertificateCallback = (cert, host, port) => true;
  return IOClient(httpClient);
}
