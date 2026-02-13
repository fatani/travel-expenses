// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripsTableTable extends trip_table.TripsTable
    with TableInfo<$TripsTableTable, TripsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultCurrencyMeta = const VerificationMeta(
    'defaultCurrency',
  );
  @override
  late final GeneratedColumn<String> defaultCurrency = GeneratedColumn<String>(
    'default_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    defaultCurrency,
    startDate,
    endDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_currency')) {
      context.handle(
        _defaultCurrencyMeta,
        defaultCurrency.isAcceptableOrUnknown(
          data['default_currency']!,
          _defaultCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultCurrencyMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      defaultCurrency:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}default_currency'],
          )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $TripsTableTable createAlias(String alias) {
    return $TripsTableTable(attachedDatabase, alias);
  }
}

class TripsTableData extends DataClass implements Insertable<TripsTableData> {
  final String id;
  final String name;
  final String defaultCurrency;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  const TripsTableData({
    required this.id,
    required this.name,
    required this.defaultCurrency,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['default_currency'] = Variable<String>(defaultCurrency);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TripsTableCompanion toCompanion(bool nullToAbsent) {
    return TripsTableCompanion(
      id: Value(id),
      name: Value(name),
      defaultCurrency: Value(defaultCurrency),
      startDate:
          startDate == null && nullToAbsent
              ? const Value.absent()
              : Value(startDate),
      endDate:
          endDate == null && nullToAbsent
              ? const Value.absent()
              : Value(endDate),
      createdAt: Value(createdAt),
    );
  }

  factory TripsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultCurrency: serializer.fromJson<String>(json['defaultCurrency']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'defaultCurrency': serializer.toJson<String>(defaultCurrency),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TripsTableData copyWith({
    String? id,
    String? name,
    String? defaultCurrency,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    DateTime? createdAt,
  }) => TripsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    createdAt: createdAt ?? this.createdAt,
  );
  TripsTableData copyWithCompanion(TripsTableCompanion data) {
    return TripsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultCurrency:
          data.defaultCurrency.present
              ? data.defaultCurrency.value
              : this.defaultCurrency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, defaultCurrency, startDate, endDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultCurrency == this.defaultCurrency &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.createdAt == this.createdAt);
}

class TripsTableCompanion extends UpdateCompanion<TripsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> defaultCurrency;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TripsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsTableCompanion.insert({
    required String id,
    required String name,
    required String defaultCurrency,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       defaultCurrency = Value(defaultCurrency),
       createdAt = Value(createdAt);
  static Insertable<TripsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? defaultCurrency,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? defaultCurrency,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TripsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultCurrency.present) {
      map['default_currency'] = Variable<String>(defaultCurrency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTableTable extends expense_table.ExpensesTable
    with TableInfo<$ExpensesTableTable, ExpensesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationTextMeta = const VerificationMeta(
    'locationText',
  );
  @override
  late final GeneratedColumn<String> locationText = GeneratedColumn<String>(
    'location_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    amount,
    currency,
    date,
    category,
    note,
    merchant,
    paymentMethod,
    locationText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpensesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('location_text')) {
      context.handle(
        _locationTextMeta,
        locationText.isAcceptableOrUnknown(
          data['location_text']!,
          _locationTextMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpensesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpensesTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      tripId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}trip_id'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      currency:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}currency'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      locationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_text'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ExpensesTableTable createAlias(String alias) {
    return $ExpensesTableTable(attachedDatabase, alias);
  }
}

class ExpensesTableData extends DataClass
    implements Insertable<ExpensesTableData> {
  final String id;
  final String tripId;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String? note;
  final String? merchant;
  final String? paymentMethod;
  final String? locationText;
  final DateTime createdAt;
  const ExpensesTableData({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    this.note,
    this.merchant,
    this.paymentMethod,
    this.locationText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || locationText != null) {
      map['location_text'] = Variable<String>(locationText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return ExpensesTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      amount: Value(amount),
      currency: Value(currency),
      date: Value(date),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      merchant:
          merchant == null && nullToAbsent
              ? const Value.absent()
              : Value(merchant),
      paymentMethod:
          paymentMethod == null && nullToAbsent
              ? const Value.absent()
              : Value(paymentMethod),
      locationText:
          locationText == null && nullToAbsent
              ? const Value.absent()
              : Value(locationText),
      createdAt: Value(createdAt),
    );
  }

  factory ExpensesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpensesTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      locationText: serializer.fromJson<String?>(json['locationText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String?>(note),
      'merchant': serializer.toJson<String?>(merchant),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'locationText': serializer.toJson<String?>(locationText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExpensesTableData copyWith({
    String? id,
    String? tripId,
    double? amount,
    String? currency,
    DateTime? date,
    String? category,
    Value<String?> note = const Value.absent(),
    Value<String?> merchant = const Value.absent(),
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> locationText = const Value.absent(),
    DateTime? createdAt,
  }) => ExpensesTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    date: date ?? this.date,
    category: category ?? this.category,
    note: note.present ? note.value : this.note,
    merchant: merchant.present ? merchant.value : this.merchant,
    paymentMethod:
        paymentMethod.present ? paymentMethod.value : this.paymentMethod,
    locationText: locationText.present ? locationText.value : this.locationText,
    createdAt: createdAt ?? this.createdAt,
  );
  ExpensesTableData copyWithCompanion(ExpensesTableCompanion data) {
    return ExpensesTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      paymentMethod:
          data.paymentMethod.present
              ? data.paymentMethod.value
              : this.paymentMethod,
      locationText:
          data.locationText.present
              ? data.locationText.value
              : this.locationText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('merchant: $merchant, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('locationText: $locationText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    amount,
    currency,
    date,
    category,
    note,
    merchant,
    paymentMethod,
    locationText,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpensesTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.date == this.date &&
          other.category == this.category &&
          other.note == this.note &&
          other.merchant == this.merchant &&
          other.paymentMethod == this.paymentMethod &&
          other.locationText == this.locationText &&
          other.createdAt == this.createdAt);
}

class ExpensesTableCompanion extends UpdateCompanion<ExpensesTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<double> amount;
  final Value<String> currency;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<String?> note;
  final Value<String?> merchant;
  final Value<String?> paymentMethod;
  final Value<String?> locationText;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.merchant = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.locationText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesTableCompanion.insert({
    required String id,
    required String tripId,
    required double amount,
    required String currency,
    required DateTime date,
    required String category,
    this.note = const Value.absent(),
    this.merchant = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.locationText = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       amount = Value(amount),
       currency = Value(currency),
       date = Value(date),
       category = Value(category),
       createdAt = Value(createdAt);
  static Insertable<ExpensesTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<String>? note,
    Expression<String>? merchant,
    Expression<String>? paymentMethod,
    Expression<String>? locationText,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (merchant != null) 'merchant': merchant,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (locationText != null) 'location_text': locationText,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<double>? amount,
    Value<String>? currency,
    Value<DateTime>? date,
    Value<String>? category,
    Value<String?>? note,
    Value<String?>? merchant,
    Value<String?>? paymentMethod,
    Value<String?>? locationText,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpensesTableCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (locationText.present) {
      map['location_text'] = Variable<String>(locationText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('merchant: $merchant, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('locationText: $locationText, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTableTable extends receipt_table.ReceiptsTable
    with TableInfo<$ReceiptsTableTable, ReceiptsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    expenseId,
    localPath,
    data,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      expenseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}expense_id'],
          )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ReceiptsTableTable createAlias(String alias) {
    return $ReceiptsTableTable(attachedDatabase, alias);
  }
}

class ReceiptsTableData extends DataClass
    implements Insertable<ReceiptsTableData> {
  final String id;
  final String expenseId;
  final String? localPath;
  final Uint8List? data;
  final DateTime createdAt;
  const ReceiptsTableData({
    required this.id,
    required this.expenseId,
    this.localPath,
    this.data,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['expense_id'] = Variable<String>(expenseId);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<Uint8List>(data);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReceiptsTableCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsTableCompanion(
      id: Value(id),
      expenseId: Value(expenseId),
      localPath:
          localPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localPath),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      createdAt: Value(createdAt),
    );
  }

  factory ReceiptsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptsTableData(
      id: serializer.fromJson<String>(json['id']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      data: serializer.fromJson<Uint8List?>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'expenseId': serializer.toJson<String>(expenseId),
      'localPath': serializer.toJson<String?>(localPath),
      'data': serializer.toJson<Uint8List?>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReceiptsTableData copyWith({
    String? id,
    String? expenseId,
    Value<String?> localPath = const Value.absent(),
    Value<Uint8List?> data = const Value.absent(),
    DateTime? createdAt,
  }) => ReceiptsTableData(
    id: id ?? this.id,
    expenseId: expenseId ?? this.expenseId,
    localPath: localPath.present ? localPath.value : this.localPath,
    data: data.present ? data.value : this.data,
    createdAt: createdAt ?? this.createdAt,
  );
  ReceiptsTableData copyWithCompanion(ReceiptsTableCompanion data) {
    return ReceiptsTableData(
      id: data.id.present ? data.id.value : this.id,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsTableData(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('localPath: $localPath, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    expenseId,
    localPath,
    $driftBlobEquality.hash(data),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptsTableData &&
          other.id == this.id &&
          other.expenseId == this.expenseId &&
          other.localPath == this.localPath &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.createdAt == this.createdAt);
}

class ReceiptsTableCompanion extends UpdateCompanion<ReceiptsTableData> {
  final Value<String> id;
  final Value<String> expenseId;
  final Value<String?> localPath;
  final Value<Uint8List?> data;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReceiptsTableCompanion({
    this.id = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptsTableCompanion.insert({
    required String id,
    required String expenseId,
    this.localPath = const Value.absent(),
    this.data = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expenseId = Value(expenseId),
       createdAt = Value(createdAt);
  static Insertable<ReceiptsTableData> custom({
    Expression<String>? id,
    Expression<String>? expenseId,
    Expression<String>? localPath,
    Expression<Uint8List>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      if (localPath != null) 'local_path': localPath,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? expenseId,
    Value<String?>? localPath,
    Value<Uint8List?>? data,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReceiptsTableCompanion(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      localPath: localPath ?? this.localPath,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsTableCompanion(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('localPath: $localPath, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTableTable tripsTable = $TripsTableTable(this);
  late final $ExpensesTableTable expensesTable = $ExpensesTableTable(this);
  late final $ReceiptsTableTable receiptsTable = $ReceiptsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tripsTable,
    expensesTable,
    receiptsTable,
  ];
}

typedef $$TripsTableTableCreateCompanionBuilder =
    TripsTableCompanion Function({
      required String id,
      required String name,
      required String defaultCurrency,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TripsTableTableUpdateCompanionBuilder =
    TripsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> defaultCurrency,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TripsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TripsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTableTable,
          TripsTableData,
          $$TripsTableTableFilterComposer,
          $$TripsTableTableOrderingComposer,
          $$TripsTableTableAnnotationComposer,
          $$TripsTableTableCreateCompanionBuilder,
          $$TripsTableTableUpdateCompanionBuilder,
          (
            TripsTableData,
            BaseReferences<_$AppDatabase, $TripsTableTable, TripsTableData>,
          ),
          TripsTableData,
          PrefetchHooks Function()
        > {
  $$TripsTableTableTableManager(_$AppDatabase db, $TripsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TripsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TripsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TripsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> defaultCurrency = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsTableCompanion(
                id: id,
                name: name,
                defaultCurrency: defaultCurrency,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String defaultCurrency,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TripsTableCompanion.insert(
                id: id,
                name: name,
                defaultCurrency: defaultCurrency,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTableTable,
      TripsTableData,
      $$TripsTableTableFilterComposer,
      $$TripsTableTableOrderingComposer,
      $$TripsTableTableAnnotationComposer,
      $$TripsTableTableCreateCompanionBuilder,
      $$TripsTableTableUpdateCompanionBuilder,
      (
        TripsTableData,
        BaseReferences<_$AppDatabase, $TripsTableTable, TripsTableData>,
      ),
      TripsTableData,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableTableCreateCompanionBuilder =
    ExpensesTableCompanion Function({
      required String id,
      required String tripId,
      required double amount,
      required String currency,
      required DateTime date,
      required String category,
      Value<String?> note,
      Value<String?> merchant,
      Value<String?> paymentMethod,
      Value<String?> locationText,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableTableUpdateCompanionBuilder =
    ExpensesTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<double> amount,
      Value<String> currency,
      Value<DateTime> date,
      Value<String> category,
      Value<String?> note,
      Value<String?> merchant,
      Value<String?> paymentMethod,
      Value<String?> locationText,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExpensesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTableTable,
          ExpensesTableData,
          $$ExpensesTableTableFilterComposer,
          $$ExpensesTableTableOrderingComposer,
          $$ExpensesTableTableAnnotationComposer,
          $$ExpensesTableTableCreateCompanionBuilder,
          $$ExpensesTableTableUpdateCompanionBuilder,
          (
            ExpensesTableData,
            BaseReferences<
              _$AppDatabase,
              $ExpensesTableTable,
              ExpensesTableData
            >,
          ),
          ExpensesTableData,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableTableManager(_$AppDatabase db, $ExpensesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ExpensesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ExpensesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> locationText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion(
                id: id,
                tripId: tripId,
                amount: amount,
                currency: currency,
                date: date,
                category: category,
                note: note,
                merchant: merchant,
                paymentMethod: paymentMethod,
                locationText: locationText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required double amount,
                required String currency,
                required DateTime date,
                required String category,
                Value<String?> note = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> locationText = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion.insert(
                id: id,
                tripId: tripId,
                amount: amount,
                currency: currency,
                date: date,
                category: category,
                note: note,
                merchant: merchant,
                paymentMethod: paymentMethod,
                locationText: locationText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTableTable,
      ExpensesTableData,
      $$ExpensesTableTableFilterComposer,
      $$ExpensesTableTableOrderingComposer,
      $$ExpensesTableTableAnnotationComposer,
      $$ExpensesTableTableCreateCompanionBuilder,
      $$ExpensesTableTableUpdateCompanionBuilder,
      (
        ExpensesTableData,
        BaseReferences<_$AppDatabase, $ExpensesTableTable, ExpensesTableData>,
      ),
      ExpensesTableData,
      PrefetchHooks Function()
    >;
typedef $$ReceiptsTableTableCreateCompanionBuilder =
    ReceiptsTableCompanion Function({
      required String id,
      required String expenseId,
      Value<String?> localPath,
      Value<Uint8List?> data,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReceiptsTableTableUpdateCompanionBuilder =
    ReceiptsTableCompanion Function({
      Value<String> id,
      Value<String> expenseId,
      Value<String?> localPath,
      Value<Uint8List?> data,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ReceiptsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTableTable> {
  $$ReceiptsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReceiptsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTableTable> {
  $$ReceiptsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTableTable> {
  $$ReceiptsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get expenseId =>
      $composableBuilder(column: $table.expenseId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReceiptsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTableTable,
          ReceiptsTableData,
          $$ReceiptsTableTableFilterComposer,
          $$ReceiptsTableTableOrderingComposer,
          $$ReceiptsTableTableAnnotationComposer,
          $$ReceiptsTableTableCreateCompanionBuilder,
          $$ReceiptsTableTableUpdateCompanionBuilder,
          (
            ReceiptsTableData,
            BaseReferences<
              _$AppDatabase,
              $ReceiptsTableTable,
              ReceiptsTableData
            >,
          ),
          ReceiptsTableData,
          PrefetchHooks Function()
        > {
  $$ReceiptsTableTableTableManager(_$AppDatabase db, $ReceiptsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ReceiptsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ReceiptsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ReceiptsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> expenseId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<Uint8List?> data = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsTableCompanion(
                id: id,
                expenseId: expenseId,
                localPath: localPath,
                data: data,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String expenseId,
                Value<String?> localPath = const Value.absent(),
                Value<Uint8List?> data = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsTableCompanion.insert(
                id: id,
                expenseId: expenseId,
                localPath: localPath,
                data: data,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReceiptsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTableTable,
      ReceiptsTableData,
      $$ReceiptsTableTableFilterComposer,
      $$ReceiptsTableTableOrderingComposer,
      $$ReceiptsTableTableAnnotationComposer,
      $$ReceiptsTableTableCreateCompanionBuilder,
      $$ReceiptsTableTableUpdateCompanionBuilder,
      (
        ReceiptsTableData,
        BaseReferences<_$AppDatabase, $ReceiptsTableTable, ReceiptsTableData>,
      ),
      ReceiptsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db, _db.tripsTable);
  $$ExpensesTableTableTableManager get expensesTable =>
      $$ExpensesTableTableTableManager(_db, _db.expensesTable);
  $$ReceiptsTableTableTableManager get receiptsTable =>
      $$ReceiptsTableTableTableManager(_db, _db.receiptsTable);
}
