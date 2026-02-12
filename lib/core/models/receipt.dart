class Receipt {
  final String id;
  final String expenseId;
  final String localPath;
  final DateTime createdAt;

  Receipt({
    required this.id,
    required this.expenseId,
    required this.localPath,
    required this.createdAt,
  });

  Receipt copyWith({
    String? id,
    String? expenseId,
    String? localPath,
    DateTime? createdAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'expenseId': expenseId,
    'localPath': localPath,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'],
    expenseId: json['expenseId'],
    localPath: json['localPath'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}
