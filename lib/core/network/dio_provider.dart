import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../network/api_client.dart';

/// A Riverpod provider that gives any widget or ViewModel access to
/// the single shared Dio client.
///
/// Usage in a provider:
///   final dio = ref.watch(dioProvider);
final dioProvider = Provider<Dio>((ref) => createApiClient());
