import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addNotification({
  required String userId,
  required String title,
  required String message,
  required String type,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .add({
    'title': title,
    'message': message,
    'timestamp': Timestamp.now(),
    'type': type,
  });
}

