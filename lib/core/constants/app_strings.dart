/// App Strings Constants
///
/// Centralized string constants for the application
/// Following Flutter best practices for internationalization
library;

/// Application-wide string constants
class AppStrings {
  // App Info
  static const String appName = 'SKVK Astrology';
  static const String appVersion = '1.0.0';

  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnknown = 'An unknown error occurred.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorNoData = 'No data available.';

  // Success Messages
  static const String successSaved = 'Saved successfully.';
  static const String successDeleted = 'Deleted successfully.';
  static const String successUpdated = 'Updated successfully.';

  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String horoscope = 'Horoscope';
  static const String matching = 'Matching';
  static const String predictions = 'Predictions';
  static const String calendar = 'Calendar';
  static const String audio = 'Audio';

  // User
  static const String userName = 'Name';
  static const String userEmail = 'Email';
  static const String userPhone = 'Phone';
  static const String userBirthDate = 'Birth Date';
  static const String userBirthTime = 'Birth Time';
  static const String userBirthPlace = 'Birth Place';
  static const String userGender = 'Gender';

  // Horoscope
  static const String horoscopeGenerate = 'Generate Horoscope';
  static const String horoscopeLoading = 'Generating horoscope...';
  static const String horoscopeError = 'Failed to generate horoscope.';

  // Matching
  static const String matchingTitle = 'Kundali Matching';
  static const String matchingCalculate = 'Calculate Matching';
  static const String matchingLoading = 'Calculating match...';
  static const String matchingError = 'Failed to calculate match.';

  // Predictions
  static const String predictionsTitle = 'Daily Predictions';
  static const String predictionsLoading = 'Loading predictions...';
  static const String predictionsError = 'Failed to load predictions.';

  // Calendar
  static const String calendarTitle = 'Hindu Calendar';
  static const String calendarLoading = 'Loading calendar...';
  static const String calendarError = 'Failed to load calendar.';

  static const String audioTitle = 'Audio Content';
  static const String audioPlay = 'Play';
  static const String audioPause = 'Pause';
  static const String audioStop = 'Stop';
  static const String audioNext = 'Next';
  static const String audioPrevious = 'Previous';
  static const String audioLoading = 'Loading audio...';
  static const String audioError = 'Failed to load audio.';

  // Validation
  static const String validationRequired = 'This field is required.';
  static const String validationEmail = 'Please enter a valid email address.';
  static const String validationPhone = 'Please enter a valid phone number.';
  static const String validationMinLength =
      'Minimum length is {min} characters.';
  static const String validationMaxLength =
      'Maximum length is {max} characters.';

  // Date/Time
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Placeholders
  static const String placeholderName = 'Enter your name';
  static const String placeholderEmail = 'Enter your email';
  static const String placeholderPhone = 'Enter your phone number';
  static const String placeholderSearch = 'Search...';

  // Empty States
  static const String emptyNoData = 'No data available';
  static const String emptyNoResults = 'No results found';
  static const String emptyNoFavorites = 'No favorites yet';
  static const String emptyNoHistory = 'No history available';

  // Confirmation Dialogs
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmDiscard =
      'Are you sure you want to discard changes?';
}
