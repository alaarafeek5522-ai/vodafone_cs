import 'dart:convert';
import 'dart:io';
import 'dart:math';

class VodafoneService {
  // HTTP client بيتجاهل SSL تماماً زي verify=False في Python
  static Future<String> _post(String url, Map<String, String> headers, String body, {bool isForm = false}) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    try {
      final uri = Uri.parse(url);
      final req = await client.postUrl(uri);
      headers.forEach((k, v) => req.headers.set(k, v));
      if (!isForm) req.headers.contentType = ContentType.json;
      req.write(body);
      final res = await req.close();
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close();
    }
  }

  static Future<String> _postForm(String url, Map<String, String> headers, Map<String, String> body) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    try {
      final uri = Uri.parse(url);
      final req = await client.postUrl(uri);
      headers.forEach((k, v) => req.headers.set(k, v));
      req.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
      final encoded = body.entries.map((e) =>
          '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
      req.write(encoded);
      final res = await req.close();
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close();
    }
  }

  static Future<String> _get(String url, Map<String, String> headers) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    try {
      final uri = Uri.parse(url);
      final req = await client.getUrl(uri);
      headers.forEach((k, v) => req.headers.set(k, v));
      final res = await req.close();
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close();
    }
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

  static Map<String, String> _deviceHeaders({String? msisdn}) {
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
      'Host': 'mobile.vodafone.com.eg',
      'Accept-Encoding': 'gzip',
      'User-Agent': 'okhttp/4.12.0',
    };
    if (msisdn != null) h['msisdn'] = msisdn;
    return h;
  }

  static Future<String> login(String phone, String password) async {
    final res = await _postForm(
      'https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token',
      _deviceHeaders(msisdn: phone),
      {
        'username': phone,
        'password': password,
        'grant_type': 'password',
        'client_secret': 'dca0pbLUWXVhXR266Gw1iT5rqwvvJQoN',
        'client_id': 'AnaVF',
      },
    );
    final data = jsonDecode(res);
    if (data['access_token'] == null) throw Exception('فشل تسجيل الدخول');
    return data['access_token'];
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
    try {
      final uri = Uri.parse(
        'https://web.vodafone.com.eg/services/dxl/sam/serviceAccountManagement/v1/serviceAccount'
      ).replace(queryParameters: {
        '@type': 'DigitalProfile',
        r"$.resources[?(@resourceType=='MSISDN')].IDs[0].value": phone,
      });
      final res = await _get(uri.toString(), {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'AR',
        'msisdn': phone,
        'clientId': 'WebsiteConsumer',
        'Referer': 'https://web.vodafone.com.eg/spa/profile',
      });
      final data = jsonDecode(res);
      if (data is List && data.isNotEmpty && data[0]['contact'] != null) {
        final c = data[0]['contact'][0];
        return {
          'firstName': c['contactFirstName'] ?? 'Unknown',
          'lastName': c['contactLastName'] ?? 'Unknown',
          'tariff': _tariff(token),
        };
      }
    } catch (_) {}
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

  static final Map<String, String> _chatH = {
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
    'Content-Type': 'application/json',
  };

  static Future<String> createChatSession() async {
    final res = await _get(
      'https://chat.vodafone.com.eg/genesys/1/service/Chat2',
      _chatH,
    );
    return jsonDecode(res)['_id'];
  }

  static Future<void> joinChat({
    required String chatId,
    required String firstName,
    required String lastName,
    required String phone,
    required String tariff,
  }) async {
    await _post(
      'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat',
      _chatH,
      jsonEncode({
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
    );
  }

  static Future<Map<String, dynamic>> refreshChat(String chatId, int position) async {
    final url = 'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/refresh?transcriptPosition=$position';
    final res = await _post(url, _chatH, jsonEncode({}));
    return jsonDecode(res);
  }

  static Future<void> sendMessage(String chatId, String message) async {
    await _post(
      'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/send',
      _chatH,
      jsonEncode({'message': message}),
    );
  }

  static Future<void> disconnect(String chatId) async {
    try {
      await _post(
        'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/disconnect',
        _chatH,
        jsonEncode({'_verbose': 'True'}),
      );
    } catch (_) {}
  }
}
