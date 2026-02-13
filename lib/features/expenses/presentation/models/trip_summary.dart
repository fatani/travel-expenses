import '../providers/expense_filters_provider.dart';

class TripSummary {
  final Map<String, double> totalByCurrency;
  final Map<ExpenseCategory, double> totalByCategory;
  final Map<DateTime, double> totalByDay;

  const TripSummary({
    required this.totalByCurrency,
    required this.totalByCategory,
    required this.totalByDay,
  });

  /// Total amount across all currencies
  double get grandTotal => totalByCurrency.values.fold(0, (a, b) => a + b);
}
