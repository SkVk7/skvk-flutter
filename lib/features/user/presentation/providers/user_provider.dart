/// User Provider
///
/// Provider for user service
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/user/user_service.dart';
import '../../../../core/models/user/user_model.dart';

/// User service provider
final userServiceProvider = NotifierProvider<UserService, UserModel?>(() {
  return UserService();
});
