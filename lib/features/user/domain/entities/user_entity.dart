/// User domain entity
///
/// This represents the core business logic for a user
/// and is independent of any external frameworks
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// Removed missing user_model import

/// Time of birth data class
class TimeOfBirth {
  final int hour;
  final int minute;

  const TimeOfBirth({
    required this.hour,
    required this.minute,
  });

  factory TimeOfBirth.fromTimeOfDay(TimeOfDay timeOfDay) {
    return TimeOfBirth(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

/// User entity representing the core business concept of a user
class UserEntity extends Equatable {
  final String id;
  final String username;
  final DateTime dateOfBirth;
  final TimeOfBirth timeOfBirth;
  final String placeOfBirth;
  final String sex;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.sex,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated fields
  UserEntity copyWith({
    String? id,
    String? username,
    DateTime? dateOfBirth,
    TimeOfBirth? timeOfBirth,
    String? placeOfBirth,
    String? sex,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      sex: sex ?? this.sex,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validate user data
  bool get isValid {
    return username.isNotEmpty &&
        username.length >= 2 &&
        username.length <= 50 &&
        dateOfBirth.isBefore(DateTime.now()) &&
        placeOfBirth.isNotEmpty &&
        (sex == 'Male' || sex == 'Female') &&
        latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  /// Get user age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': {
        'hour': timeOfBirth.hour,
        'minute': timeOfBirth.minute,
      },
      'placeOfBirth': placeOfBirth,
      'sex': sex,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      username: json['username'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      timeOfBirth: TimeOfBirth(
        hour: json['timeOfBirth']['hour'] as int,
        minute: json['timeOfBirth']['minute'] as int,
      ),
      placeOfBirth: json['placeOfBirth'] as String,
      sex: json['sex'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        dateOfBirth,
        timeOfBirth,
        placeOfBirth,
        sex,
        latitude,
        longitude,
        createdAt,
        updatedAt,
      ];
}

// Removed duplicate TimeOfBirth class definition
