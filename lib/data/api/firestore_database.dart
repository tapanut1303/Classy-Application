import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subject.dart';

class FirestoreDatabase {
  FirestoreDatabase._();

  static final instance = FirestoreDatabase._();
  final _firestore = FirebaseFirestore.instance;

  Future<String> saveSubject(Subject subject) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('ต้องเข้าสู่ระบบก่อนบันทึกข้อมูล');

    final subjectRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subjects')
        .add({
      'code': subject.code,
      'name': subject.name,
      'lecturer': subject.lecturer,
      'room': subject.room,
      'credits': subject.credits,
      'grade': subject.grade,
      'colorValue': subject.colorValue,
      'days': subject.days,
      'startTime': subject.startTime,
      'endTime': subject.endTime,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final savedSubject = await subjectRef.get();
    if (!savedSubject.exists) {
      throw StateError('Firebase ไม่พบข้อมูลวิชาหลังจากบันทึก');
    }

    return subjectRef.id;
  }

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
}
