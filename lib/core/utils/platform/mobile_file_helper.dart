/// Mobile File Helper
///
/// Platform-specific file operations helper for mobile (Android/iOS)
/// This file is only used on mobile platforms, not on web
library;

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

/// Create a file on mobile platform
/// This function is only called when !kIsWeb
io.File createMobileFile(String path) {
  return io.File(path);
}

/// Get temporary directory on mobile platform
/// This function is only called when !kIsWeb
Future<io.Directory> getMobileTemporaryDirectory() async {
  return getTemporaryDirectory();
}

/// Create a directory on mobile platform
/// This function is only called when !kIsWeb
io.Directory createMobileDirectory(String path) {
  return io.Directory(path);
}
