/// Track Model
///
/// Immutable model representing an audio track with all metadata.
/// Used throughout the audio player system.
library;

/// Represents an audio track with metadata
class Track {
  /// Unique identifier for the track
  final String id;

  /// Track title
  final String title;

  /// Artist or subtitle
  final String? artist;

  /// Alternative subtitle field
  final String? subtitle;

  /// URL to artwork/cover image
  final String? artworkUrl;

  /// URL to audio file
  final String? audioUrl;

  /// Track duration (may be null if not yet loaded)
  final Duration? duration;

  /// Lyrics text (optional, can be loaded separately)
  final String? lyrics;

  const Track({
    required this.id,
    required this.title,
    this.artist,
    this.subtitle,
    this.artworkUrl,
    this.audioUrl,
    this.duration,
    this.lyrics,
  });

  /// Create Track from music map (from API)
  factory Track.fromMusicMap(Map<String, dynamic> music) {
    return Track(
      id: music['id'] as String? ?? '',
      title: music['title'] as String? ?? music['id'] as String? ?? '',
      artist: music['artist'] as String?,
      subtitle: music['subtitle'] as String? ?? music['artist'] as String?,
      artworkUrl: music['coverArtUrl'] as String? ?? music['coverUrl'] as String?,
      audioUrl: music['audioUrl'] as String?,
      duration: music['duration'] != null
          ? Duration(milliseconds: music['duration'] as int)
          : null,
    );
  }

  /// Create a copy with updated fields
  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? subtitle,
    String? artworkUrl,
    String? audioUrl,
    Duration? duration,
    String? lyrics,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      subtitle: subtitle ?? this.subtitle,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      lyrics: lyrics ?? this.lyrics,
    );
  }

  /// Get display subtitle (artist or subtitle)
  String get displaySubtitle => artist ?? subtitle ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Track(id: $id, title: $title)';
}

