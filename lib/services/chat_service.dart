import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Xiaomi Build/SKQ1.210216.001) AppleWebKit/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br, zstd',
    'Content-Type': 'application/json',
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

  static Future<String> createSession() async {
    final r = await http.get(
      Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/Chat2'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));
    return jsonDecode(r.body)['_id'];
  }

  static Future<void> joinChat({
    required String chatId,
    required String firstName,
    required String lastName,
    required String phone,
    required String tariff,
  }) async {
    await http.post(
      Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat'),
      headers: _headers,
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
  }

  static Future<void> sendMessage(String chatId, String message) async {
    await http.post(
      Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/send'),
      headers: _headers,
      body: jsonEncode({'message': message}),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<void> disconnect(String chatId) async {
    try {
      await http.post(
        Uri.parse('https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/disconnect'),
        headers: _headers,
        body: jsonEncode({'_verbose': 'True'}),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // Isolate entry point — بيشتغل في thread منفصل زي البوت
  static void _pollIsolate(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final String chatId = args[1];
    int lastPosition = 0;

    final refreshUrl =
        'https://chat.vodafone.com.eg/genesys/1/service/$chatId/ixn/chat/refresh';

    while (true) {
      try {
        final r = await http.post(
          Uri.parse('$refreshUrl?transcriptPosition=$lastPosition'),
          headers: _headers,
          body: jsonEncode({}),
        ).timeout(const Duration(seconds: 8));

        final data = jsonDecode(r.body);

        if (data['transcriptPosition'] != null) {
          lastPosition = data['transcriptPosition'];
        }

        final transcript = data['transcriptToShow'];
        if (transcript != null) {
          for (final msg in transcript) {
            if (msg is List && msg.isNotEmpty) {
              if (msg[0] == 'Notice.Joined') {
                sendPort.send({'type': 'joined', 'name': msg.length > 1 ? msg[1] : ''});
              }
              if (msg.length >= 5 && msg[0] == 'Message.Text' && msg[4] == 'AGENT') {
                sendPort.send({'type': 'message', 'text': msg[2].toString()});
              }
              if (msg[0] == 'Notice.Disconnected') {
                sendPort.send({'type': 'disconnected'});
                return;
              }
            }
          }
        }
      } catch (_) {
        // ignore — بيحاول تاني
      }

      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  static Future<({ReceivePort port, Isolate isolate})> startPolling(String chatId) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _pollIsolate,
      [receivePort.sendPort, chatId],
    );
    return (port: receivePort, isolate: isolate);
  }
}
