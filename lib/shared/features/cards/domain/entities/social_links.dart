// =============================================================================
// SOCIAL_LINKS.DART
// =============================================================================
// Value Object fuer Social Media Links. Kopiert von mobilapp.
// =============================================================================

import 'package:equatable/equatable.dart';

/// Social Media Link
class SocialLink extends Equatable {
  const SocialLink({
    required this.platform,
    required this.url,
  });

  final SocialPlatform platform;
  final String url;

  @override
  List<Object?> get props => [platform, url];

  factory SocialLink.fromMapEntry(String key, String value) {
    return SocialLink(
      platform: SocialPlatform.fromString(key),
      url: value,
    );
  }

  MapEntry<String, String> toMapEntry() {
    return MapEntry(platform.value, url);
  }
}

/// Unterstuetzte Social Media Plattformen
enum SocialPlatform {
  linkedin('linkedin', 'LinkedIn'),
  instagram('instagram', 'Instagram'),
  facebook('facebook', 'Facebook'),
  twitter('twitter', 'X (Twitter)'),
  xing('xing', 'XING'),
  youtube('youtube', 'YouTube'),
  tiktok('tiktok', 'TikTok'),
  website('website', 'Website'),
  github('github', 'GitHub'),
  whatsapp('whatsapp', 'WhatsApp'),
  telegram('telegram', 'Telegram'),
  other('other', 'Andere');

  const SocialPlatform(this.value, this.displayName);

  final String value;
  final String displayName;

  static SocialPlatform fromString(String value) {
    return SocialPlatform.values.firstWhere(
      (platform) => platform.value == value.toLowerCase(),
      orElse: () => SocialPlatform.other,
    );
  }
}

/// Collection von Social Links
class SocialLinks extends Equatable {
  const SocialLinks(this.links);

  final List<SocialLink> links;

  static const empty = SocialLinks([]);

  factory SocialLinks.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return empty;

    return SocialLinks(
      map.entries
          .map((e) => SocialLink.fromMapEntry(e.key, e.value.toString()))
          .toList(),
    );
  }

  Map<String, String> toMap() {
    return Map.fromEntries(links.map((link) => link.toMapEntry()));
  }

  int get count => links.length;
  bool get isEmpty => links.isEmpty;
  bool get isNotEmpty => links.isNotEmpty;

  SocialLink? getLink(SocialPlatform platform) {
    try {
      return links.firstWhere((link) => link.platform == platform);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [links];
}
