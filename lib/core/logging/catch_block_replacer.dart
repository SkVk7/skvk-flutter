/// Catch Block Replacer
///
/// Utility to help replace empty catch blocks with proper logging throughout the application.
library;

/// Helper class to replace empty catch blocks with proper logging
class CatchBlockReplacer {
  /// Replace empty catch block with error logging
  static String replaceEmptyCatch({
    required String operation,
    required String source,
    String? additionalContext,
  }) {
    final context = additionalContext != null ? ' - $additionalContext' : '';
    return '''
    } catch (e) {
      await LoggingHelper.logError('Failed to $operation$context', source: '$source', error: e);
    }''';
  }

  /// Replace empty catch block with warning logging
  static String replaceEmptyCatchWithWarning({
    required String operation,
    required String source,
    String? additionalContext,
  }) {
    final context = additionalContext != null ? ' - $additionalContext' : '';
    return '''
    } catch (e) {
      await LoggingHelper.logWarning('Failed to $operation$context', source: '$source', metadata: {'error': e.toString()});
    }''';
  }

  /// Replace empty catch block with info logging (for non-critical operations)
  static String replaceEmptyCatchWithInfo({
    required String operation,
    required String source,
    String? additionalContext,
  }) {
    final context = additionalContext != null ? ' - $additionalContext' : '';
    return '''
    } catch (e) {
      await LoggingHelper.logInfo('Failed to $operation$context', source: '$source', metadata: {'error': e.toString()});
    }''';
  }
}
