/// Safely extracts a list from API responses that may be a list, or a map
/// with keys like 'data', 'items', 'data.items', 'data.data', etc.
List<dynamic> responseToList(dynamic data) {
  if (data == null) return [];
  if (data is List) return data;
  if (data is! Map) return [];
  final map = data as Map<String, dynamic>;

  // data.data (array)
  final d = map['data'];
  if (d is List) return d;
  if (d is Map) {
    final inner = Map<String, dynamic>.from(d);
    final items = inner['items'];
    if (items is List) return items;
    final dataInner = inner['data'];
    if (dataInner is List) return dataInner;
  }

  // data.items
  final items = map['items'];
  if (items is List) return items;

  // first array value found
  for (final v in map.values) {
    if (v is List) return v;
  }
  return [];
}
