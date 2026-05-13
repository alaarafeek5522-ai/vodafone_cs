import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class VodafoneService {
  static http.Client _client() {
    final ctx = SecurityContext.defaultContext;
    final hc = HttpClient(context: ctx)
      ..badCertificateCallback = (cert, host, port) => true;
    return IOClient(hc);
  }

  static String _randomHex(int length) {
    final rand = Random();
    const chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static String _randomDigitalId() {
    final rand = Random();
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(12, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static Map<String, String> _getDeviceHeaders({String? msisdn}) {
    final devices = ['Realme RMX3760','Xiaomi M2102J20SG','Samsung SM-G998B','LENOVO TB310XU','HUAWEI LIO-L29'];
    final rand = Random();
    final h = <String, String>{
      'Accept': 'application/json, text/plain, */*',
      'Connection': 'keep-alive',
      'silentLogin': 'true',
      'x-agent-operatingsystem': '${11 + rand.nextInt(5)}',
      'clientId': 'AnaVodafoneAndroid',
      'Accept-Language': 'ar',
      'x-agent-device': devices[rand.nextInt(devices.length)],
      'x-agent-version': '2026.4.1',
      'x-agent-build': '${1100 + rand.nextInt(100)}',
      'digitalId': _randomDigitalId(),
      'device-id': _randomHex(16),
      'Content-Type': 'application/x-www-form-urlencoded',
      'Host': 'mobile.vodafone.com.eg',
      'Accept-Encoding': 'gzip',
      'User-Agent': 'okhttp/4.12.0',
    };
    if (msisdn != null) h['msisdn'] = msisdn;
    return h;
  }

  static Future<String> login(String phone, String password) async {
    final client = _client();
    try {
      final r = await client.post(
        Uri.parse('https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token'),
        headers: _getDeviceHeaders(msisdn: phone),
        body: {
          'username': phone,
          'password': password,
          'grant_type': 'password',
          'client_secret': 'dca0pbLUWXVhXR266Gw1iT5rqwvvJQoN',
          'client_id': 'AnaVF',
        },
      ).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) throw Exception('فشل تسجيل الدخول');
      return jsonDecode(r.body)['access_token'];
    } finally {
      client.close();
    }
  }

  static Map<String, dynamic> decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};
      String p = parts[1];
      p += '=' * ((4 - p.length % 4) % 4);
      return jsonDecode(utf8.decode(base64Url.decode(p)));
    } catch (_) { return {}; }
  }

  static Future<Map<String, String>> getUserProfile(String token, String phone) async {
    final client = _client();
    try {
      final uri = Uri.parse(
        'https://web.vodafone.com.eg/services/dxl/sam/serviceAccountManagement/v1/serviceAccount',
      ).replace(queryParameters: {
        '@type': 'DigitalProfile',
        r"$.resources[?(@resourceType=='MSISDN')].IDs[0].value": phone,
      });
      final r = await client.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'AR',
        'msisdn': phone,
        'clientId': 'WebsiteConsumer',
        'Content-Type': 'application/json',
        'Referer': 'https://web.vodafone.com.eg/spa/profile',
      }).timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data is List && data.isNotEmpty && data[0]['contact'] != null) {
          final c = data[0]['contact'][0];
          return {
            'firstName': c['contactFirstName'] ?? 'Unknown',
            'lastName': c['contactLastName'] ?? 'Unknown',
            'tariff': _tariff(token),
          };
        }
      }
    } catch (_) {} finally {
      client.close();
    }
    final info = decodeToken(token)['userInfo'] ?? {};
    return {
      'firstName': info['firstName'] ?? 'Unknown',
      'lastName': info['lastName'] ?? 'Unknown',
      'tariff': _tariff(token),
    };
  }

  static String _tariff(String token) {
    try { return decodeToken(token)['userInfo']?['tariffModelName'] ?? 'غير محدد'; }
    catch (_) { return 'غير محدد'; }
  }

  static final Map<String, String> _chatHeaders = {
    'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Xiaomi Build/SKQ1.210216.001) AppleWebKit/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br, zstd',
    'sec-ch-ua-platform': '"Android"',
    'sec-ch-ua': '"Chromium";v="146", "Not-A.Brand";v="24", "Android WebView";v="146"',
    'sec-ch-ua-mobile': '?1',
    'Origin': 'https://web.vodafone.com.eg',
    'X-Requested-With': 'com.emeint.android.myservices',
    'Sec-Fetch-Site': 'same-site',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Dest': 'empty',
    'Referer': 'https://web.vodafone.com.eg/',
    'Accept-Language': 'ar,ar-EG;q=0.9,en-US;q=0.8,en;q=0.7',
  };

  static Map<String, String> get _chatHeadersWithJson {
    final h = Map<String, String>.from(_chatHeaders);
    h['Content-Type'] = 'application/json';
    return h;
  }

  static Future<String> createChatSession() async {
    final client = _client();
    try {
      final r = await client.get(
        Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/Chat2'),
        headers: _chatHeaders,
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(r.body)['_id'];
    } finally { client.close(); }
  }

  static Future<void> joinChat({
    required String chatId,
    required String firstName,
    required String lastName,
    required String phone,
    required String tariff,
  }) async {
    final client = _client();
    try {
      await client.post(
        Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat'),
        headers: _chatHeadersWithJson,
        body: jsonEncode({
          'subject': 'ES_1_mobile_es',
          'FirstName': firstName,
          'LastName': lastName,
          'EmailAddress': '',
          'UserName': '',
          'LoggedIn': 'True',
          'transcriptEmailAddress': 'True',
          'message': 'hi-test-dev team',
          'TopicSelected': 'Chat_Contactus_ar',
          'MSISDN': phone,
          '_verbose': 'True',
          'Language': 'ar',
          'CustomerValue': '',
          'RatePlan': tariff,
          'Channel_name': 'app',
          'Transfer_test': 'No',
          'Source': 'FlexBot',
        }),
      ).timeout(const Duration(seconds: 15));
    } finally { client.close(); }
  }

  static Future<Map<String, dynamic>> refreshChat(String chatId, int position) async {
    final client = _client();
    try {
      final uri = Uri.parse(
        'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/refresh',
      ).replace(queryParameters: {'transcriptPosition': position.toString()});
      final r = await client.post(uri,
        headers: _chatHeadersWithJson,
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 30));
      return jsonDecode(r.body);
    } finally { client.close(); }
  }

  static Future<void> sendMessage(String chatId, String message) async {
    final client = _client();
    try {
      await client.post(
        Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/send'),
        headers: _chatHeadersWithJson,
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 15));
    } finally { client.close(); }
  }

  static Future<void> disconnect(String chatId) async {
    final client = _client();
    try {
      await client.post(
        Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/disconnect'),
        headers: _chatHeadersWithJson,
        body: jsonEncode({'_verbose': 'True'}),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {} finally { client.close(); }
  }
}
