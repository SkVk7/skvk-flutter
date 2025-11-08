/// User-Friendly Text Constants
///
/// This file contains user-friendly text alternatives to technical
/// astrological terms, making the app accessible to common people
library;

class UserFriendlyText {
  // App Titles and Headers
  static const String appTitle = 'Your Life Guide';
  static const String welcomeMessage = 'Welcome to Your Life Guide';
  static const String appSubtitle =
      'Discover what the stars have in store for you';

  // Feature Names (User-Friendly)
  static const String horoscope = 'My Birth Chart';
  static const String predictions = 'Daily Guidance';
  static const String calendar = 'Sacred Calendar';
  static const String matching = 'Compatibility Check';
  static const String profile = 'My Profile';

  // Quick Actions
  static const String todaysGuidance = 'Today\'s Guidance';
  static const String myBirthChart = 'My Birth Chart';

  // Technical Terms (User-Friendly Alternatives)
  static const Map<String, String> technicalTerms = {
    // Planetary terms
    'Sun': 'Sun',
    'Moon': 'Moon',
    'Mars': 'Mars',
    'Mercury': 'Mercury',
    'Jupiter': 'Jupiter',
    'Venus': 'Venus',
    'Saturn': 'Saturn',
    'Rahu': 'North Node',
    'Ketu': 'South Node',

    // Zodiac signs
    'Aries': 'Aries (Ram)',
    'Taurus': 'Taurus (Bull)',
    'Gemini': 'Gemini (Twins)',
    'Cancer': 'Cancer (Crab)',
    'Leo': 'Leo (Lion)',
    'Virgo': 'Virgo (Virgin)',
    'Libra': 'Libra (Scales)',
    'Scorpio': 'Scorpio (Scorpion)',
    'Sagittarius': 'Sagittarius (Archer)',
    'Capricorn': 'Capricorn (Goat)',
    'Aquarius': 'Aquarius (Water Bearer)',
    'Pisces': 'Pisces (Fish)',

    // Nakshatras (Star Constellations)
    'Ashwini': 'Ashwini (Horse Head)',
    'Bharani': 'Bharani (Bearer)',
    'Krittika': 'Krittika (Cutter)',
    'Rohini': 'Rohini (Red One)',
    'Mrigashira': 'Mrigashira (Deer Head)',
    'Ardra': 'Ardra (Moist)',
    'Punarvasu': 'Punarvasu (Return of Light)',
    'Pushya': 'Pushya (Nourisher)',
    'Ashlesha': 'Ashlesha (Embrace)',
    'Magha': 'Magha (Mighty)',
    'Purva Phalguni': 'Purva Phalguni (Former Red One)',
    'Uttara Phalguni': 'Uttara Phalguni (Latter Red One)',
    'Hasta': 'Hasta (Hand)',
    'Chitra': 'Chitra (Bright)',
    'Swati': 'Swati (Independent)',
    'Vishakha': 'Vishakha (Forked)',
    'Anuradha': 'Anuradha (Following Radha)',
    'Jyeshtha': 'Jyeshtha (Eldest)',
    'Mula': 'Mula (Root)',
    'Purva Ashadha': 'Purva Ashadha (Former Invincible)',
    'Uttara Ashadha': 'Uttara Ashadha (Latter Invincible)',
    'Shravana': 'Shravana (Hearing)',
    'Dhanishta': 'Dhanishta (Wealthiest)',
    'Shatabhisha': 'Shatabhisha (Hundred Healers)',
    'Purva Bhadrapada': 'Purva Bhadrapada (Former Blessed Feet)',
    'Uttara Bhadrapada': 'Uttara Bhadrapada (Latter Blessed Feet)',
    'Revati': 'Revati (Wealthy)',

    // Houses
    '1st House': 'Personality & Appearance',
    '2nd House': 'Wealth & Family',
    '3rd House': 'Communication & Siblings',
    '4th House': 'Home & Mother',
    '5th House': 'Children & Creativity',
    '6th House': 'Health & Service',
    '7th House': 'Marriage & Partnership',
    '8th House': 'Transformation & Mysteries',
    '9th House': 'Higher Learning & Philosophy',
    '10th House': 'Career & Reputation',
    '11th House': 'Friends & Aspirations',
    '12th House': 'Spirituality & Subconscious',

    // Dasha periods
    'Dasha': 'Life Period',
    'Antardasha': 'Sub Period',
    'Pratyantardasha': 'Sub-sub Period',

    // Aspects
    'Conjunction': 'Close Connection',
    'Opposition': 'Balancing Force',
    'Trine': 'Harmonious Flow',
    'Square': 'Challenging Energy',
    'Sextile': 'Supportive Energy',

    // Dignities
    'Exalted': 'Very Strong',
    'Debilitated': 'Challenging',
    'Own Sign': 'Comfortable',
    'Neutral': 'Balanced',
  };

  // User-Friendly Descriptions
  static const Map<String, String> descriptions = {
    'horoscope_description':
        'Your personal birth chart showing the positions of planets at the time of your birth',
    'predictions_description':
        'Daily insights and guidance based on current planetary movements',
    'calendar_description':
        'Traditional Hindu calendar with auspicious dates and festivals',
    'matching_description':
        'Check compatibility between two people for marriage or relationships',
    'profile_description': 'Manage your personal information and birth details',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'calculation_complete': 'Your horoscope is ready!',
    'profile_saved': 'Your information has been saved successfully',
    'prediction_ready': 'Your daily guidance is ready',
    'matching_complete': 'Compatibility analysis is complete',
  };

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Unable to connect. Please check your internet connection',
    'calculation_error':
        'Something went wrong with the calculation. Please try again',
    'validation_error': 'Please check your information and try again',
    'unknown_error': 'Oops! Something unexpected happened. Please try again',
  };

  // Help Text
  static const Map<String, String> helpText = {
    'birth_time_help':
        'Enter the exact time you were born for accurate results',
    'birth_place_help': 'Select the city where you were born',
    'name_help': 'Enter your full name as it appears on official documents',
    'matching_help':
        'Enter birth details of both people to check compatibility',
  };

  /// Get user-friendly term for technical astrological term
  static String getFriendlyTerm(String technicalTerm) {
    return technicalTerms[technicalTerm] ?? technicalTerm;
  }

  /// Get user-friendly description for feature
  static String getFeatureDescription(String feature) {
    return descriptions['${feature}_description'] ??
        'Feature description not available';
  }

  /// Get user-friendly success message
  static String getSuccessMessage(String action) {
    return successMessages[action] ?? 'Action completed successfully';
  }

  /// Get user-friendly error message
  static String getErrorMessage(String error) {
    return errorMessages[error] ?? 'An error occurred. Please try again';
  }

  /// Get help text for field
  static String getHelpText(String field) {
    return helpText[field] ?? 'Help text not available';
  }

  /// Convert technical text to user-friendly text
  static String makeUserFriendly(String text) {
    String friendlyText = text;

    // Replace technical terms with user-friendly alternatives
    technicalTerms.forEach((technical, friendly) {
      friendlyText = friendlyText.replaceAll(technical, friendly);
    });

    return friendlyText;
  }
}
