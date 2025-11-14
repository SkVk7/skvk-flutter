/// Profile Photo Service
///
/// Service for managing user profile photos
library;

import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoService {
  static const String _profilePhotoKey = 'profile_photo_path';

  /// Save profile photo path to SharedPreferences
  static Future<void> saveProfilePhotoPath(String photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePhotoKey, photoPath);
  }

  /// Get profile photo path from SharedPreferences
  static Future<String?> getProfilePhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePhotoKey);
  }

  /// Remove profile photo
  static Future<void> removeProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilePhotoKey);
  }

  /// Save image file to app directory
  static Future<String?> saveImageToAppDirectory(String imagePath) async {
    try {
      final File sourceFile = File(imagePath);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String destinationPath = '${appDir.path}/$fileName';

      await sourceFile.copy(destinationPath);
      return destinationPath;
    } on Exception catch (e) {
      developer.log('Error saving image: $e', name: 'ProfilePhotoService');
      return null;
    }
  }

  /// Get profile photo as File
  static Future<File?> getProfilePhotoFile() async {
    final String? photoPath = await getProfilePhotoPath();
    if (photoPath != null) {
      final File photoFile = File(photoPath);
      if (photoFile.existsSync()) {
        return photoFile;
      }
    }
    return null;
  }

  /// Check if profile photo exists
  static Future<bool> hasProfilePhoto() async {
    final String? photoPath = await getProfilePhotoPath();
    if (photoPath != null) {
      // For data URLs (web), just check if path exists
      if (photoPath.startsWith('data:')) {
        return true;
      }
      // For file paths (mobile), check if file exists
      final File photoFile = File(photoPath);
      return photoFile.existsSync();
    }
    return false;
  }
}
