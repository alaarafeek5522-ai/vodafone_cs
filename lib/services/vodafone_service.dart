import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class VodafoneService {
  static const _timeout = Duration(seconds: 10);

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
    final devices = [
      'Xiaomi M2102J20SG',
      'Samsung SM-G998B',
      'LENOVO TB310XU',
      'HUAWEI LIO-L29',
    ];
    final rand = Random();
    final headers = <String, String>{
      'Accept': 'application/json, text/plain, */*',
      'Connection': 'keep-alive',
      'silentLogin': 'true',
      'x-agent-operatingsystem': '${11 + rand.nextInt(4)}',
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
    if (msisdn != null) headers['msisdn'] = msisdn;
    return headers;
  }

  static Future<String> login(String phone, String password) async {
    final url = Uri.parse(
        'https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token');
    final headers = _getDeviceHeaders(msisdn: phone);
    final body = {
      'username': phone,
      'password': password,
      'grant_type': 'password',
      'client_secret': '95fd95fb-7489-4958-8ae6-d31a525cd20a',
      'client_id': 'ana-vodafone-app',
    };
    final response = await http.post(url, headers: headers, body: body)
        .timeout(_timeout);
    if (response.statusCode != 200) throw Exception('فشل تسجيل الدخول');
    return jsonDecode(response.body)['access_token'];
  }

  static Map<String, dynamic> decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};
      String payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded);
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, String>> getUserProfile(String token, String phone) async {
    final decoded = decodeToken(token);
    final userInfo = decoded['userInfo'] ?? {};
    return {
      'firstName': userInfo['firstName'] ?? 'Unknown',
      'lastName': userInfo['lastName'] ?? 'Unknown',
      'tariff': userInfo['tariffModelName'] ?? 'غير محدد',
    };
  }

  static Map<String, String> get _chatHeaders => {
    'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Xiaomi Build/SKQ1.210216.001) AppleWebKit/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Content-Type': 'application/json',
    'Origin': 'https://web.vodafone.com.eg',
    'Referer': 'https://web.vodafone.com.eg/',
    'Accept-Language': 'ar,ar-EG;q=0.9',
    'X-Requested-With': 'com.emeint.android.myservices',
  };

  static Future<String> createChatSession() async {
    final url = Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/Chat2');
    final response = await http.get(url, headers: _chatHeaders).timeout(_timeout);
    return jsonDecode(response.body)['_id'];
  }

  static Future<void> joinChat({
    required String chatId,
    required String firstName,
    required String lastName,
    required String phone,
    required String tariff,
  }) async {
    final url = Uri.parse(
        'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat');
    final payload = {
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
    };
    await http.post(url, headers: _chatHeaders, body: jsonEncode(payload))
        .timeout(_timeout);
  }

  static Future<Map<String, dynamic>> refreshChat(String chatId, int position) async {
    final url = Uri.parse(
        'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/refresh?transcriptPosition=$position');
    final response = await http.post(url, headers: _chatHeaders, body: jsonEncode({}))
        .timeout(const Duration(seconds: 8));
    return jsonDecode(response.body);
  }

  static Future<void> sendMessage(String chatId, String message) async {
    final url = Uri.parse(
        'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/send');
    await http.post(url, headers: _chatHeaders, body: jsonEncode({'message': message}))
        .timeout(_timeout);
  }

  static Future<void> disconnect(String chatId) async {
    final url = Uri.parse(
        'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/disconnect');
    await http.post(url, headers: _chatHeaders, body: jsonEncode({'_verbose': 'True'}))
        .timeout(_timeout);
  }
}
