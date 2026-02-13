import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/trip.dart';
import '../../../expenses/presentation/pages/expense_list_page.dart';
import '../providers/trips_providers.dart';

class TripDetailsPage extends ConsumerWidget {
  final String tripId;

  const TripDetailsPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripByIdProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/trips');
            }
          },
        ),
        title: tripAsync.when(
          data: (trip) => Text(trip?.name ?? 'تفاصيل الرحلة'),
          loading: () => const Text('تفاصيل الرحلة'),
          error: (error, stackTrace) => const Text('تفاصيل الرحلة'),
        ),
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('خطأ: $error')),
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('لم يتم العثور على الرحلة'));
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                _HeaderCard(trip: trip),
                const TabBar(
                  tabs: [
                    Tab(text: 'المصاريف'),
                    Tab(text: 'الملخص'),
                    Tab(text: 'التصدير'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ExpensesTabContent(
                        tripId: trip.id,
                        tripCurrency: trip.defaultCurrency,
                      ),
                      const _Placeholder(text: 'قريبًا: ملخص الرحلة'),
                      const _Placeholder(text: 'قريبًا: تصدير CSV'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Trip trip;

  const _HeaderCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateRange = _formatDateRange(trip.startDate, trip.endDate);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('العملة: ${trip.defaultCurrency}'),
            if (dateRange != null) ...[
              const SizedBox(height: 4),
              Text('التواريخ: $dateRange'),
            ],
          ],
        ),
      ),
    );
  }

  String? _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return null;
    }
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
    if (start != null) {
      return _formatDate(start);
    }
    return _formatDate(end!);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ExpensesTabContent extends StatelessWidget {
  final String tripId;
  final String tripCurrency;

  const _ExpensesTabContent({
    required this.tripId,
    required this.tripCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return ExpenseListPage(
      tripId: tripId,
      tripCurrency: tripCurrency,
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String text;

  const _Placeholder({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text),
    );
  }
}
