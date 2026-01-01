// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumer_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsumerHiveModelAdapter extends TypeAdapter<ConsumerHiveModel> {
  @override
  final int typeId = 2;

  @override
  ConsumerHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsumerHiveModel(
      authId: fields[0] as String?,
      fullName: fields[1] as String,
      username: fields[2] as String,
      phoneNumber: fields[3] as String?,
      dob: fields[4] as String?,
      gender: fields[5] as String?,
      country: fields[6] as String?,
      profilePicture: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumerHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.authId)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.dob)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.country)
      ..writeByte(7)
      ..write(obj.profilePicture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsumerHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
