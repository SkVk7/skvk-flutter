/// Global Translation Service
///
/// Single point of access for all translation functionality
/// Works like the astrology library - global, singleton, and comprehensive
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_service.dart';

/// Global Translation Service - Single point of access
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  /// Current language preferences
  LanguagePreferences? _currentPreferences;

  /// Translation cache for performance
  final Map<String, String> _cache = {};

  /// Hardcoded translations for all supported languages
  static const Map<SupportedLanguage, Map<String, String>> _translations = {
    SupportedLanguage.english: {
      // App Titles
      'horoscope_title': '⭐ Your Horoscope',
      'matching_title': '💕 Kundali Matching',
      'calendar_title': '📅 Hindu Calendar',
      'predictions_title': '👁️ Predictions',
      'profile_title': '🌟 My Profile',
      'home_title': '🔮 SKVK Astrology',

      // Common Terms
      'nakshatra': 'Nakshatra',
      'rashi': 'Rashi',
      'pada': 'Pada',
      'lucky_color': 'Lucky Color',
      'lucky_number': 'Lucky Number',
      'current_dasha': 'Current Dasha',
      'upcoming_dasha': 'Upcoming Dasha',
      'personal_information': 'Personal Information',
      'astrological_details': 'Astrological Details',
      'life_predictions': 'Life Predictions',
      'general_prediction': 'General Prediction',
      'career': 'Career',
      'health': 'Health',
      'basic_details': 'Basic Details',
      'dasha_periods': 'Dasha Periods',

      // Form Labels
      'name': 'Name',
      'dob': 'Date of Birth',
      'tob': 'Time of Birth',
      'pob': 'Place of Birth',
      'gender': 'Gender',
      'calculation_system': 'Calculation System',
      'ayanamsha_system': 'Ayanamsha System',
      'select_calculation_system': 'Select calculation system',
      'regional_recommendations': 'Regional Recommendations',

      // Actions
      'calculate': 'Calculate',
      'retry': 'Retry',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'share': 'Share',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',

      // Messages
      'loading': 'Loading...',
      'calculating': 'Calculating...',
      'error': 'Error',
      'success': 'Success',
      'no_data': 'No data available',
      'unknown': 'Unknown',

      // Language Settings
      'language_settings': 'Language Settings',
      'language': 'Language',
      'header_language': 'Header Language',
      'content_language': 'Content Language',
      'save_changes': 'Save Changes',
      'language_saved': 'Language settings saved successfully!',
      'save_error': 'Failed to save language settings',

      // Home Screen
      'welcome_title': 'Welcome to Your Life Guide',
      'welcome_subtitle':
          'Discover what the stars have in store for you with personalized insights and guidance',
      'quick_actions': 'Quick Actions',
      'my_birth_chart': 'My Birth Chart',
      'features': 'Features',
      'sacred_calendar': 'Sacred Calendar',
      'compatibility_check': 'Compatibility Check',
      'daily_insights': 'Daily Insights',
      'view_full_prediction': 'View Full Prediction',
      'complete_your_profile': 'Complete Your Profile',
      'complete_profile': 'Complete Profile',
      'my_profile': 'My Profile',
      'todays_guidance': 'Today\'s Guidance',

      // User Profile Screen
      'loading_profile': 'Loading profile...',
      'retry_profile': 'Retry',
      'no_profile_found': 'No Profile Found',
      'create_profile': 'Create Profile',
      'edit_profile': 'Edit Profile',
      'share_profile': 'Share Profile',
      'error_updating_profile_picture': 'Error updating profile picture',
      'no_profile_to_share': 'No profile to share',
      'profile_sharing_coming_soon': 'Profile sharing feature coming soon',

      // Matching Screen
      'kundali_matching': 'Kundali Matching',
      'partner_details': 'Partner Details',
      'partner_name': 'Name',
      'date_of_birth': 'Date of Birth',
      'time_of_birth': 'Time of Birth',
      'place_of_birth': 'Place of Birth',
      'select_place': 'Select Place',
      'matching_calculation_system': 'Calculation System',
      'matching_select_calculation_system': 'Select calculation system',
      'choose_based_on_region': 'Choose based on your region',
      'edit_partner_details': 'Edit Partner Details',
      'matching_calculating': 'Calculating...',
      'perform_matching': 'Perform Matching',
      'your_details': 'Your Details',
      'matching_personal_information': 'Personal Information',
      'matching_dob': 'DOB',
      'matching_tob': 'TOB',
      'nakshatram': 'Nakshatram',
      'raasi': 'Raasi',
      'matching_results': 'Matching Results',
      'compatibility_score': 'Compatibility Score',
      'detailed_guna_milan_analysis': 'Detailed Guna Milan Analysis',
      'overall_compatibility_insights': 'Overall Compatibility Insights',
      'matching_ayanamsha_system': 'Ayanamsha System',

      // Calendar Screen
      'calendar': 'Calendar',
      'year': 'Year',
      'month': 'Month',
      'week': 'Week',
      'day': 'Day',
      'festivals': 'Festivals',
      'auspicious': 'Auspicious',
      'hindu_info': 'Hindu Info',
      'no_festivals_today': 'No festivals today',
      'upcoming_festivals': 'Upcoming Festivals',
      'no_upcoming_festivals': 'No upcoming festivals',
      'festival': 'Festival',

      // Predictions Screen
      'daily_predictions': 'Daily Predictions',
      'good_day_ahead': 'Good day ahead',
      'general_outlook': 'General Outlook',
      'love': 'Love',
      'prediction_career': 'Career',
      'prediction_health': 'Health',
      'finance': 'Finance',
      'harmony_in_relationships': 'Harmony in relationships',
      'progress_in_work': 'Progress in work',
      'good_health': 'Good health',
      'stable_finances': 'Stable finances',
      'lucky_numbers': 'Lucky Numbers',
      'lucky_colors': 'Lucky Colors',
      'auspicious_time': 'Auspicious Time',
      'avoid_time': 'Avoid Time',
      'dasha_influence': 'Dasha Influence',
      'remedies': 'Remedies',
      'explanation': 'Explanation',
      'based_on_planetary_positions': 'Based on current planetary positions and dasha influences',
      'venus_moon_influences': 'Venus and Moon influences on emotional connections',
      'sun_mars_influences': 'Sun and Mars influences on professional growth',
      'moon_mars_health_influences': 'Moon and Mars influences on physical and mental health',
      'jupiter_venus_finances': 'Jupiter and Venus influences on financial matters',
      'numerical_associations':
          'Based on current planetary positions and their numerical associations',
      'colors_strong_planets': 'Colors associated with currently strong planets',
      'best_time_activities': 'Best time for important activities based on planetary influences',
      'avoid_important_decisions': 'Time to avoid important decisions or activities',
      'current_dasha_effects': 'Current planetary period and its effects on your life',
      'suggested_remedies': 'Suggested remedies to enhance positive influences',

      // Horoscope Screen
      'horoscope': 'Horoscope',
      'please_complete_profile': 'Please complete your profile to view your horoscope.',
      'no_upcoming_dasha_period': 'No upcoming dasha period',
      'horoscope_calculation_system': 'Calculation System',

      // Matching Screen
      'matching_kundali_matching': 'Kundali Matching',

      // Additional Predictions Screen
      'love_relationships': 'Love & Relationships',
      'career_professional': 'Career & Professional',
      'health_wellness': 'Health & Wellness',
      'finance_money': 'Finance & Money',
      'career_work': 'Career & Work',
      'health_wellbeing': 'Health & Wellbeing',
      'finance_wealth': 'Finance & Wealth',
      'additional_lucky_numbers': 'Lucky Numbers',
      'additional_lucky_colors': 'Lucky Colors',
      'additional_auspicious_time': 'Auspicious Time',
      'additional_avoid_time': 'Avoid Time',
      'additional_dasha_influence': 'Dasha Influence',
      'additional_remedies': 'Remedies',
    },
    SupportedLanguage.hindi: {
      // App Titles
      'horoscope_title': '⭐ आपकी कुंडली',
      'matching_title': '💕 कुंडली मिलान',
      'calendar_title': '📅 हिंदू कैलेंडर',
      'predictions_title': '👁️ भविष्यवाणी',
      'profile_title': '🌟 मेरा प्रोफाइल',
      'home_title': '🔮 एसकेवीके ज्योतिष',

      // Common Terms
      'nakshatra': 'नक्षत्र',
      'rashi': 'राशि',
      'pada': 'पाद',
      'lucky_color': 'शुभ रंग',
      'lucky_number': 'शुभ संख्या',
      'current_dasha': 'वर्तमान दशा',
      'upcoming_dasha': 'आगामी दशा',
      'personal_information': 'व्यक्तिगत जानकारी',
      'astrological_details': 'ज्योतिषीय विवरण',
      'life_predictions': 'जीवन भविष्यवाणी',
      'general_prediction': 'सामान्य भविष्यवाणी',
      'career': 'करियर',
      'health': 'स्वास्थ्य',
      'basic_details': 'मूल विवरण',
      'dasha_periods': 'दशा अवधि',

      // Form Labels
      'name': 'नाम',
      'dob': 'जन्म तिथि',
      'tob': 'जन्म समय',
      'pob': 'जन्म स्थान',
      'gender': 'लिंग',
      'calculation_system': 'गणना प्रणाली',
      'ayanamsha_system': 'अयनांश प्रणाली',
      'select_calculation_system': 'गणना प्रणाली चुनें',
      'regional_recommendations': 'क्षेत्रीय सिफारिशें',

      // Actions
      'calculate': 'गणना करें',
      'retry': 'पुनः प्रयास',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'edit': 'संपादित करें',
      'share': 'साझा करें',
      'back': 'वापस',
      'next': 'अगला',
      'done': 'पूर्ण',

      // Messages
      'loading': 'लोड हो रहा है...',
      'calculating': 'गणना हो रही है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'no_data': 'कोई डेटा उपलब्ध नहीं',
      'unknown': 'अज्ञात',

      // Language Settings
      'language_settings': 'भाषा सेटिंग्स',
      'language': 'भाषा',
      'header_language': 'हेडर भाषा',
      'content_language': 'सामग्री भाषा',
      'save_changes': 'परिवर्तन सहेजें',
      'language_saved': 'भाषा सेटिंग्स सफलतापूर्वक सहेजी गईं!',
      'save_error': 'भाषा सेटिंग्स सहेजने में विफल',

      // Home Screen
      'welcome_title': 'आपके जीवन गाइड में आपका स्वागत है',
      'welcome_subtitle':
          'व्यक्तिगत अंतर्दृष्टि और मार्गदर्शन के साथ जानें कि तारे आपके लिए क्या रखे हैं',
      'quick_actions': 'त्वरित कार्य',
      'my_birth_chart': 'मेरी जन्म कुंडली',
      'features': 'विशेषताएं',
      'sacred_calendar': 'पवित्र कैलेंडर',
      'compatibility_check': 'संगतता जांच',
      'daily_insights': 'दैनिक अंतर्दृष्टि',
      'view_full_prediction': 'पूर्ण भविष्यवाणी देखें',
      'complete_your_profile': 'अपना प्रोफाइल पूरा करें',
      'complete_profile': 'प्रोफाइल पूरा करें',
      'my_profile': 'मेरा प्रोफाइल',
      'todays_guidance': 'आज का मार्गदर्शन',

      // User Profile Screen
      'loading_profile': 'प्रोफाइल लोड हो रहा है...',
      'retry_profile': 'पुनः प्रयास करें',
      'no_profile_found': 'कोई प्रोफाइल नहीं मिला',
      'create_profile': 'प्रोफाइल बनाएं',
      'edit_profile': 'प्रोफाइल संपादित करें',
      'share_profile': 'प्रोफाइल साझा करें',
      'error_updating_profile_picture': 'प्रोफाइल तस्वीर अपडेट करने में त्रुटि',
      'no_profile_to_share': 'साझा करने के लिए कोई प्रोफाइल नहीं',
      'profile_sharing_coming_soon': 'प्रोफाइल साझाकरण सुविधा जल्द आ रही है',

      // Matching Screen
      'kundali_matching': 'कुंडली मिलान',
      'partner_details': 'साथी का विवरण',
      'partner_name': 'नाम',
      'date_of_birth': 'जन्म तिथि',
      'time_of_birth': 'जन्म समय',
      'place_of_birth': 'जन्म स्थान',
      'select_place': 'स्थान चुनें',
      'matching_calculation_system': 'गणना प्रणाली',
      'matching_select_calculation_system': 'गणना प्रणाली चुनें',
      'choose_based_on_region': 'अपने क्षेत्र के आधार पर चुनें',
      'edit_partner_details': 'साथी का विवरण संपादित करें',
      'matching_calculating': 'गणना हो रही है...',
      'perform_matching': 'मिलान करें',
      'your_details': 'आपका विवरण',
      'matching_personal_information': 'व्यक्तिगत जानकारी',
      'matching_dob': 'जन्म तिथि',
      'matching_tob': 'जन्म समय',
      'nakshatram': 'नक्षत्र',
      'raasi': 'राशि',
      'matching_results': 'मिलान परिणाम',
      'compatibility_score': 'संगतता स्कोर',
      'detailed_guna_milan_analysis': 'विस्तृत गुण मिलान विश्लेषण',
      'overall_compatibility_insights': 'समग्र संगतता अंतर्दृष्टि',
      'matching_ayanamsha_system': 'अयनांश प्रणाली',

      // Calendar Screen
      'calendar': 'हिंदू कैलेंडर',
      'year': 'वर्ष',
      'month': 'महीना',
      'week': 'सप्ताह',
      'day': 'दिन',
      'festivals': 'त्योहार',
      'auspicious': 'शुभ',
      'hindu_info': 'हिंदू जानकारी',
      'no_festivals_today': 'आज कोई त्योहार नहीं',
      'upcoming_festivals': 'आगामी त्योहार',
      'no_upcoming_festivals': 'कोई आगामी त्योहार नहीं',
      'festival': 'त्योहार',

      // Predictions Screen
      'daily_predictions': 'दैनिक भविष्यवाणी',
      'good_day_ahead': 'आगे अच्छा दिन',
      'general_outlook': 'सामान्य दृष्टिकोण',
      'love': 'प्रेम',
      'prediction_career': 'करियर',
      'prediction_health': 'स्वास्थ्य',
      'finance': 'वित्त',
      'harmony_in_relationships': 'रिश्तों में सामंजस्य',
      'progress_in_work': 'काम में प्रगति',
      'good_health': 'अच्छा स्वास्थ्य',
      'stable_finances': 'स्थिर वित्त',
      'lucky_numbers': 'भाग्यशाली नंबर',
      'additional_lucky_colors': 'भाग्यशाली रंग',
      'additional_auspicious_time': 'शुभ समय',
      'additional_avoid_time': 'बचने का समय',
      'additional_dasha_influence': 'दशा प्रभाव',
      'remedies': 'उपाय',
      'explanation': 'व्याख्या',
      'based_on_planetary_positions': 'वर्तमान ग्रह स्थिति और दशा प्रभावों के आधार पर',
      'venus_moon_influences': 'भावनात्मक संबंधों पर शुक्र और चंद्रमा का प्रभाव',
      'sun_mars_influences': 'व्यावसायिक विकास पर सूर्य और मंगल का प्रभाव',
      'moon_mars_health_influences': 'शारीरिक और मानसिक स्वास्थ्य पर चंद्रमा और मंगल का प्रभाव',
      'jupiter_venus_finances': 'वित्तीय मामलों पर बृहस्पति और शुक्र का प्रभाव',
      'numerical_associations': 'वर्तमान ग्रह स्थितियों और उनके संख्यात्मक संबंधों के आधार पर',
      'colors_strong_planets': 'वर्तमान में मजबूत ग्रहों से जुड़े रंग',
      'best_time_activities': 'ग्रह प्रभावों के आधार पर महत्वपूर्ण गतिविधियों के लिए सर्वोत्तम समय',
      'avoid_important_decisions': 'महत्वपूर्ण निर्णय या गतिविधियों से बचने का समय',
      'current_dasha_effects': 'वर्तमान ग्रह अवधि और आपके जीवन पर इसके प्रभाव',
      'suggested_remedies': 'सकारात्मक प्रभावों को बढ़ाने के लिए सुझाए गए उपाय',

      // Horoscope Screen
      'horoscope': 'कुंडली',
      'please_complete_profile': 'अपनी कुंडली देखने के लिए कृपया अपना प्रोफाइल पूरा करें।',
      'no_upcoming_dasha_period': 'कोई आगामी दशा अवधि नहीं',
      'horoscope_calculation_system': 'गणना प्रणाली',

      // Matching Screen
      'matching_kundali_matching': 'कुंडली मिलान',

      // Additional Predictions Screen
      'love_relationships': 'प्रेम और रिश्ते',
      'career_professional': 'करियर और व्यावसायिक',
      'health_wellness': 'स्वास्थ्य और कल्याण',
      'finance_money': 'वित्त और धन',
    },
    SupportedLanguage.telugu: {
      // App Titles
      'horoscope_title': '⭐ మీ జాతకం',
      'matching_title': '💕 జాతక మిలనం',
      'calendar_title': '📅 హిందూ క్యాలెండర్',
      'predictions_title': '👁️ భవిష్యత్',
      'profile_title': '🌟 నా ప్రొఫైల్',
      'home_title': '🔮 ఎస్.కె.వి.కె. జ్యోతిష్యం',

      // Common Terms
      'nakshatra': 'నక్షత్రం',
      'rashi': 'రాశి',
      'pada': 'పాదం',
      'lucky_color': 'అదృష్ట రంగు',
      'lucky_number': 'అదృష్ట సంఖ్య',
      'current_dasha': 'ప్రస్తుత దశ',
      'upcoming_dasha': 'రాబోయే దశ',
      'personal_information': 'వ్యక్తిగత సమాచారం',
      'astrological_details': 'జ్యోతిష్య వివరాలు',
      'life_predictions': 'జీవిత భవిష్యత్',
      'general_prediction': 'సాధారణ భవిష్యత్',
      'career': 'వృత్తి',
      'health': 'ఆరోగ్యం',
      'basic_details': 'ప్రాథమిక వివరాలు',
      'dasha_periods': 'దశ కాలాలు',

      // Form Labels
      'name': 'పేరు',
      'dob': 'జన్మ తేదీ',
      'tob': 'జన్మ సమయం',
      'pob': 'జన్మ స్థలం',
      'gender': 'లింగం',
      'calculation_system': 'లెక్కింపు వ్యవస్థ',
      'ayanamsha_system': 'అయనాంశ వ్యవస్థ',
      'select_calculation_system': 'లెక్కింపు వ్యవస్థను ఎంచుకోండి',
      'regional_recommendations': 'ప్రాంతీయ సిఫార్సులు',

      // Actions
      'calculate': 'లెక్కించు',
      'retry': 'మళ్లీ ప్రయత్నించు',
      'save': 'సేవ్ చేయి',
      'cancel': 'రద్దు చేయి',
      'edit': 'సవరించు',
      'share': 'భాగస్వామ్యం',
      'back': 'వెనుక',
      'next': 'తదుపరి',
      'done': 'పూర్తి',

      // Messages
      'loading': 'లోడ్ అవుతోంది...',
      'calculating': 'లెక్కిస్తోంది...',
      'error': 'లోపం',
      'success': 'విజయం',
      'no_data': 'డేటా లేదు',
      'unknown': 'తెలియదు',

      // Language Settings
      'language_settings': 'భాషా సెట్టింగులు',
      'language': 'భాష',
      'header_language': 'హెడర్ భాష',
      'content_language': 'విషయం భాష',
      'save_changes': 'మార్పులు సేవ్ చేయి',
      'language_saved': 'భాషా సెట్టింగులు విజయవంతంగా సేవ్ చేయబడ్డాయి!',
      'save_error': 'భాషా సెట్టింగులు సేవ్ చేయడంలో విఫలమైంది',

      // Home Screen
      'welcome_title': 'మీ జీవిత గైడ్‌కు స్వాగతం',
      'welcome_subtitle':
          'వ్యక్తిగత అంతర్దృష్టులు మరియు మార్గదర్శకత్వంతో నక్షత్రాలు మీ కోసం ఏమి ఉంచాయో కనుగొనండి',
      'quick_actions': 'త్వరిత చర్యలు',
      'my_birth_chart': 'నా జన్మ చార్ట్',
      'features': 'లక్షణాలు',
      'sacred_calendar': 'పవిత్ర క్యాలెండర్',
      'compatibility_check': 'అనుకూలత తనిఖీ',
      'daily_insights': 'రోజువారీ అంతర్దృష్టులు',
      'view_full_prediction': 'పూర్తి భవిష్యత్తును చూడండి',
      'complete_your_profile': 'మీ ప్రొఫైల్‌ను పూర్తి చేయండి',
      'complete_profile': 'ప్రొఫైల్ పూర్తి చేయండి',
      'my_profile': 'నా ప్రొఫైల్',
      'todays_guidance': 'ఈరోజు మార్గదర్శకత్వం',

      // User Profile Screen
      'loading_profile': 'ప్రొఫైల్ లోడ్ అవుతోంది...',
      'retry_profile': 'మళ్లీ ప్రయత్నించండి',
      'no_profile_found': 'ప్రొఫైల్ కనుగొనబడలేదు',
      'create_profile': 'ప్రొఫైల్ సృష్టించండి',
      'edit_profile': 'ప్రొఫైల్ సవరించండి',
      'share_profile': 'ప్రొఫైల్ భాగస్వామ్యం చేయండి',
      'error_updating_profile_picture': 'ప్రొఫైల్ చిత్రాన్ని నవీకరించడంలో లోపం',
      'no_profile_to_share': 'భాగస్వామ్యం చేయడానికి ప్రొఫైల్ లేదు',
      'profile_sharing_coming_soon': 'ప్రొఫైల్ భాగస్వామ్యం ఫీచర్ త్వరలో వస్తోంది',

      // Matching Screen
      'kundali_matching': 'జాతక మిలనం',
      'partner_details': 'భాగస్వామి వివరాలు',
      'partner_name': 'పేరు',
      'date_of_birth': 'పుట్టిన తేదీ',
      'time_of_birth': 'పుట్టిన సమయం',
      'place_of_birth': 'పుట్టిన స్థలం',
      'select_place': 'స్థలం ఎంచుకోండి',
      'matching_calculation_system': 'లెక్కింపు వ్యవస్థ',
      'matching_select_calculation_system': 'లెక్కింపు వ్యవస్థను ఎంచుకోండి',
      'choose_based_on_region': 'మీ ప్రాంతం ఆధారంగా ఎంచుకోండి',
      'edit_partner_details': 'భాగస్వామి వివరాలను సవరించండి',
      'matching_calculating': 'లెక్కిస్తోంది...',
      'perform_matching': 'మిలనం చేయండి',
      'your_details': 'మీ వివరాలు',
      'matching_personal_information': 'వ్యక్తిగత సమాచారం',
      'matching_dob': 'పుట్టిన తేదీ',
      'matching_tob': 'పుట్టిన సమయం',
      'nakshatram': 'నక్షత్రం',
      'raasi': 'రాశి',
      'matching_results': 'మిలన ఫలితాలు',
      'compatibility_score': 'అనుకూలత స్కోర్',
      'detailed_guna_milan_analysis': 'వివరణాత్మక గుణ మిలన విశ్లేషణ',
      'overall_compatibility_insights': 'మొత్తం అనుకూలత అంతర్దృష్టులు',
      'matching_ayanamsha_system': 'అయనాంశ వ్యవస్థ',

      // Calendar Screen
      'calendar': 'హిందూ క్యాలెండర్',
      'year': 'సంవత్సరం',
      'month': 'నెల',
      'week': 'వారం',
      'day': 'రోజు',
      'festivals': 'పండుగలు',
      'auspicious': 'శుభ',
      'hindu_info': 'హిందూ సమాచారం',
      'no_festivals_today': 'ఈరోజు పండుగలు లేవు',
      'upcoming_festivals': 'రాబోయే పండుగలు',
      'no_upcoming_festivals': 'రాబోయే పండుగలు లేవు',
      'festival': 'పండుగ',

      // Predictions Screen
      'daily_predictions': 'రోజువారీ అంచనాలు',
      'good_day_ahead': 'మంచి రోజు ముందుంది',
      'general_outlook': 'సాధారణ దృక్పథం',
      'love': 'ప్రేమ',
      'prediction_career': 'వృత్తి',
      'prediction_health': 'ఆరోగ్యం',
      'finance': 'ఆర్థిక',
      'harmony_in_relationships': 'సంబంధాలలో సామరస్యం',
      'progress_in_work': 'పనిలో పురోగతి',
      'good_health': 'మంచి ఆరోగ్యం',
      'stable_finances': 'స్థిరమైన ఆర్థిక స్థితి',
      'lucky_numbers': 'అదృష్ట సంఖ్యలు',
      'additional_lucky_colors': 'అదృష్ట రంగులు',
      'additional_auspicious_time': 'శుభ సమయం',
      'additional_avoid_time': 'నివారించాల్సిన సమయం',
      'additional_dasha_influence': 'దశ ప్రభావం',
      'remedies': 'పరిహారాలు',
      'explanation': 'వివరణ',
      'based_on_planetary_positions': 'ప్రస్తుత గ్రహ స్థానాలు మరియు దశ ప్రభావాల ఆధారంగా',
      'venus_moon_influences': 'భావోద్వేగ సంబంధాలపై శుక్ర మరియు చంద్ర ప్రభావాలు',
      'sun_mars_influences': 'వృత్తిపరమైన వృద్ధిపై సూర్య మరియు మంగళ ప్రభావాలు',
      'moon_mars_health_influences': 'శారీరక మరియు మానసిక ఆరోగ్యంపై చంద్ర మరియు మంగళ ప్రభావాలు',
      'jupiter_venus_finances': 'ఆర్థిక విషయాలపై గురు మరియు శుక్ర ప్రభావాలు',
      'numerical_associations': 'ప్రస్తుత గ్రహ స్థానాలు మరియు వాటి సంఖ్యా సంబంధాల ఆధారంగా',
      'colors_strong_planets': 'ప్రస్తుతం బలమైన గ్రహాలతో సంబంధం ఉన్న రంగులు',
      'best_time_activities': 'గ్రహ ప్రభావాల ఆధారంగా ముఖ్యమైన కార్యకలాపాలకు ఉత్తమ సమయం',
      'avoid_important_decisions': 'ముఖ్యమైన నిర్ణయాలు లేదా కార్యకలాపాలను నివారించాల్సిన సమయం',
      'current_dasha_effects': 'ప్రస్తుత గ్రహ కాలం మరియు మీ జీవితంపై దాని ప్రభావాలు',
      'suggested_remedies': 'సానుకూల ప్రభావాలను మెరుగుపరచడానికి సూచించిన పరిహారాలు',

      // Horoscope Screen
      'horoscope': 'జాతకం',
      'please_complete_profile': 'మీ జాతకాన్ని చూడటానికి దయచేసి మీ ప్రొఫైల్‌ను పూర్తి చేయండి.',
      'no_upcoming_dasha_period': 'రాబోయే దశా కాలం లేదు',
      'horoscope_calculation_system': 'లెక్కింపు వ్యవస్థ',

      // Matching Screen
      'matching_kundali_matching': 'కుండలి మిలన్',

      // Additional Predictions Screen
      'love_relationships': 'ప్రేమ మరియు సంబంధాలు',
      'career_professional': 'వృత్తి మరియు వృత్తిపరమైన',
      'health_wellness': 'ఆరోగ్యం మరియు క్షేమం',
      'finance_money': 'ఆర్థిక మరియు డబ్బు',
    },
    SupportedLanguage.tamil: {
      // App Titles
      'horoscope_title': '⭐ உங்கள் ஜாதகம்',
      'matching_title': '💕 ஜாதக பொருத்தம்',
      'calendar_title': '📅 இந்து நாட்காட்டி',
      'predictions_title': '👁️ கணிப்புகள்',
      'profile_title': '🌟 எனது சுயவிவரம்',
      'home_title': '🔮 எஸ்.கே.வி.கே. ஜோதிடம்',

      // Common Terms
      'nakshatra': 'நட்சத்திரம்',
      'rashi': 'ராசி',
      'pada': 'பாதம்',
      'lucky_color': 'அதிர்ஷ்ட நிறம்',
      'lucky_number': 'அதிர்ஷ்ட எண்',
      'current_dasha': 'தற்போதைய தசை',
      'upcoming_dasha': 'வரவிருக்கும் தசை',
      'personal_information': 'தனிப்பட்ட தகவல்',
      'astrological_details': 'ஜோதிட விவரங்கள்',
      'life_predictions': 'வாழ்க்கை கணிப்புகள்',
      'general_prediction': 'பொது கணிப்பு',
      'career': 'வேலை',
      'health': 'ஆரோக்கியம்',
      'basic_details': 'அடிப்படை விவரங்கள்',
      'dasha_periods': 'தசை காலங்கள்',

      // Form Labels
      'name': 'பெயர்',
      'dob': 'பிறந்த தேதி',
      'tob': 'பிறந்த நேரம்',
      'pob': 'பிறந்த இடம்',
      'gender': 'பாலினம்',
      'calculation_system': 'கணக்கீட்டு முறை',
      'ayanamsha_system': 'அயனாம்ச முறை',
      'select_calculation_system': 'கணக்கீட்டு முறையைத் தேர்ந்தெடுக்கவும்',
      'regional_recommendations': 'பிராந்திய பரிந்துரைகள்',

      // Actions
      'calculate': 'கணக்கிடு',
      'retry': 'மீண்டும் முயற்சி',
      'save': 'சேமி',
      'cancel': 'ரத்து செய்',
      'edit': 'திருத்து',
      'share': 'பகிர்',
      'back': 'பின்',
      'next': 'அடுத்து',
      'done': 'முடிந்தது',

      // Messages
      'loading': 'ஏற்றப்படுகிறது...',
      'calculating': 'கணக்கிடப்படுகிறது...',
      'error': 'பிழை',
      'success': 'வெற்றி',
      'no_data': 'தரவு இல்லை',
      'unknown': 'தெரியவில்லை',

      // Language Settings
      'language_settings': 'மொழி அமைப்புகள்',
      'language': 'மொழி',
      'header_language': 'தலைப்பு மொழி',
      'content_language': 'உள்ளடக்கம் மொழி',
      'save_changes': 'மாற்றங்களை சேமி',
      'language_saved': 'மொழி அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன!',
      'save_error': 'மொழி அமைப்புகளை சேமிக்க முடியவில்லை',

      // Home Screen
      'welcome_title': 'உங்கள் வாழ்க்கை வழிகாட்டிக்கு வரவேற்கிறோம்',
      'welcome_subtitle':
          'தனிப்பட்ட நுண்ணறிவுகள் மற்றும் வழிகாட்டுதலுடன் நட்சத்திரங்கள் உங்களுக்காக என்ன வைத்திருக்கின்றன என்பதைக் கண்டறியுங்கள்',
      'quick_actions': 'விரைவு செயல்கள்',
      'my_birth_chart': 'எனது பிறப்பு சார்ட்',
      'features': 'அம்சங்கள்',
      'sacred_calendar': 'புனித நாட்காட்டி',
      'compatibility_check': 'பொருத்தம் சரிபார்ப்பு',
      'daily_insights': 'தினசரி நுண்ணறிவுகள்',
      'view_full_prediction': 'முழு கணிப்பைக் காண்க',
      'complete_your_profile': 'உங்கள் சுயவிவரத்தை முடிக்கவும்',
      'complete_profile': 'சுயவிவரத்தை முடிக்கவும்',
      'my_profile': 'எனது சுயவிவரம்',
      'todays_guidance': 'இன்றைய வழிகாட்டுதல்',

      // User Profile Screen
      'loading_profile': 'சுயவிவரம் ஏற்றப்படுகிறது...',
      'retry_profile': 'மீண்டும் முயற்சி',
      'no_profile_found': 'சுயவிவரம் கிடைக்கவில்லை',
      'create_profile': 'சுயவிவரம் உருவாக்கவும்',
      'edit_profile': 'சுயவிவரத்தை திருத்தவும்',
      'share_profile': 'சுயவிவரத்தை பகிரவும்',
      'error_updating_profile_picture': 'சுயவிவர படத்தை புதுப்பிக்கும் போது பிழை',
      'no_profile_to_share': 'பகிர்வதற்கு சுயவிவரம் இல்லை',
      'profile_sharing_coming_soon': 'சுயவிவர பகிர்வு அம்சம் விரைவில் வருகிறது',

      // Matching Screen
      'kundali_matching': 'ஜாதக பொருத்தம்',
      'partner_details': 'பங்காளி விவரங்கள்',
      'partner_name': 'பெயர்',
      'date_of_birth': 'பிறந்த தேதி',
      'time_of_birth': 'பிறந்த நேரம்',
      'place_of_birth': 'பிறந்த இடம்',
      'select_place': 'இடத்தைத் தேர்ந்தெடுக்கவும்',
      'matching_calculation_system': 'கணக்கீட்டு முறை',
      'matching_select_calculation_system': 'கணக்கீட்டு முறையைத் தேர்ந்தெடுக்கவும்',
      'choose_based_on_region': 'உங்கள் பிராந்தியத்தின் அடிப்படையில் தேர்ந்தெடுக்கவும்',
      'edit_partner_details': 'பங்காளி விவரங்களைத் திருத்தவும்',
      'matching_calculating': 'கணக்கிடுகிறது...',
      'perform_matching': 'பொருத்தத்தைச் செய்யவும்',
      'your_details': 'உங்கள் விவரங்கள்',
      'matching_personal_information': 'தனிப்பட்ட தகவல்',
      'matching_dob': 'பிறந்த தேதி',
      'matching_tob': 'பிறந்த நேரம்',
      'nakshatram': 'நட்சத்திரம்',
      'raasi': 'ராசி',
      'matching_results': 'பொருத்த முடிவுகள்',
      'compatibility_score': 'ஒருங்கிணைப்பு மதிப்பெண்',
      'detailed_guna_milan_analysis': 'விரிவான குண மிலன் பகுப்பாய்வு',
      'overall_compatibility_insights': 'மொத்த ஒருங்கிணைப்பு நுண்ணறிவுகள்',
      'matching_ayanamsha_system': 'அயனாங்க வழிமுறை',

      // Calendar Screen
      'calendar': 'இந்து நாட்காட்டி',
      'year': 'ஆண்டு',
      'month': 'மாதம்',
      'week': 'வாரம்',
      'day': 'நாள்',
      'festivals': 'திருவிழாக்கள்',
      'auspicious': 'சுப',
      'hindu_info': 'இந்து தகவல்',
      'no_festivals_today': 'இன்று திருவிழாக்கள் இல்லை',
      'upcoming_festivals': 'வரவிருக்கும் திருவிழாக்கள்',
      'no_upcoming_festivals': 'வரவிருக்கும் திருவிழாக்கள் இல்லை',
      'festival': 'திருவிழா',

      // Predictions Screen
      'daily_predictions': 'தினசரி கணிப்புகள்',
      'good_day_ahead': 'நல்ல நாள் முன்னால்',
      'general_outlook': 'பொதுவான பார்வை',
      'love': 'காதல்',
      'prediction_career': 'தொழில்',
      'prediction_health': 'உடல்நலம்',
      'finance': 'நிதி',
      'harmony_in_relationships': 'உறவுகளில் இணக்கம்',
      'progress_in_work': 'வேலையில் முன்னேற்றம்',
      'good_health': 'நல்ல ஆரோக்கியம்',
      'stable_finances': 'நிலையான நிதி',
      'lucky_numbers': 'அதிர்ஷ்ட எண்கள்',
      'additional_lucky_colors': 'அதிர்ஷ்ட நிறங்கள்',
      'additional_auspicious_time': 'சுப நேரம்',
      'additional_avoid_time': 'தவிர்க்க வேண்டிய நேரம்',
      'additional_dasha_influence': 'தசா செல்வாக்கு',
      'remedies': 'தீர்வுகள்',
      'explanation': 'விளக்கம்',
      'based_on_planetary_positions': 'தற்போதைய கிரக நிலைகள் மற்றும் தசா தாக்கங்களின் அடிப்படையில்',
      'venus_moon_influences': 'உணர்ச்சி தொடர்புகளில் சுக்ரன் மற்றும் சந்திரன் செல்வாக்குகள்',
      'sun_mars_influences': 'தொழில்முறை வளர்ச்சியில் சூரியன் மற்றும் செவ்வாய் செல்வாக்குகள்',
      'moon_mars_health_influences':
          'உடல் மற்றும் மன ஆரோக்கியத்தில் சந்திரன் மற்றும் செவ்வாய் செல்வாக்குகள்',
      'jupiter_venus_finances': 'நிதி விஷயங்களில் குரு மற்றும் சுக்ரன் செல்வாக்குகள்',
      'numerical_associations':
          'தற்போதைய கிரக நிலைகள் மற்றும் அவற்றின் எண் தொடர்புகளின் அடிப்படையில்',
      'colors_strong_planets': 'தற்போது வலுவான கிரகங்களுடன் தொடர்புடைய நிறங்கள்',
      'best_time_activities':
          'கிரக தாக்கங்களின் அடிப்படையில் முக்கியமான நடவடிக்கைகளுக்கான சிறந்த நேரம்',
      'avoid_important_decisions':
          'முக்கியமான முடிவுகள் அல்லது நடவடிக்கைகளைத் தவிர்க்க வேண்டிய நேரம்',
      'current_dasha_effects': 'தற்போதைய கிரக காலம் மற்றும் உங்கள் வாழ்க்கையில் அதன் விளைவுகள்',
      'suggested_remedies': 'நேர்மறை தாக்கங்களை மேம்படுத்த பரிந்துரைக்கப்பட்ட தீர்வுகள்',

      // Horoscope Screen
      'horoscope': 'ஜாதகம்',
      'please_complete_profile':
          'உங்கள் ஜாதகத்தைப் பார்க்க தயவுசெய்து உங்கள் சுயவிவரத்தை முடிக்கவும்.',
      'no_upcoming_dasha_period': 'வரவிருக்கும் தசா காலம் இல்லை',
      'horoscope_calculation_system': 'கணக்கீட்டு முறை',

      // Matching Screen
      'matching_kundali_matching': 'குண்டலி மிலன்',

      // Additional Predictions Screen
      'love_relationships': 'காதல் மற்றும் உறவுகள்',
      'career_professional': 'தொழில் மற்றும் தொழில்முறை',
      'health_wellness': 'ஆரோக்கியம் மற்றும் நல்வாழ்வு',
      'finance_money': 'நிதி மற்றும் பணம்',
    },
  };

  /// Initialize the translation service
  void initialize(LanguagePreferences preferences) {
    _currentPreferences = preferences;
    _cache.clear();
  }

  /// Update language preferences
  void updatePreferences(LanguagePreferences preferences) {
    _currentPreferences = preferences;
    _cache.clear(); // Clear cache when language changes
  }

  /// Translate text for headers (uses header language)
  String translateHeader(String key, {String? fallback}) {
    if (_currentPreferences == null) return fallback ?? key;

    final cacheKey = 'header_${_currentPreferences!.headerLanguage.name}_$key';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final translation = _getTranslation(_currentPreferences!.headerLanguage, key);
    final result = translation ?? fallback ?? key;
    _cache[cacheKey] = result;
    return result;
  }

  /// Translate text for content (uses content language)
  String translateContent(String key, {String? fallback}) {
    if (_currentPreferences == null) return fallback ?? key;

    final cacheKey = 'content_${_currentPreferences!.contentLanguage.name}_$key';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final translation = _getTranslation(_currentPreferences!.contentLanguage, key);
    final result = translation ?? fallback ?? key;
    _cache[cacheKey] = result;
    return result;
  }

  /// Translate text with automatic language detection
  String translate(String key, {String? fallback}) {
    return translateContent(key, fallback: fallback);
  }

  /// Get translation for specific language
  String translateForLanguage(SupportedLanguage language, String key, {String? fallback}) {
    final cacheKey = '${language.name}_$key';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final translation = _getTranslation(language, key);
    final result = translation ?? fallback ?? key;
    _cache[cacheKey] = result;
    return result;
  }

  /// Get translation from hardcoded data
  String? _getTranslation(SupportedLanguage language, String key) {
    return _translations[language]?[key];
  }

  /// Clear translation cache
  void clearCache() {
    _cache.clear();
  }

  /// Get all available keys for a language
  List<String> getKeys(SupportedLanguage language) {
    return _translations[language]?.keys.toList() ?? [];
  }

  /// Check if translation exists
  bool hasTranslation(SupportedLanguage language, String key) {
    return _translations[language]?.containsKey(key) ?? false;
  }

  /// Get current language preferences
  LanguagePreferences? get currentPreferences => _currentPreferences;
}

/// Global translation service instance
final TranslationService globalTranslationService = TranslationService();

// Provider for reactive translation service
final translationServiceProvider = Provider<TranslationService>((ref) {
  // Watch language service to trigger rebuilds when language changes
  ref.watch(languageServiceProvider);
  return globalTranslationService;
});
