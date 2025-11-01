/// Enums for astrological calculations
///
/// These enums define the standard values used in Vedic astrology
library;

/// Calculation precision levels
///
/// For astrology applications, we always use maximum precision
/// to ensure 100% accuracy in all calculations.
enum CalculationPrecision {
  ultra, // Maximum precision (default for all calculations)
}

/// Ayanamsha types
enum AyanamshaType {
  lahiri, // Most commonly used in India
  raman, // B.V. Raman
  krishnamurti, // K.P. System
  faganBradley, // Western sidereal
  yukteshwar, // Sri Yukteshwar
  jnBhasin, // J.N. Bhasin
  babylonian, // Babylonian
  sassanian, // Sassanian
  aldebaran15Tau, // Aldebaran 15° Taurus
  galacticCenter, // Galactic Center
  galacticEquator, // Galactic Equator
  galacticEquatorIAU1958, // IAU 1958
  galacticEquatorTrue, // True Galactic Equator
  galacticEquatorMula, // Mula Galactic Equator
  ayanamshaZero, // Zero Ayanamsha
  ayanamshaUser, // User defined
}

/// House systems
enum HouseSystem {
  placidus, // Most commonly used
  koch, // Koch houses
  equal, // Equal houses
  whole, // Whole sign houses
  porphyry, // Porphyry houses
  regiomontanus, // Regiomontanus houses
  campanus, // Campanus houses
  alcabitius, // Alcabitius houses
  topocentric, // Topocentric houses
  krusinski, // Krusinski houses
  axial, // Axial rotation houses
  horizontal, // Horizontal houses
  polich, // Polich/Page houses
  morinus, // Morinus houses
}

/// Planets
enum Planet {
  sun,
  moon,
  mars,
  mercury,
  jupiter,
  venus,
  saturn,
  rahu,
  ketu,
  uranus,
  neptune,
  pluto,
}

/// Houses
enum House {
  first, // Ascendant
  second, // Wealth
  third, // Siblings
  fourth, // Mother
  fifth, // Children
  sixth, // Health
  seventh, // Marriage
  eighth, // Longevity
  ninth, // Father
  tenth, // Career
  eleventh, // Gains
  twelfth, // Losses
}

/// Elements
enum Element {
  fire, // Agni
  earth, // Prithvi
  air, // Vayu
  water, // Jal
}

/// Qualities
enum Quality {
  cardinal, // Chara
  fixed, // Sthira
  mutable, // Dvisvabhava
}

/// Regional calendar types
///
enum RegionalCalendar {
  // North Indian Calendars
  northIndian, // North Indian (Vikram Samvat)
  punjabi, // Punjabi calendar
  himachali, // Himachal Pradesh calendar
  uttarakhandi, // Uttarakhand calendar
  rajasthani, // Rajasthan calendar
  haryanvi, // Haryana calendar

  // South Indian Calendars
  southIndian, // South Indian (Saka calendar)
  tamil, // Tamil calendar
  malayalam, // Malayalam calendar
  kannada, // Kannada calendar
  telugu, // Telugu calendar

  // East Indian Calendars
  bengali, // Bengali calendar
  odia, // Odia calendar
  assamese, // Assamese calendar
  manipuri, // Manipuri calendar

  // West Indian Calendars
  gujarati, // Gujarati calendar
  marathi, // Marathi calendar
  konkani, // Konkani calendar

  // Central Indian Calendars
  chhattisgarhi, // Chhattisgarh calendar
  madhyaPradeshi, // Madhya Pradesh calendar

  // Special Regional Calendars
  kashmiri, // Kashmir calendar
  nepali, // Nepali calendar
  sikkimese, // Sikkim calendar
  goan, // Goa calendar

  // Default
  universal, // Universal calendar (default)
}

/// Regional calendar characteristics
enum CalendarCharacteristics {
  lunarBased, // Primarily lunar calendar
  solarBased, // Primarily solar calendar
  lunisolar, // Lunisolar calendar
  regionalVariation, // Has regional variations
  seasonalBased, // Based on seasons
}

/// Transit types
enum TransitType {
  conjunction, // 0° aspect
  opposition, // 180° aspect
  trine, // 120° aspect
  square, // 90° aspect
  sextile, // 60° aspect
  houseTransit, // House transit
}

/// Genders
enum Gender {
  male, // Purusha
  female, // Stree
  neutral, // Napumsaka
}

/// Gunas
enum Guna {
  sattva, // Pure, spiritual
  rajas, // Active, passionate
  tamas, // Inert, material
}

/// Yonis (Animal symbols)
enum Yoni {
  horse, // Ashwa
  elephant, // Gaja
  sheep, // Mesha
  serpent, // Sarpa
  dog, // Shvana
  cat, // Marjara
  rat, // Mushaka
  cow, // Go
  buffalo, // Mahisha
  tiger, // Vyaghra
  deer, // Mriga
  monkey, // Vanara
  lion, // Simha
  mongoose, // Nakula
}

/// Nadis
enum Nadi {
  adya, // First
  madhya, // Middle
  antya, // Last
}

/// Ashta Koota parameters
enum AshtaKoota {
  varna, // Caste compatibility
  vashya, // Mutual attraction
  tara, // Star compatibility
  yoni, // Sexual compatibility
  grahaMaitri, // Planetary friendship
  gana, // Temperament compatibility
  bhakoot, // Love and affection
  nadi, // Health and progeny
}

/// Compatibility levels based on classical Vedic texts
enum CompatibilityLevel {
  excellent, // 28-36 points
  veryGood, // 24-27 points
  good, // 18-23 points (minimum threshold for favorable match)
  average, // 12-17 points
  poor, // 6-11 points
  veryPoor, // 0-5 points
}

/// Festival types
enum FestivalType {
  religious, // Religious festivals
  seasonal, // Seasonal festivals
  national, // National holidays
  regional, // Regional festivals
  personal, // Personal observances
  auspicious, // Auspicious days
  inauspicious, // Inauspicious days
}

/// Muhurta types
enum MuhurtaType {
  marriage, // Marriage ceremony
  business, // Business start
  travel, // Travel
  education, // Education start
  health, // Health treatments
  spiritual, // Spiritual practices
  general, // General auspicious
}

/// Calculation methods
enum CalculationMethod {
  swissEphemeris, // Swiss Ephemeris
  vedic, // Traditional Vedic
  modern, // Modern calculations
  hybrid, // Combined approach
}

/// Cache types
enum CacheType {
  memory, // In-memory cache
  persistent, // Persistent storage
  network, // Network cache
}

/// Error types
enum AstrologyErrorType {
  calculation, // Calculation error
  validation, // Input validation error
  network, // Network error
  cache, // Cache error
  configuration, // Configuration error
  unknown, // Unknown error
}
