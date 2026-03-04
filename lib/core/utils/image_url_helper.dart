import 'package:yayvo/core/api/api_endpoints.dart';

/// Builds a full image URL from a path (e.g. /uploads/...).
/// Handles leading slash and avoids double slashes with baseUrl.
String imageUrlFromPath(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = ApiEndpoints.baseUrl;
  final normalized = path.startsWith('/') ? path : '/$path';
  return base.endsWith('/') ? '$base${normalized.substring(1)}' : '$base$normalized';
}
