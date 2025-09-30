import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? goal;
  final String? level;
  final String? gender;
  final int currentDay;
  final int? age;
  final int? height;
  final int? weight;
  final bool onboardingCompleted;
  

  UserModel({
    required this.uid,
    required this.email,
    this.goal,
    this.level,
    this.gender,
    this.age,
    this.height,
    this.weight,
    required this.onboardingCompleted,
    required this.currentDay,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] as String? ?? doc.id, 
      email: data['email'] as String? ?? 'No Email Provided',
      
      goal: data['goal'] as String?,
      level: data['level'] as String?,
      gender: data['gender'] as String?,
      age: data['age'] as int?,
      height: data['height'] as int?,
      weight: data['weight'] as int?,

      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      currentDay: data['currentDay'] as int? ?? 1,
    );
  }
}