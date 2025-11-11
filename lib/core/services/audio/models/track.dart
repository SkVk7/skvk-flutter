/// Track Model
///
/// Represents an audio track with all metadata
library;

/// Track model for audio playback
class Track {
  final String id;
  final String title;
  final String subtitle;
  final String album;
  final Duration duration;
  final String coverUrl;
  final String sourceUrl;
  final Map<String, dynamic>? metadata;

  const Track({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.album,
    required this.duration,
    required this.coverUrl,
    required this.sourceUrl,
    this.metadata,
  });

  /// Create Track from JSON
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      album: json['album'] as String? ?? '',
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : Duration.zero,
      coverUrl: json['coverUrl'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Convert Track to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'album': album,
      'duration': duration.inMilliseconds,
      'coverUrl': coverUrl,
      'sourceUrl': sourceUrl,
      'metadata': metadata,
    };
  }

  /// Create Track from music map (from API)
  factory Track.fromMusicMap(Map<String, dynamic> music) {
    return Track(
      id: music['id'] as String? ?? '',
      title: music['title'] as String? ?? music['id'] as String? ?? '',
      subtitle: music['subtitle'] as String? ?? music['artist'] as String? ?? '',
      album: music['album'] as String? ?? '',
      duration: music['duration'] != null
          ? Duration(milliseconds: music['duration'] as int)
          : Duration.zero,
      coverUrl: music['coverArtUrl'] as String? ?? music['coverUrl'] as String? ?? '',
      sourceUrl: music['audioUrl'] as String? ?? '',
      metadata: music,
    );
  }

  /// Create a copy with updated fields
  Track copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? album,
    Duration? duration,
    String? coverUrl,
    String? sourceUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      coverUrl: coverUrl ?? this.coverUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Track(id: $id, title: $title)';
}

