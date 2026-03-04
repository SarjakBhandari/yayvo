import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/consumer/data/models/review_api_model.dart';

@HiveType(typeId: HiveTableConstants.reviewCacheTypeId)
class ReviewCacheHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String jsonString;

  ReviewCacheHiveModel({required this.id, required this.jsonString});

  static ReviewCacheHiveModel fromApi(ReviewApiModel api) {
    return ReviewCacheHiveModel(
      id: api.id,
      jsonString: jsonEncode(api.toJson()),
    );
  }

  ReviewApiModel toApi() {
    return ReviewApiModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonString) as Map),
    );
  }
}

class ReviewCacheHiveModelAdapter extends TypeAdapter<ReviewCacheHiveModel> {
  @override
  final int typeId = HiveTableConstants.reviewCacheTypeId;

  @override
  ReviewCacheHiveModel read(BinaryReader reader) {
    final id = reader.read() as String;
    final jsonString = reader.read() as String;
    return ReviewCacheHiveModel(id: id, jsonString: jsonString);
  }

  @override
  void write(BinaryWriter writer, ReviewCacheHiveModel obj) {
    writer.write(obj.id);
    writer.write(obj.jsonString);
  }
}
