import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_repository.dart';
import 'in_memory_repository.dart';

final repositoryProvider = Provider<AppRepository>((ref) {
  return InMemoryRepository();
});
