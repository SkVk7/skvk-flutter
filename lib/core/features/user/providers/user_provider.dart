/// User Provider
///
/// Provider for user service
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user/user_service.dart';
import '../../../models/user/user_model.dart';

/// User service provider
final userServiceProvider = NotifierProvider<UserService, UserModel?>(() {
  return UserService();
});
