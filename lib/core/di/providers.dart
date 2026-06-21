import 'package:flutter_riverpod/flutter_riverpod.dart';

// Active project state — all feature providers consume this
final activeProjectIdProvider = StateProvider<int?>((ref) => null);
