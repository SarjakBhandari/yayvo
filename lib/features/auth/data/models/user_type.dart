import 'package:hive/hive.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';

part 'user_type.g.dart';

@HiveType(typeId: HiveTableConstants.userTypeId)
enum UserType {
  @HiveField(0)
  consumer,

  @HiveField(1)
  retailer,
}
