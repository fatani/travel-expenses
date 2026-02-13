class Expense {
  final String id;
  final String tripId;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String? note;
  final String merchant;
  final String paymentMethod;
  final String? locationText;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    this.note,
    required this.merchant,
    required this.paymentMethod,
    this.locationText,
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
    String? merchant,
    String? paymentMethod,
    String? locationText,
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
      merchant: merchant ?? this.merchant,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      locationText: locationText ?? this.locationText,
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
    'merchant': merchant,
    'paymentMethod': paymentMethod,
    'locationText': locationText,
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
    merchant: json['merchant'],
    paymentMethod: json['paymentMethod'],
    locationText: json['locationText'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}
