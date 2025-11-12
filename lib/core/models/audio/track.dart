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

  /// Album name (optional)
  final String? album;

  /// URL to artwork/cover image
  final String? artworkUrl;

  /// Alternative cover URL field name
  final String? coverUrl;

  /// URL to audio file
  final String? audioUrl;

  /// Alternative source URL field name
  final String? sourceUrl;

  /// Track duration (may be null if not yet loaded)
  final Duration? duration;

  /// Lyrics text (optional, can be loaded separately)
  final String? lyrics;

  /// Additional metadata (optional)
  final Map<String, dynamic>? metadata;

  const Track({
    required this.id,
    required this.title,
    this.artist,
    this.subtitle,
    this.album,
    this.artworkUrl,
    this.coverUrl,
    this.audioUrl,
    this.sourceUrl,
    this.duration,
    this.lyrics,
    this.metadata,
  });

  /// Create Track from music map (from API)
  factory Track.fromMusicMap(Map<String, dynamic> music) {
    return Track(
      id: music['id'] as String? ?? '',
      title: music['title'] as String? ?? music['id'] as String? ?? '',
      artist: music['artist'] as String?,
      subtitle: music['subtitle'] as String? ?? music['artist'] as String?,
      album: music['album'] as String?,
      artworkUrl: music['coverArtUrl'] as String? ?? music['coverUrl'] as String?,
      coverUrl: music['coverArtUrl'] as String? ?? music['coverUrl'] as String?,
      audioUrl: music['audioUrl'] as String?,
      sourceUrl: music['audioUrl'] as String?,
      duration: music['duration'] != null
          ? Duration(milliseconds: music['duration'] as int)
          : null,
      metadata: music,
    );
  }

  /// Create Track from JSON
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      subtitle: json['subtitle'] as String? ?? '',
      album: json['album'] as String?,
      artworkUrl: json['artworkUrl'] as String? ?? json['coverArtUrl'] as String?,
      coverUrl: json['coverUrl'] as String? ?? json['coverArtUrl'] as String?,
      audioUrl: json['audioUrl'] as String? ?? json['sourceUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String? ?? json['audioUrl'] as String?,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      lyrics: json['lyrics'] as String?,
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
      if (artist != null) 'artist': artist,
      if (subtitle != null) 'subtitle': subtitle,
      if (album != null) 'album': album,
      if (artworkUrl != null) 'artworkUrl': artworkUrl,
      if (coverUrl != null) 'coverUrl': coverUrl,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (sourceUrl != null) 'sourceUrl': sourceUrl,
      if (duration != null) 'duration': duration!.inMilliseconds,
      if (lyrics != null) 'lyrics': lyrics,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? subtitle,
    String? album,
    String? artworkUrl,
    String? coverUrl,
    String? audioUrl,
    String? sourceUrl,
    Duration? duration,
    String? lyrics,
    Map<String, dynamic>? metadata,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      subtitle: subtitle ?? this.subtitle,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      duration: duration ?? this.duration,
      lyrics: lyrics ?? this.lyrics,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get display subtitle (artist or subtitle)
  String get displaySubtitle => artist ?? subtitle ?? '';

  /// Get cover URL (artworkUrl or coverUrl)
  String? get displayCoverUrl => artworkUrl ?? coverUrl;

  /// Get audio URL (audioUrl or sourceUrl)
  String? get displayAudioUrl => audioUrl ?? sourceUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Track(id: $id, title: $title)';
}

