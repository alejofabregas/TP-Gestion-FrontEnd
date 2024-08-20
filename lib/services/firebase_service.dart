import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

const Map<String, String> clavesJson = {
  "type": "service_account",
  "project_id": "gestionmaestrosplitter",
  "private_key_id": "e8cabca42142fb4b0e1d3c8d503375e5c9007607",
  "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC3lXIxiXicAjW/\nbq3tjKLAIuhOxzHtvfowkFD4lRQvIIXeosELRkEIcJ2qr57EAgdccjRrc2lTQTrh\nqyprE+0mHcxSSJJ5rEgLUmae9bpa0MGBJFNlPSH7qwBpmO3F7Vu+9Ct0ARM1nmlT\nt1yYokDV7TJlnLlYCB+sw7REA11VE/+ak0wxvuZN/+33HosG133x62t8YiJk0R4a\nFtVs0l44gV3VUxeoW8yED52XEit8f3vO0XnoG3iJXf9jbWfCmGGwAG51jWL7uL6m\nQ5rmjBGV13agiX7vuuTWeWjf797v6NiE3R8gG+qEvAj3y5G0metcTYJop78nm2d/\n8LpjzVhjAgMBAAECggEABIVrsIigLcdoJ3TEV8tU3sJ9UiNZuW8qUDPdqqGRQ6/b\nXCZJ9sseIuUTHPcCQ/WA1OgDHnpTJ7e9iX07qDNvbbbiJ0yePtzdUVoQKO4ITuBB\nQ7rvStj8k0Qc2HzpriwwTD2bLFoybOmf0m37m86zJhGXYiU/80kP7qNLNzmV/Nhc\njxd+39/pCB1y4qPJ9cDTmqdx30soQoRnpAmhfQ6bARULaOqfOVJoN5DYjQhugxD8\nFE9kC1uFWbBKzKPoUrU0RiC4ur1/RsheEagnPi2V1ExwWdqta2YYDsT2a7k/AnTW\nHYcGGgN+w4i7ZsBV68di/UPjgGxv0NdQ6HtP+jlLoQKBgQDc3w/iX6S0tILtlZVJ\nu+w4bOmjW8ENAxqigzQgFlF8VAYqo/FBincbKJyK5nkxXCHe+rXQ62BdmtNFklku\n4UHj8+F5udPZpOSoBYmdmzkZ/ZnoZeTbfNYEsRzNJVeythKDIgfDBqum6n+rY5Lv\nxfFSMGiNyCQfn1kSghZSInJRuQKBgQDUyDGTKOW1Pl5jqHzJxY9g4hrCTOCZZgxs\n7Uk/OKthd1ktzmc0+cnNRvqCXzt3061fFOfldVhWD5cFKw7+adG8VX/kAXpn/Hnc\nkmqKaA9lsJ/Kxb3Qe4lIsWm+Mo7bYYPDuPAQwK3/3tYSKVu84M9+vQs31DtCEM2i\nG/RYyOz4+wKBgHJ6axE54XSH2xSpYydEb7sPOEmjVPwZj8SLnIjFCJcYNdoD/xep\nXPKGqhyUOFyNFEEuUO5oERpzFO4KXI8f0bcEwOkGl/dGr/0mYZ1+xqnh99OsfGIG\n4iasZfEuWbYXCKFPEhbTbkSlZma+xXnhbqLa1FYoVhDN1qzxIACSOg6BAoGAT3ek\n7Czt/U6ZueaHFGQwNCK9k6tahm/SXCwSmwXzG6eTKsRXTzWq5HuJu38Nmqb3rPcF\n1HCK2TlhUZDPPL0Qk6Hq7aCPsp5cdMBKAf7zISthwj0vstkwYHHB6ELBj7VPnJ1J\nKziKw3DZylaf6F6dn9vCgMtGhln4Mn72NuJzflkCgYAQY3xX4Ncjaylfx/aKnJEV\nfTCzWrbVcjE2k2M12oQkgdEHBPMccol2F3n3D+YlxO5oJSNH94HHpVI31FEQyERL\n3ztjymsJreep/v+YGOouCTIfLBrUGgfXhcDLsHQicx+Msz4+Ecjc62cvQ3CCch90\nqraTTcgoIBgLGTh/lB27uw==\n-----END PRIVATE KEY-----\n",
  "client_email":
      "firebase-adminsdk-3ym18@gestionmaestrosplitter.iam.gserviceaccount.com",
  "client_id": "108814966326449163793",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-3ym18%40gestionmaestrosplitter.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final String projectId = "YOUR_PROJECT_ID";
  // final String serverKey = "YOUR_SERVER_KEY";

  Future<String?> initNotifications() async {
    await Firebase.initializeApp();
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _firebaseMessaging.getToken();
      return token;
    }
    return null;
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    final credentials = auth.ServiceAccountCredentials.fromJson(clavesJson);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient = await auth.clientViaServiceAccount(credentials, scopes);
    const projectId = "gestionmaestrosplitter";
    final Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
        },
      }
    };
    print("Sending notification: $message");
    final response = await authClient.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );
    print("Notification sent: ${response.body}");
    if (response.statusCode != 200) {
      print("Error sending notification: ${response.body}");
      throw Exception('Error sending notification: ${response.body}');
    }
  }
}
