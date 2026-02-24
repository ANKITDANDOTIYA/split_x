import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static Future<String> _getAccessToken() async {
    final String response = await rootBundle.loadString('assets/service-account.json');
    final data = json.decode(response);
    final credentials = ServiceAccountCredentials.fromJson(data);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(credentials, scopes);
    return client.credentials.accessToken.data;
  }

  static Future<void> sendExpenseNotification({
    required List<String> receiverUserIds, 
    required String title,
    required double amount,
    required String payerName,
  }) async {
    try {
      final String accessToken = await _getAccessToken();
      const String projectId = "split-expenses-70f9a"; // 👈 Apna ID yahan likho

      for (String uid in receiverUserIds) {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        String? token = userDoc.data()?['fcmToken'];

        if (token != null) {
          await http.post(
            Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              "message": {
                "token": token,
                "notification": {
                  "title": "New Expense Added",
                  "body": "$payerName added \"$title\" • ₹${amount.toStringAsFixed(2)}",
                },
                "android": {"priority": "high"}
              }
            }),
          );
        }
      }
    } catch (e) {
      print("Notification Error: $e");
    }
  }

  static Future<void> sendSettlementNotification({
  required String receiverUserId,
  required String fromName,
  required double amount,
}) async {
  try {
    final String accessToken = await _getAccessToken();
    const String projectId = "split-expenses-70f9a"; // Apna Project ID check kar lena

    var userDoc = await FirebaseFirestore.instance.collection('users').doc(receiverUserId).get();
    String? token = userDoc.data()?['fcmToken'];

    if (token != null) {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "message": {
            "token": token,
            "notification": {
              "title": "Payment Received! 💸",
              "body": "$fromName sent you ₹${amount.toStringAsFixed(2)}",
            },
            "android": {"priority": "high"}
          }
        }),
      );
    }
  } catch (e) {
    print("Settlement Notification Error: $e");
  }
}
}