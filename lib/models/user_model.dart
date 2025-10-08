import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_progress_model.dart';

class UserModel {
  final String uid;
  final String email;
  final String? goal;
  final String? level;
  final String? gender;
  final DateTime? planStartDate; 
  final int? age;
  final int? height;
  final int? weight;
  final bool onboardingCompleted;
  final UserProgress progress;
  
  UserModel({
    required this.uid,
    required this.email,
    this.goal,
    this.level,
    this.gender,
    this.planStartDate,
    this.age,
    this.height,
    this.weight,
    required this.onboardingCompleted,
    required this.progress,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] as String? ?? doc.id, 
      email: data['email'] as String? ?? 'No Email Provided',
      goal: data['goal'] as String?,
      level: data['level'] as String?,
      gender: data['gender'] as String?,
      planStartDate: (data['planStartDate'] as Timestamp?)?.toDate(),
      age: data['age'] as int?,
      height: data['height'] as int?,
      weight: data['weight'] as int?,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      progress: UserProgress.fromMap(data['progress'] as Map<String, dynamic>?),
    );
  }
}