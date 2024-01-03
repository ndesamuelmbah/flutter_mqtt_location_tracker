// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_auth_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirebaseAuthUserAdapter extends TypeAdapter<FirebaseAuthUser> {
  @override
  final int typeId = 16;

  @override
  FirebaseAuthUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FirebaseAuthUser(
      uid: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String?,
      photoUrl: fields[3] as String?,
      emailVerified: fields[4] as bool,
      creationTime: fields[5] as int,
      providers: (fields[6] as List).cast<CustomAuthProvider>(),
      isAdmin: fields[7] as bool?,
      phoneNumber: fields[8] as String,
      isSubscribedToTracking: fields[9] as bool?,
      accountNumber: fields[10] as String,
      signatureUrl: fields[11] as String?,
      organizationName: fields[12] as String?,
      frontOfId: fields[13] as String?,
      backOfId: fields[14] as String?,
      firebaseMessagingToken: fields[15] as String?,
      passwordHash: fields[16] as String?,
      deviceIds: fields[17] as List<String>?,
    );
  }

  @override
  void write(BinaryWriter writer, FirebaseAuthUser obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.emailVerified)
      ..writeByte(5)
      ..write(obj.creationTime)
      ..writeByte(6)
      ..write(obj.providers)
      ..writeByte(7)
      ..write(obj.isAdmin)
      ..writeByte(8)
      ..write(obj.phoneNumber)
      ..writeByte(9)
      ..write(obj.isSubscribedToTracking)
      ..writeByte(10)
      ..write(obj.accountNumber)
      ..writeByte(11)
      ..write(obj.signatureUrl)
      ..writeByte(12)
      ..write(obj.organizationName)
      ..writeByte(13)
      ..write(obj.frontOfId)
      ..writeByte(14)
      ..write(obj.backOfId)
      ..writeByte(15)
      ..write(obj.firebaseMessagingToken)
      ..writeByte(16)
      ..write(obj.passwordHash)
      ..writeByte(17)
      ..write(obj.deviceIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirebaseAuthUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FirebaseAuthUsersAdapter extends TypeAdapter<FirebaseAuthUsers> {
  @override
  final int typeId = 7;

  @override
  FirebaseAuthUsers read(BinaryReader reader) {
    var numOfUsers = reader.readByte();
    var users = <FirebaseAuthUser>[];
    for (var i = 0; i < numOfUsers; i++) {
      users.add(reader.read() as FirebaseAuthUser);
    }
    return FirebaseAuthUsers(users: users);
  }

  @override
  void write(BinaryWriter writer, FirebaseAuthUsers obj) {
    writer.writeByte(obj.users.length);
    obj.users.forEach(writer.write);
  }
}
