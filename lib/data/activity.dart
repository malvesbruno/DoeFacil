import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> logActivity(String title, String subtitle, String type) async {
  await FirebaseFirestore.instance.collection('activities').add({
    'title': title,
    'subtitle': subtitle,
    'type': type, // 'entry', 'exit', 'update'
    'timestamp': FieldValue.serverTimestamp(),
  });
}
