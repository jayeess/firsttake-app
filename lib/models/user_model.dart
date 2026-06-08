import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { TALENT, RECRUITER }

enum AccountStatus { ACTIVE, SUSPENDED, DELETED }

class UserModel {
  final String uid;
  final String email;
  final String phone;
  final UserType userType;
  final bool emailVerified;
  final bool phoneVerified;
  final AccountStatus accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.uid,
    required this.email,
    required this.phone,
    required this.userType,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.accountStatus = AccountStatus.ACTIVE,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.name == map['userType'],
      ),
      emailVerified: map['emailVerified'] as bool? ?? false,
      phoneVerified: map['phoneVerified'] as bool? ?? false,
      accountStatus: AccountStatus.values.firstWhere(
        (e) => e.name == map['accountStatus'],
        orElse: () => AccountStatus.ACTIVE,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      lastLogin: map['lastLogin'] != null
          ? (map['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'userType': userType.name,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'accountStatus': accountStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? phone,
    UserType? userType,
    bool? emailVerified,
    bool? phoneVerified,
    AccountStatus? accountStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
