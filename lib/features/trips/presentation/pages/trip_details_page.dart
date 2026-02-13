import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/trip.dart';
import '../../../../core/models/expense.dart';
import '../../../expenses/presentation/models/trip_summary.dart';
import '../../../expenses/presentation/pages/expense_list_page.dart';
import '../../../expenses/presentation/providers/trip_summary_provider.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
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
                      _SummaryTabContent(tripId: trip.id),
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

class _SummaryTabContent extends ConsumerWidget {
  final String tripId;

  const _SummaryTabContent({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(tripSummaryProvider(tripId));
    final expensesAsync = ref.watch(watchExpensesByTripProvider(tripId));

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('خطأ: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(tripSummaryProvider(tripId));
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
      data: (summary) {
        if (summary.totalByCurrency.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('لا توجد مصاريف بعد'),
                const SizedBox(height: 8),
                Text(
                  'أضف أول مصروف من تبويب المصاريف',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        final expenses = expensesAsync.asData?.value ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TotalByCurrencyCard(summary: summary),
              const SizedBox(height: 16),
              if (summary.totalByCategory.isNotEmpty) ...
                [
                  _ByCategoryCard(summary: summary),
                  const SizedBox(height: 16),
                ],
              if (summary.totalByDay.isNotEmpty) ...
                [
                  _ByDayCard(summary: summary, expenses: expenses),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _TotalByCurrencyCard extends StatelessWidget {
  final TripSummary summary;

  const _TotalByCurrencyCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencies = summary.totalByCurrency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإجمالي',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...currencies.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(_formatMoney(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByCategoryCard extends StatelessWidget {
  final TripSummary summary;

  const _ByCategoryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final categories = summary.totalByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حسب الفئة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...categories.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.value),
                    Text(_formatMoney(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByDayCard extends StatelessWidget {
  final TripSummary summary;
  final List<Expense> expenses;

  const _ByDayCard({
    required this.summary,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final days = summary.totalByDay.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final displayDays = days.take(7).toList();

    // Group expenses by (date + currency) for breakdown
    final Map<String, Map<String, double>> dayByAmount = {};
    for (final expense in expenses) {
      final dayKey = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      final dayStr = _formatDate(dayKey);
      dayByAmount.putIfAbsent(dayStr, () => {});
      dayByAmount[dayStr]![expense.currency] =
          (dayByAmount[dayStr]![expense.currency] ?? 0) + expense.amount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حسب الأيام',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '(آخر 7 أيام)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ...displayDays.map(
              (entry) {
                final dayStr = _formatDate(entry.key);
                final currenciesForDay =
                    dayByAmount[dayStr]?.entries.toList() ?? [];
                currenciesForDay.sort((a, b) => b.value.compareTo(a.value));

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayStr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currenciesForDay
                            .map((e) => '${e.key} ${_formatMoney(e.value)}')
                            .join(' • '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
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

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatMoney(double amount) {
  return amount.toStringAsFixed(2);
}
