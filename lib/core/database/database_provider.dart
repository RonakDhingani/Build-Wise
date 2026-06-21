import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'isar_service.dart';

final isarProvider = Provider<Isar>((ref) {
  return IsarService.instance;
});
