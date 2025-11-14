/// User Provider
///
/// Provider for user service
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/services/user/user_service.dart';

/// User service provider
final userServiceProvider = NotifierProvider<UserService, UserModel?>(() {
  return UserService();
});
