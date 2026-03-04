import 'package:equatable/equatable.dart';

enum CollectionItemType { product, review }

class CollectionItem extends Equatable {
  final String id;
  final CollectionItemType type;
  final String ownerAuthId;
  final DateTime savedAt;

  const CollectionItem({
    required this.id,
    required this.type,
    required this.ownerAuthId,
    required this.savedAt,
  });

  @override
  List<Object?> get props => [id, type, ownerAuthId, savedAt];
}
