import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_repository.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/models/trip.dart';

// Stream provider لعرض جميع الرحلات
final tripsStreamProvider = StreamProvider.autoDispose<List<Trip>>((ref) {
  final repository = ref.watch(repositoryProvider);
  return repository.watchAllTrips();
});

// Notifier لإضافة رحلة جديدة
class AddTripNotifier extends StateNotifier<AsyncValue<void>> {
  final AppRepository repository;

  AddTripNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> addTrip({
    required String name,
    required String defaultCurrency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final trip = Trip(
        id: const Uuid().v4(),
        name: name,
        defaultCurrency: defaultCurrency,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
      );
      await repository.insertTrip(trip);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// State notifier provider
final addTripProvider = StateNotifierProvider.autoDispose<AddTripNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(repositoryProvider);
  return AddTripNotifier(repository);
});

// Provider لحذف رحلة
final deleteTripProvider = FutureProvider.autoDispose.family<void, String>((ref, tripId) async {
  final repository = ref.watch(repositoryProvider);
  await repository.deleteTrip(tripId);
});
