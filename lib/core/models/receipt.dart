import 'dart:typed_data';

class Receipt {
  final String id;
  final String expenseId;
  final String? localPath; // Nullable for Web
  final Uint8List? data; // Store image bytes for Web
  final DateTime createdAt;

  Receipt({
    required this.id,
    required this.expenseId,
    this.localPath,
    this.data,
    required this.createdAt,
  });

  Receipt copyWith({
    String? id,
    String? expenseId,
    String? localPath,
    Uint8List? data,
    DateTime? createdAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      localPath: localPath ?? this.localPath,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'expenseId': expenseId,
    'localPath': localPath,
    'data': data,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'],
    expenseId: json['expenseId'],
    localPath: json['localPath'],
    data: json['data'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}
