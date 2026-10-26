import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // ProviderScope is the Riverpod equivalent of a dependency injection root.
  // Everything inside it can access Riverpod providers.
  runApp(const ProviderScope(child: App()));
}
