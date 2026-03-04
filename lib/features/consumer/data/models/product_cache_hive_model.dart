import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/consumer/data/models/product_api_model.dart';

@HiveType(typeId: HiveTableConstants.productCacheTypeId)
class ProductCacheHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String jsonString;

  ProductCacheHiveModel({required this.id, required this.jsonString});

  static ProductCacheHiveModel fromApi(ProductApiModel api) {
    return ProductCacheHiveModel(
      id: api.id,
      jsonString: jsonEncode(api.toJson()),
    );
  }

  ProductApiModel toApi() {
    return ProductApiModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonString) as Map),
    );
  }
}

class ProductCacheHiveModelAdapter extends TypeAdapter<ProductCacheHiveModel> {
  @override
  final int typeId = HiveTableConstants.productCacheTypeId;

  @override
  ProductCacheHiveModel read(BinaryReader reader) {
    final id = reader.read() as String;
    final jsonString = reader.read() as String;
    return ProductCacheHiveModel(id: id, jsonString: jsonString);
  }

  @override
  void write(BinaryWriter writer, ProductCacheHiveModel obj) {
    writer.write(obj.id);
    writer.write(obj.jsonString);
  }
}
