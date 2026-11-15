import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subject.dart';

class FirestoreDatabase {
  FirestoreDatabase._();

  static final instance = FirestoreDatabase._();
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveUserProfile({
    required String name,
    required String studentId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('ต้องเข้าสู่ระบบก่อนบันทึกข้อมูล');

    final profileRef = _firestore.collection('users').doc(user.uid);
    await profileRef.set({
      'name': name,
      'studentId': studentId,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final savedProfile = await profileRef.get();
    if (!savedProfile.exists || savedProfile.data()?['name'] != name) {
      throw StateError('บันทึกข้อมูลโปรไฟล์ไม่สำเร็จ');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data();
  }

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

  Future<void> updateSubject(Subject subject, {Subject? previous}) async {
    final subjectRef = await _findSubject(previous ?? subject);
    if (subjectRef == null) return;

    await subjectRef.update({
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSubject(Subject subject) async {
    final subjectRef = await _findSubject(subject);
    await subjectRef?.delete();
  }

  Future<DocumentReference<Map<String, dynamic>>?> _findSubject(
    Subject subject,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('ต้องเข้าสู่ระบบก่อนบันทึกข้อมูล');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subjects')
        .where('code', isEqualTo: subject.code)
        .get();

    for (final document in snapshot.docs) {
      final data = document.data();
      if (data['name'] == subject.name &&
          data['lecturer'] == subject.lecturer &&
          data['room'] == subject.room &&
          data['credits'] == subject.credits &&
          data['grade'] == subject.grade &&
          data['colorValue'] == subject.colorValue &&
          _sameDays(data['days'], subject.days) &&
          data['startTime'] == subject.startTime &&
          data['endTime'] == subject.endTime) {
        return document.reference;
      }
    }

    return null;
  }

  bool _sameDays(Object? value, List<int> days) {
    if (value is! List) return false;
    final storedDays = value.map((day) => day as num).map((day) => day.toInt());
    return storedDays.length == days.length &&
        storedDays.every((day) => days.contains(day));
  }

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
}
