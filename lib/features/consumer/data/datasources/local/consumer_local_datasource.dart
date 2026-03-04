import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/consumer/data/models/consumer_profile_cache_hive_model.dart';
import 'package:yayvo/features/consumer/domain/entities/consumer_entity.dart';

final consumerLocalProvider = Provider<ConsumerLocalDatasource>((ref) {
  final hive = ref.read(hiveServiceProvider);
  return ConsumerLocalDatasource(hive);
});

class ConsumerLocalDatasource {
  final HiveService _hive;
  ConsumerLocalDatasource(this._hive);

  Future<ConsumerHiveModel?> getConsumerById(String authId) async {
    return _hive.getConsumerById(authId);
  }

  Future<bool> updateConsumer(ConsumerHiveModel model) async {
    return _hive.updateConsumer(model);
  }

  Future<ConsumerHiveModel> registerConsumer(ConsumerHiveModel model) async {
    return _hive.registerConsumer(model);
  }

  /// Profile cache (API consumer profile: displayName, bio, profilePicture).
  ConsumerProfileCacheHiveModel? getConsumerProfileCache(String authId) =>
      _hive.getConsumerProfileCache(authId);

  Future<void> saveConsumerProfileCache(ConsumerEntity entity) async {
    await _hive.saveConsumerProfileCache(
        ConsumerProfileCacheHiveModel.fromEntity(entity));
  }
}
