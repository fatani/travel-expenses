import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../providers/trips_providers.dart';

class TripListPage extends ConsumerWidget {
  const TripListPage({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String tripId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الرحلة؟'),
          content: const Text('سيتم حذف الرحلة وكل المصاريف والإيصالات المرتبطة بها.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(deleteTripProvider(tripId).future);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرحلات'),
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorState(
          title: 'حدث خطأ أثناء تحميل البيانات.',
          actionLabel: 'إعادة المحاولة',
          onAction: () => ref.invalidate(tripsStreamProvider),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return EmptyState(
              icon: Icons.card_travel,
              title: 'لا توجد رحلات بعد',
              subtitle: 'ابدأ بإضافة رحلة جديدة لتتبع المصاريف.',
              actionLabel: 'إضافة رحلة',
              onAction: () => context.push('/trips/new'),
            );
          }

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return ListTile(
                title: Text(trip.name),
                subtitle: Text(trip.defaultCurrency),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trip.startDate != null
                          ? '${trip.startDate?.day}/${trip.startDate?.month}'
                          : '',
                    ),
                    IconButton(
                      tooltip: 'تعديل',
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.push('/trips/${trip.id}/edit'),
                    ),
                    IconButton(
                      tooltip: 'حذف',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, trip.id),
                    ),
                  ],
                ),
                onTap: () => context.go('/trips/${trip.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/trips/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

