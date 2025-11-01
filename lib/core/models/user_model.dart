/// User Model
///
/// Represents user data with all necessary fields for astrology calculations
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../astrology/core/enums/astrology_enums.dart';

/// Time of birth model
class TimeOfBirth extends Equatable {
  final int hour;
  final int minute;
  final int second;

  const TimeOfBirth({
    required this.hour,
    required this.minute,
    this.second = 0,
  });

  /// Create from TimeOfDay
  factory TimeOfBirth.fromTimeOfDay(TimeOfDay timeOfDay) {
    return TimeOfBirth(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
      second: 0,
    );
  }

  /// Create from DateTime
  factory TimeOfBirth.fromDateTime(DateTime dateTime) {
    return TimeOfBirth(
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
    );
  }

  /// Convert to TimeOfDay
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Convert to DateTime (with today's date)
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  /// Format as string
  String format() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  /// Format as 12-hour string
  String format12Hour() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  List<Object?> get props => [hour, minute, second];
}

/// User model with all required fields for astrology calculations
class UserModel extends Equatable {
  final String id;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final DateTime dateOfBirth;
  final TimeOfBirth timeOfBirth;
  final String placeOfBirth;
  final double latitude;
  final double longitude;
  final String sex;
  final String? gender;
  final String? timezone;
  final AyanamshaType ayanamsha;
  final HouseSystem houseSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.phone,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.latitude,
    required this.longitude,
    required this.sex,
    this.gender,
    this.timezone,
    this.ayanamsha = AyanamshaType.lahiri,
    this.houseSystem = HouseSystem.placidus,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      timeOfBirth: TimeOfBirthJson.fromJson(json['timeOfBirth'] as Map<String, dynamic>),
      placeOfBirth: json['placeOfBirth'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sex: json['sex'] as String,
      gender: json['gender'] as String?,
      timezone: json['timezone'] as String?,
      ayanamsha: AyanamshaType.values.firstWhere(
        (e) => e.name == json['ayanamsha'],
        orElse: () => AyanamshaType.lahiri,
      ),
      houseSystem: HouseSystem.values.firstWhere(
        (e) => e.name == json['houseSystem'],
        orElse: () => HouseSystem.placidus,
      ),
      // Removed: UTC birth time fields - timezone conversion now handled by AstrologyFacade
      // Astrology data handled separately
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': timeOfBirth.toJson(),
      'placeOfBirth': placeOfBirth,
      'latitude': latitude,
      'longitude': longitude,
      'sex': sex,
      'gender': gender,
      'timezone': timezone,
      'ayanamsha': ayanamsha.name,
      'houseSystem': houseSystem.name,
      // Removed: UTC birth time fields - timezone conversion now handled by AstrologyFacade
      // Astrology data handled separately
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    TimeOfBirth? timeOfBirth,
    String? placeOfBirth,
    double? latitude,
    double? longitude,
    String? sex,
    String? gender,
    String? timezone,
    AyanamshaType? ayanamsha,
    HouseSystem? houseSystem,
    // Removed: UTC birth time parameters - timezone conversion now handled by AstrologyFacade
    // Astrology data handled separately
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sex: sex ?? this.sex,
      gender: gender ?? this.gender,
      timezone: timezone ?? this.timezone,
      ayanamsha: ayanamsha ?? this.ayanamsha,
      houseSystem: houseSystem ?? this.houseSystem,
      // Removed: UTC birth time fields - timezone conversion now handled by AstrologyFacade
      // Astrology data handled separately
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory method to create a new user
  factory UserModel.create({
    required String name,
    required DateTime dateOfBirth,
    required TimeOfBirth timeOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
    required String sex,
    String? username,
    String? email,
    String? phone,
    String? gender,
    String? timezone,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    HouseSystem houseSystem = HouseSystem.placidus,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: 'user_${now.millisecondsSinceEpoch}',
      name: name,
      username: username,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      timeOfBirth: timeOfBirth,
      placeOfBirth: placeOfBirth,
      latitude: latitude,
      longitude: longitude,
      sex: sex,
      gender: gender,
      timezone: timezone,
      ayanamsha: ayanamsha,
      houseSystem: houseSystem,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check if user has complete birth data
  bool get hasCompleteBirthData {
    return placeOfBirth.isNotEmpty && latitude != 0.0 && longitude != 0.0;
  }

  /// Check if user has astrology data (now fetched from centralized cache)
  bool get hasAstrologyData {
    // Astrology data is now fetched from centralized astrology cache
    // This method is kept for backward compatibility
    return hasCompleteBirthData;
  }

  /// Validate user data
  bool get isValid {
    return name.isNotEmpty &&
        placeOfBirth.isNotEmpty &&
        latitude != 0.0 &&
        longitude != 0.0 &&
        sex.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
        phone,
        dateOfBirth,
        timeOfBirth,
        placeOfBirth,
        latitude,
        longitude,
        sex,
        gender,
        timezone,
        ayanamsha,
        houseSystem,
        // Removed: UTC birth time fields - timezone conversion now handled by AstrologyFacade
        // Astrology data handled separately
        createdAt,
        updatedAt,
      ];

  /// Get the local birth DateTime (combines dateOfBirth and timeOfBirth)
  DateTime get localBirthDateTime {
    return DateTime(
      dateOfBirth.year,
      dateOfBirth.month,
      dateOfBirth.day,
      timeOfBirth.hour,
      timeOfBirth.minute,
      timeOfBirth.second,
    );
  }

  /// Get formatted birth time for display (preserves user's original input)
  String get formattedBirthTime {
    // Format the local time for display (no conversion needed)
    return '${localBirthDateTime.hour.toString().padLeft(2, '0')}:${localBirthDateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Extension for TimeOfBirth JSON serialization
extension TimeOfBirthJson on TimeOfBirth {
  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  static TimeOfBirth fromJson(Map<String, dynamic> json) {
    return TimeOfBirth(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }
}
