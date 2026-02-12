class Trip {
  final String id;
  final String name;
  final String defaultCurrency;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.name,
    required this.defaultCurrency,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  Trip copyWith({
    String? id,
    String? name,
    String? defaultCurrency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'defaultCurrency': defaultCurrency,
    'startDate': startDate?.millisecondsSinceEpoch,
    'endDate': endDate?.millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'],
    name: json['name'],
    defaultCurrency: json['defaultCurrency'],
    startDate: json['startDate'] != null 
      ? DateTime.fromMillisecondsSinceEpoch(json['startDate']) 
      : null,
    endDate: json['endDate'] != null 
      ? DateTime.fromMillisecondsSinceEpoch(json['endDate']) 
      : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}
