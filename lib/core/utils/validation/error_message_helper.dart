/// Error Message Helper
///
/// Utility class for converting technical error messages to user-friendly messages
library;

/// Error message helper for converting technical errors to user-friendly messages
class ErrorMessageHelper {
  /// Convert technical error to user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred. Please try again.';
    }

    final errorString = error.toString().toLowerCase();

    // Detect connection errors
    final isConnectionError = errorString.contains('connection refused') ||
        errorString.contains('connection reset') ||
        errorString.contains('connection timed out') ||
        errorString.contains('failed to fetch') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('socketexception') ||
        errorString.contains('err_connection_refused') ||
        errorString.contains('clientexception');

    // Detect timeout errors
    final isTimeout = errorString.contains('timeout') ||
        errorString.contains('timed out') ||
        errorString.contains('request timeout');

    // Detect server errors
    final isServerError = errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('service unavailable') ||
        errorString.contains('bad gateway') ||
        errorString.contains('gateway timeout');

    // Detect not found errors
    final isNotFound = errorString.contains('404') ||
        errorString.contains('not found') ||
        errorString.contains('file not found') ||
        errorString.contains('book file not found');

    // Detect invalid format errors
    final isInvalidFormat = errorString.contains('invalid') ||
        errorString.contains('failed to parse') ||
        errorString.contains('json') ||
        errorString.contains('format');

    if (isConnectionError) {
      return 'Server is down. Please try again later.';
    } else if (isTimeout) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (isServerError) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (isNotFound) {
      return 'Book not found. Please check your connection and try again.';
    } else if (isInvalidFormat) {
      return 'Invalid book format. Please try again later.';
    } else {
      // Try to extract the actual error message from the exception
      final errorStr = error.toString();
      if (errorStr.contains('Failed to load book:')) {
        return errorStr
            .replaceAll('Exception: ', '')
            .replaceAll('Failed to load book: ', '');
      } else if (errorStr.contains('API error:')) {
        return errorStr
            .replaceAll('Exception: ', '')
            .replaceAll('API error: ', '');
      } else {
        // For other errors, return a generic message
        return 'Unable to process your request. Please try again later.';
      }
    }
  }

  /// Check if error is a connection/server error
  static bool isConnectionError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('connection refused') ||
        errorString.contains('connection reset') ||
        errorString.contains('failed to fetch') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('socketexception') ||
        errorString.contains('err_connection_refused') ||
        errorString.contains('clientexception');
  }

  /// Check if error is a server error
  static bool isServerError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('service unavailable') ||
        errorString.contains('bad gateway') ||
        errorString.contains('gateway timeout');
  }
}
