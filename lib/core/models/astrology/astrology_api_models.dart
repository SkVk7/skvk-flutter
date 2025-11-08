/// Astrology API Models
///
/// Data models for astrology API responses.
/// These models represent the JSON structure returned by the Spring Boot API.
library;

/// Birth Data Response Model
class BirthDataResponse {
  final String birthDateTime;
  final double? latitude;
  final double? longitude;
  final String? ayanamsha;
  final String? houseSystem;
  final Map<String, dynamic>? rashi;
  final Map<String, dynamic>? nakshatra;
  final Map<String, dynamic>? pada;
  final Map<String, dynamic>? dasha;
  final Map<String, dynamic>? birthChart;
  final String? calculatedAt;

  BirthDataResponse({
    required this.birthDateTime,
    this.latitude,
    this.longitude,
    this.ayanamsha,
    this.houseSystem,
    this.rashi,
    this.nakshatra,
    this.pada,
    this.dasha,
    this.birthChart,
    this.calculatedAt,
  });

  factory BirthDataResponse.fromJson(Map<String, dynamic> json) {
    return BirthDataResponse(
      birthDateTime: json['birthDateTime'] as String? ?? '',
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      ayanamsha: json['ayanamsha'] as String?,
      houseSystem: json['houseSystem'] as String?,
      rashi: json['rashi'] as Map<String, dynamic>?,
      nakshatra: json['nakshatra'] as Map<String, dynamic>?,
      pada: json['pada'] as Map<String, dynamic>?,
      dasha: json['dasha'] as Map<String, dynamic>?,
      birthChart: json['birthChart'] as Map<String, dynamic>?,
      calculatedAt: json['calculatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birthDateTime': birthDateTime,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (ayanamsha != null) 'ayanamsha': ayanamsha,
      if (houseSystem != null) 'houseSystem': houseSystem,
      if (rashi != null) 'rashi': rashi,
      if (nakshatra != null) 'nakshatra': nakshatra,
      if (pada != null) 'pada': pada,
      if (dasha != null) 'dasha': dasha,
      if (birthChart != null) 'birthChart': birthChart,
      if (calculatedAt != null) 'calculatedAt': calculatedAt,
    };
  }
}

/// Compatibility Response Model
class CompatibilityResponse {
  final double? overallScore;
  final Map<String, dynamic>? kootaScores;
  final String? explanation;
  final String? recommendation;
  final String? calculatedAt;

  CompatibilityResponse({
    this.overallScore,
    this.kootaScores,
    this.explanation,
    this.recommendation,
    this.calculatedAt,
  });

  factory CompatibilityResponse.fromJson(Map<String, dynamic> json) {
    return CompatibilityResponse(
      overallScore: json['overallScore'] as double?,
      kootaScores: json['kootaScores'] as Map<String, dynamic>?,
      explanation: json['explanation'] as String?,
      recommendation: json['recommendation'] as String?,
      calculatedAt: json['calculatedAt'] as String?,
    );
  }
}

/// Predictions Response Model
class PredictionsResponse {
  final Map<String, dynamic>? dasha;
  final Map<String, dynamic>? transit;
  final Map<String, dynamic>? prediction;
  final String? calculatedAt;

  PredictionsResponse({
    this.dasha,
    this.transit,
    this.prediction,
    this.calculatedAt,
  });

  factory PredictionsResponse.fromJson(Map<String, dynamic> json) {
    return PredictionsResponse(
      dasha: json['dasha'] as Map<String, dynamic>?,
      transit: json['transit'] as Map<String, dynamic>?,
      prediction: json['prediction'] as Map<String, dynamic>?,
      calculatedAt: json['calculatedAt'] as String?,
    );
  }
}

/// Calendar Year Response Model
class CalendarYearResponse {
  final int? year;
  final String? region;
  final List<Map<String, dynamic>>? festivals;
  final String? calculatedAt;

  CalendarYearResponse({
    this.year,
    this.region,
    this.festivals,
    this.calculatedAt,
  });

  factory CalendarYearResponse.fromJson(Map<String, dynamic> json) {
    return CalendarYearResponse(
      year: json['year'] as int?,
      region: json['region'] as String?,
      festivals: (json['festivals'] as List?)?.cast<Map<String, dynamic>>(),
      calculatedAt: json['calculatedAt'] as String?,
    );
  }
}

/// Calendar Month Response Model
class CalendarMonthResponse {
  final int? year;
  final int? month;
  final String? region;
  final List<Map<String, dynamic>>? days;
  final String? calculatedAt;

  CalendarMonthResponse({
    this.year,
    this.month,
    this.region,
    this.days,
    this.calculatedAt,
  });

  factory CalendarMonthResponse.fromJson(Map<String, dynamic> json) {
    return CalendarMonthResponse(
      year: json['year'] as int?,
      month: json['month'] as int?,
      region: json['region'] as String?,
      days: (json['days'] as List?)?.cast<Map<String, dynamic>>(),
      calculatedAt: json['calculatedAt'] as String?,
    );
  }
}
