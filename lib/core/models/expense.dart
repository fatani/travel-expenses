class Expense {
  final String id;
  final String tripId;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String? note;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    this.note,
    required this.createdAt,
  });

  Expense copyWith({
    String? id,
    String? tripId,
    double? amount,
    String? currency,
    DateTime? date,
    String? category,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'amount': amount,
    'currency': currency,
    'date': date.millisecondsSinceEpoch,
    'category': category,
    'note': note,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    tripId: json['tripId'],
    amount: json['amount'],
    currency: json['currency'],
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    category: json['category'],
    note: json['note'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}
