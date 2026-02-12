import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_repository.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/models/trip.dart';

/// Stream provider to watch all trips
/// 
/// STABLE (no autoDispose): Keeps the stream alive throughout app lifetime
/// This prevents database reconnections when navigating between screens
/// 
/// Data persists on:
/// - Web: IndexedDB (automatic by Drift)
/// - Native: SQLite database file
final tripsStreamProvider = StreamProvider<List<Trip>>((ref) {
  final repository = ref.watch(repositoryProvider);
  return repository.watchAllTrips();
});

/// Notifier for adding new trips
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

/// Provider for AddTripNotifier
/// 
/// STABLE (no autoDispose): Keeps the notifier alive for consistent form state
final addTripProvider = StateNotifierProvider<AddTripNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(repositoryProvider);
  return AddTripNotifier(repository);
});

/// Provider for deleting trips
/// 
/// Note: Using family with autoDispose is okay here since it's for individual operations
final deleteTripProvider = FutureProvider.family<void, String>((ref, tripId) async {
  final repository = ref.watch(repositoryProvider);
  await repository.deleteTrip(tripId);
});

