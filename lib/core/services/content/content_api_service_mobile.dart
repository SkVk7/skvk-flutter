/// Content API Service Mobile Implementation
///
/// Uses dart:io's HttpClient with automatic gzip decompression
library;

import 'dart:convert';
import 'dart:io' show HttpClient;

/// Mobile implementation using HttpClient (automatic gzip decompression)
Future<String> getLyricsMobile(String url) async {
  final uri = Uri.parse(url);
  final client = HttpClient();

  try {
    client.autoUncompress = true; // Enable automatic gzip decompression

    final request = await client.getUrl(uri);
    request.headers.set('Accept', 'text/plain');
    request.headers.set('Accept-Encoding', 'gzip, deflate');

    final response = await request.close().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('API request timeout');
      },
    );

    if (response.statusCode != 200) {
      final errorBody = await response.transform(utf8.decoder).join();
      throw Exception('API error: ${response.statusCode} - $errorBody');
    }

    // Read response body (automatically decompressed by HttpClient)
    final lyrics = await response.transform(utf8.decoder).join();
    return lyrics;
  } finally {
    client.close();
  }
}

/// Mobile implementation for getting book JSON (with automatic gzip decompression)
Future<String> getBookMobile(String url) async {
  final uri = Uri.parse(url);
  final client = HttpClient();

  try {
    client.autoUncompress = true; // Enable automatic gzip decompression

    final request = await client.getUrl(uri);
    request.headers.set('Accept', 'application/json');
    request.headers.set('Accept-Encoding', 'gzip, deflate');

    final response = await request.close().timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw Exception('API request timeout');
      },
    );

    if (response.statusCode != 200) {
      final errorBody = await response.transform(utf8.decoder).join();
      // Try to parse error JSON for better error message
      try {
        final errorData = jsonDecode(errorBody) as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] ?? errorData?['message'] ?? 'Unknown error';
        throw Exception('API error: $errorMessage (${response.statusCode})');
      } catch (_) {
        throw Exception('API error: ${response.statusCode} - $errorBody');
      }
    }

    // Read response body (automatically decompressed by HttpClient)
    final bookJson = await response.transform(utf8.decoder).join();
    
    // Check if response is empty
    if (bookJson.isEmpty) {
      throw Exception('Book file is empty or not found');
    }
    
    return bookJson;
  } finally {
    client.close();
  }
}
