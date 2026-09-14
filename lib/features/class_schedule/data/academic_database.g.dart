// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_database.dart';

// ignore_for_file: type=lint
class $SemestersTable extends Semesters
    with TableInfo<$SemestersTable, Semester> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemestersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _academicYearMeta = const VerificationMeta(
    'academicYear',
  );
  @override
  late final GeneratedColumn<String> academicYear = GeneratedColumn<String>(
    'academic_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SemesterStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SemesterStatus>($SemestersTable.$converterstatus);
  static const VerificationMeta _nthuTermCodeMeta = const VerificationMeta(
    'nthuTermCode',
  );
  @override
  late final GeneratedColumn<String> nthuTermCode = GeneratedColumn<String>(
    'nthu_term_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    academicYear,
    term,
    startDate,
    endDate,
    status,
    nthuTermCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semesters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Semester> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('academic_year')) {
      context.handle(
        _academicYearMeta,
        academicYear.isAcceptableOrUnknown(
          data['academic_year']!,
          _academicYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('nthu_term_code')) {
      context.handle(
        _nthuTermCodeMeta,
        nthuTermCode.isAcceptableOrUnknown(
          data['nthu_term_code']!,
          _nthuTermCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Semester map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Semester(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      academicYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      status: $SemestersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      nthuTermCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nthu_term_code'],
      ),
    );
  }

  @override
  $SemestersTable createAlias(String alias) {
    return $SemestersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SemesterStatus, String, String> $converterstatus =
      const EnumNameConverter<SemesterStatus>(SemesterStatus.values);
}

class Semester extends DataClass implements Insertable<Semester> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String academicYear;
  final String term;
  final DateTime startDate;
  final DateTime endDate;
  final SemesterStatus status;
  final String? nthuTermCode;
  const Semester({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.academicYear,
    required this.term,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.nthuTermCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['academic_year'] = Variable<String>(academicYear);
    map['term'] = Variable<String>(term);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    {
      map['status'] = Variable<String>(
        $SemestersTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || nthuTermCode != null) {
      map['nthu_term_code'] = Variable<String>(nthuTermCode);
    }
    return map;
  }

  SemestersCompanion toCompanion(bool nullToAbsent) {
    return SemestersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      academicYear: Value(academicYear),
      term: Value(term),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
      nthuTermCode: nthuTermCode == null && nullToAbsent
          ? const Value.absent()
          : Value(nthuTermCode),
    );
  }

  factory Semester.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Semester(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      academicYear: serializer.fromJson<String>(json['academicYear']),
      term: serializer.fromJson<String>(json['term']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: $SemestersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      nthuTermCode: serializer.fromJson<String?>(json['nthuTermCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'academicYear': serializer.toJson<String>(academicYear),
      'term': serializer.toJson<String>(term),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(
        $SemestersTable.$converterstatus.toJson(status),
      ),
      'nthuTermCode': serializer.toJson<String?>(nthuTermCode),
    };
  }

  Semester copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    String? academicYear,
    String? term,
    DateTime? startDate,
    DateTime? endDate,
    SemesterStatus? status,
    Value<String?> nthuTermCode = const Value.absent(),
  }) => Semester(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    academicYear: academicYear ?? this.academicYear,
    term: term ?? this.term,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    status: status ?? this.status,
    nthuTermCode: nthuTermCode.present ? nthuTermCode.value : this.nthuTermCode,
  );
  Semester copyWithCompanion(SemestersCompanion data) {
    return Semester(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      academicYear: data.academicYear.present
          ? data.academicYear.value
          : this.academicYear,
      term: data.term.present ? data.term.value : this.term,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      nthuTermCode: data.nthuTermCode.present
          ? data.nthuTermCode.value
          : this.nthuTermCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Semester(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('academicYear: $academicYear, ')
          ..write('term: $term, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('nthuTermCode: $nthuTermCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    academicYear,
    term,
    startDate,
    endDate,
    status,
    nthuTermCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Semester &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.academicYear == this.academicYear &&
          other.term == this.term &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.nthuTermCode == this.nthuTermCode);
}

class SemestersCompanion extends UpdateCompanion<Semester> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> academicYear;
  final Value<String> term;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<SemesterStatus> status;
  final Value<String?> nthuTermCode;
  final Value<int> rowid;
  const SemestersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.term = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.nthuTermCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SemestersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    required String academicYear,
    required String term,
    required DateTime startDate,
    required DateTime endDate,
    required SemesterStatus status,
    this.nthuTermCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       academicYear = Value(academicYear),
       term = Value(term),
       startDate = Value(startDate),
       endDate = Value(endDate),
       status = Value(status);
  static Insertable<Semester> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? academicYear,
    Expression<String>? term,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<String>? nthuTermCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (academicYear != null) 'academic_year': academicYear,
      if (term != null) 'term': term,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (nthuTermCode != null) 'nthu_term_code': nthuTermCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SemestersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String>? academicYear,
    Value<String>? term,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<SemesterStatus>? status,
    Value<String?>? nthuTermCode,
    Value<int>? rowid,
  }) {
    return SemestersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      term: term ?? this.term,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      nthuTermCode: nthuTermCode ?? this.nthuTermCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (academicYear.present) {
      map['academic_year'] = Variable<String>(academicYear.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SemestersTable.$converterstatus.toSql(status.value),
      );
    }
    if (nthuTermCode.present) {
      map['nthu_term_code'] = Variable<String>(nthuTermCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SemestersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('academicYear: $academicYear, ')
          ..write('term: $term, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('nthuTermCode: $nthuTermCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GraduationCategoriesTable extends GraduationCategories
    with TableInfo<$GraduationCategoriesTable, GraduationCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraduationCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _requiredCreditsMeta = const VerificationMeta(
    'requiredCredits',
  );
  @override
  late final GeneratedColumn<double> requiredCredits = GeneratedColumn<double>(
    'required_credits',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    requiredCredits,
    description,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'graduation_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<GraduationCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('required_credits')) {
      context.handle(
        _requiredCreditsMeta,
        requiredCredits.isAcceptableOrUnknown(
          data['required_credits']!,
          _requiredCreditsMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GraduationCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GraduationCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      requiredCredits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}required_credits'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $GraduationCategoriesTable createAlias(String alias) {
    return $GraduationCategoriesTable(attachedDatabase, alias);
  }
}

class GraduationCategory extends DataClass
    implements Insertable<GraduationCategory> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final double? requiredCredits;
  final String? description;
  final int sortOrder;
  final bool isActive;
  const GraduationCategory({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.requiredCredits,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || requiredCredits != null) {
      map['required_credits'] = Variable<double>(requiredCredits);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  GraduationCategoriesCompanion toCompanion(bool nullToAbsent) {
    return GraduationCategoriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      requiredCredits: requiredCredits == null && nullToAbsent
          ? const Value.absent()
          : Value(requiredCredits),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory GraduationCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GraduationCategory(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      requiredCredits: serializer.fromJson<double?>(json['requiredCredits']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'requiredCredits': serializer.toJson<double?>(requiredCredits),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  GraduationCategory copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<double?> requiredCredits = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => GraduationCategory(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    requiredCredits: requiredCredits.present
        ? requiredCredits.value
        : this.requiredCredits,
    description: description.present ? description.value : this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  GraduationCategory copyWithCompanion(GraduationCategoriesCompanion data) {
    return GraduationCategory(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      requiredCredits: data.requiredCredits.present
          ? data.requiredCredits.value
          : this.requiredCredits,
      description: data.description.present
          ? data.description.value
          : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GraduationCategory(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('requiredCredits: $requiredCredits, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    requiredCredits,
    description,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraduationCategory &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.requiredCredits == this.requiredCredits &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class GraduationCategoriesCompanion
    extends UpdateCompanion<GraduationCategory> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<double?> requiredCredits;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const GraduationCategoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.requiredCredits = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GraduationCategoriesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    this.requiredCredits = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<GraduationCategory> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<double>? requiredCredits,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (requiredCredits != null) 'required_credits': requiredCredits,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GraduationCategoriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<double?>? requiredCredits,
    Value<String?>? description,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return GraduationCategoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      requiredCredits: requiredCredits ?? this.requiredCredits,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (requiredCredits.present) {
      map['required_credits'] = Variable<double>(requiredCredits.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraduationCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('requiredCredits: $requiredCredits, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NthuCatalogTermsTable extends NthuCatalogTerms
    with TableInfo<$NthuCatalogTermsTable, NthuCatalogTerm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NthuCatalogTermsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _termCodeMeta = const VerificationMeta(
    'termCode',
  );
  @override
  late final GeneratedColumn<String> termCode = GeneratedColumn<String>(
    'term_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUpdatedAtMeta = const VerificationMeta(
    'sourceUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sourceUpdatedAt =
      GeneratedColumn<DateTime>(
        'source_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    termCode,
    displayName,
    fetchedAt,
    sourceType,
    sourceUrl,
    sourceUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nthu_catalog_terms';
  @override
  VerificationContext validateIntegrity(
    Insertable<NthuCatalogTerm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('term_code')) {
      context.handle(
        _termCodeMeta,
        termCode.isAcceptableOrUnknown(data['term_code']!, _termCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_termCodeMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('source_updated_at')) {
      context.handle(
        _sourceUpdatedAtMeta,
        sourceUpdatedAt.isAcceptableOrUnknown(
          data['source_updated_at']!,
          _sourceUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NthuCatalogTerm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NthuCatalogTerm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      termCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_code'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      sourceUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}source_updated_at'],
      ),
    );
  }

  @override
  $NthuCatalogTermsTable createAlias(String alias) {
    return $NthuCatalogTermsTable(attachedDatabase, alias);
  }
}

class NthuCatalogTerm extends DataClass implements Insertable<NthuCatalogTerm> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String termCode;
  final String displayName;
  final DateTime fetchedAt;
  final String sourceType;
  final String sourceUrl;
  final DateTime? sourceUpdatedAt;
  const NthuCatalogTerm({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.termCode,
    required this.displayName,
    required this.fetchedAt,
    required this.sourceType,
    required this.sourceUrl,
    this.sourceUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['term_code'] = Variable<String>(termCode);
    map['display_name'] = Variable<String>(displayName);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['source_type'] = Variable<String>(sourceType);
    map['source_url'] = Variable<String>(sourceUrl);
    if (!nullToAbsent || sourceUpdatedAt != null) {
      map['source_updated_at'] = Variable<DateTime>(sourceUpdatedAt);
    }
    return map;
  }

  NthuCatalogTermsCompanion toCompanion(bool nullToAbsent) {
    return NthuCatalogTermsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      termCode: Value(termCode),
      displayName: Value(displayName),
      fetchedAt: Value(fetchedAt),
      sourceType: Value(sourceType),
      sourceUrl: Value(sourceUrl),
      sourceUpdatedAt: sourceUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUpdatedAt),
    );
  }

  factory NthuCatalogTerm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NthuCatalogTerm(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      termCode: serializer.fromJson<String>(json['termCode']),
      displayName: serializer.fromJson<String>(json['displayName']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      sourceUpdatedAt: serializer.fromJson<DateTime?>(json['sourceUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'termCode': serializer.toJson<String>(termCode),
      'displayName': serializer.toJson<String>(displayName),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'sourceUpdatedAt': serializer.toJson<DateTime?>(sourceUpdatedAt),
    };
  }

  NthuCatalogTerm copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? termCode,
    String? displayName,
    DateTime? fetchedAt,
    String? sourceType,
    String? sourceUrl,
    Value<DateTime?> sourceUpdatedAt = const Value.absent(),
  }) => NthuCatalogTerm(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    termCode: termCode ?? this.termCode,
    displayName: displayName ?? this.displayName,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    sourceType: sourceType ?? this.sourceType,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    sourceUpdatedAt: sourceUpdatedAt.present
        ? sourceUpdatedAt.value
        : this.sourceUpdatedAt,
  );
  NthuCatalogTerm copyWithCompanion(NthuCatalogTermsCompanion data) {
    return NthuCatalogTerm(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      termCode: data.termCode.present ? data.termCode.value : this.termCode,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      sourceUpdatedAt: data.sourceUpdatedAt.present
          ? data.sourceUpdatedAt.value
          : this.sourceUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NthuCatalogTerm(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('termCode: $termCode, ')
          ..write('displayName: $displayName, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sourceUpdatedAt: $sourceUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    termCode,
    displayName,
    fetchedAt,
    sourceType,
    sourceUrl,
    sourceUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NthuCatalogTerm &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.termCode == this.termCode &&
          other.displayName == this.displayName &&
          other.fetchedAt == this.fetchedAt &&
          other.sourceType == this.sourceType &&
          other.sourceUrl == this.sourceUrl &&
          other.sourceUpdatedAt == this.sourceUpdatedAt);
}

class NthuCatalogTermsCompanion extends UpdateCompanion<NthuCatalogTerm> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> termCode;
  final Value<String> displayName;
  final Value<DateTime> fetchedAt;
  final Value<String> sourceType;
  final Value<String> sourceUrl;
  final Value<DateTime?> sourceUpdatedAt;
  final Value<int> rowid;
  const NthuCatalogTermsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.termCode = const Value.absent(),
    this.displayName = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.sourceUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NthuCatalogTermsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String termCode,
    required String displayName,
    required DateTime fetchedAt,
    required String sourceType,
    required String sourceUrl,
    this.sourceUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       termCode = Value(termCode),
       displayName = Value(displayName),
       fetchedAt = Value(fetchedAt),
       sourceType = Value(sourceType),
       sourceUrl = Value(sourceUrl);
  static Insertable<NthuCatalogTerm> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? termCode,
    Expression<String>? displayName,
    Expression<DateTime>? fetchedAt,
    Expression<String>? sourceType,
    Expression<String>? sourceUrl,
    Expression<DateTime>? sourceUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (termCode != null) 'term_code': termCode,
      if (displayName != null) 'display_name': displayName,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (sourceUpdatedAt != null) 'source_updated_at': sourceUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NthuCatalogTermsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? termCode,
    Value<String>? displayName,
    Value<DateTime>? fetchedAt,
    Value<String>? sourceType,
    Value<String>? sourceUrl,
    Value<DateTime?>? sourceUpdatedAt,
    Value<int>? rowid,
  }) {
    return NthuCatalogTermsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      termCode: termCode ?? this.termCode,
      displayName: displayName ?? this.displayName,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      sourceType: sourceType ?? this.sourceType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceUpdatedAt: sourceUpdatedAt ?? this.sourceUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (termCode.present) {
      map['term_code'] = Variable<String>(termCode.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (sourceUpdatedAt.present) {
      map['source_updated_at'] = Variable<DateTime>(sourceUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NthuCatalogTermsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('termCode: $termCode, ')
          ..write('displayName: $displayName, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sourceUpdatedAt: $sourceUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NthuCatalogCoursesTable extends NthuCatalogCourses
    with TableInfo<$NthuCatalogCoursesTable, NthuCatalogCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NthuCatalogCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _termCodeMeta = const VerificationMeta(
    'termCode',
  );
  @override
  late final GeneratedColumn<String> termCode = GeneratedColumn<String>(
    'term_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nthu_catalog_terms (term_code)',
    ),
  );
  static const VerificationMeta _officialCourseCodeMeta =
      const VerificationMeta('officialCourseCode');
  @override
  late final GeneratedColumn<String> officialCourseCode =
      GeneratedColumn<String>(
        'official_course_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _chineseNameMeta = const VerificationMeta(
    'chineseName',
  );
  @override
  late final GeneratedColumn<String> chineseName = GeneratedColumn<String>(
    'chinese_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
    'credits',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teachingLanguageMeta = const VerificationMeta(
    'teachingLanguage',
  );
  @override
  late final GeneratedColumn<String> teachingLanguage = GeneratedColumn<String>(
    'teaching_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructorNamesMeta = const VerificationMeta(
    'instructorNames',
  );
  @override
  late final GeneratedColumn<String> instructorNames = GeneratedColumn<String>(
    'instructor_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancellationFlagMeta = const VerificationMeta(
    'cancellationFlag',
  );
  @override
  late final GeneratedColumn<String> cancellationFlag = GeneratedColumn<String>(
    'cancellation_flag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restrictionsMeta = const VerificationMeta(
    'restrictions',
  );
  @override
  late final GeneratedColumn<String> restrictions = GeneratedColumn<String>(
    'restrictions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredElectiveMetadataMeta =
      const VerificationMeta('requiredElectiveMetadata');
  @override
  late final GeneratedColumn<String> requiredElectiveMetadata =
      GeneratedColumn<String>(
        'required_elective_metadata',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _departmentMeta = const VerificationMeta(
    'department',
  );
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
    'department',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawScheduleTextMeta = const VerificationMeta(
    'rawScheduleText',
  );
  @override
  late final GeneratedColumn<String> rawScheduleText = GeneratedColumn<String>(
    'raw_schedule_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawLocationTextMeta = const VerificationMeta(
    'rawLocationText',
  );
  @override
  late final GeneratedColumn<String> rawLocationText = GeneratedColumn<String>(
    'raw_location_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    termCode,
    officialCourseCode,
    chineseName,
    englishName,
    credits,
    teachingLanguage,
    instructorNames,
    notes,
    cancellationFlag,
    restrictions,
    requiredElectiveMetadata,
    department,
    subject,
    rawScheduleText,
    rawLocationText,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nthu_catalog_courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<NthuCatalogCourse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('term_code')) {
      context.handle(
        _termCodeMeta,
        termCode.isAcceptableOrUnknown(data['term_code']!, _termCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_termCodeMeta);
    }
    if (data.containsKey('official_course_code')) {
      context.handle(
        _officialCourseCodeMeta,
        officialCourseCode.isAcceptableOrUnknown(
          data['official_course_code']!,
          _officialCourseCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officialCourseCodeMeta);
    }
    if (data.containsKey('chinese_name')) {
      context.handle(
        _chineseNameMeta,
        chineseName.isAcceptableOrUnknown(
          data['chinese_name']!,
          _chineseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chineseNameMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishNameMeta);
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    } else if (isInserting) {
      context.missing(_creditsMeta);
    }
    if (data.containsKey('teaching_language')) {
      context.handle(
        _teachingLanguageMeta,
        teachingLanguage.isAcceptableOrUnknown(
          data['teaching_language']!,
          _teachingLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teachingLanguageMeta);
    }
    if (data.containsKey('instructor_names')) {
      context.handle(
        _instructorNamesMeta,
        instructorNames.isAcceptableOrUnknown(
          data['instructor_names']!,
          _instructorNamesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructorNamesMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('cancellation_flag')) {
      context.handle(
        _cancellationFlagMeta,
        cancellationFlag.isAcceptableOrUnknown(
          data['cancellation_flag']!,
          _cancellationFlagMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cancellationFlagMeta);
    }
    if (data.containsKey('restrictions')) {
      context.handle(
        _restrictionsMeta,
        restrictions.isAcceptableOrUnknown(
          data['restrictions']!,
          _restrictionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restrictionsMeta);
    }
    if (data.containsKey('required_elective_metadata')) {
      context.handle(
        _requiredElectiveMetadataMeta,
        requiredElectiveMetadata.isAcceptableOrUnknown(
          data['required_elective_metadata']!,
          _requiredElectiveMetadataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requiredElectiveMetadataMeta);
    }
    if (data.containsKey('department')) {
      context.handle(
        _departmentMeta,
        department.isAcceptableOrUnknown(data['department']!, _departmentMeta),
      );
    } else if (isInserting) {
      context.missing(_departmentMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('raw_schedule_text')) {
      context.handle(
        _rawScheduleTextMeta,
        rawScheduleText.isAcceptableOrUnknown(
          data['raw_schedule_text']!,
          _rawScheduleTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawScheduleTextMeta);
    }
    if (data.containsKey('raw_location_text')) {
      context.handle(
        _rawLocationTextMeta,
        rawLocationText.isAcceptableOrUnknown(
          data['raw_location_text']!,
          _rawLocationTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawLocationTextMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {termCode, officialCourseCode},
  ];
  @override
  NthuCatalogCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NthuCatalogCourse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      termCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_code'],
      )!,
      officialCourseCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_course_code'],
      )!,
      chineseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chinese_name'],
      )!,
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credits'],
      )!,
      teachingLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teaching_language'],
      )!,
      instructorNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor_names'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      cancellationFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancellation_flag'],
      )!,
      restrictions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restrictions'],
      )!,
      requiredElectiveMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}required_elective_metadata'],
      )!,
      department: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      rawScheduleText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_schedule_text'],
      )!,
      rawLocationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_location_text'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $NthuCatalogCoursesTable createAlias(String alias) {
    return $NthuCatalogCoursesTable(attachedDatabase, alias);
  }
}

class NthuCatalogCourse extends DataClass
    implements Insertable<NthuCatalogCourse> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String termCode;
  final String officialCourseCode;
  final String chineseName;
  final String englishName;
  final double credits;
  final String teachingLanguage;
  final String instructorNames;
  final String notes;
  final String cancellationFlag;
  final String restrictions;
  final String requiredElectiveMetadata;
  final String department;
  final String subject;
  final String rawScheduleText;
  final String rawLocationText;
  final DateTime fetchedAt;
  const NthuCatalogCourse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.termCode,
    required this.officialCourseCode,
    required this.chineseName,
    required this.englishName,
    required this.credits,
    required this.teachingLanguage,
    required this.instructorNames,
    required this.notes,
    required this.cancellationFlag,
    required this.restrictions,
    required this.requiredElectiveMetadata,
    required this.department,
    required this.subject,
    required this.rawScheduleText,
    required this.rawLocationText,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['term_code'] = Variable<String>(termCode);
    map['official_course_code'] = Variable<String>(officialCourseCode);
    map['chinese_name'] = Variable<String>(chineseName);
    map['english_name'] = Variable<String>(englishName);
    map['credits'] = Variable<double>(credits);
    map['teaching_language'] = Variable<String>(teachingLanguage);
    map['instructor_names'] = Variable<String>(instructorNames);
    map['notes'] = Variable<String>(notes);
    map['cancellation_flag'] = Variable<String>(cancellationFlag);
    map['restrictions'] = Variable<String>(restrictions);
    map['required_elective_metadata'] = Variable<String>(
      requiredElectiveMetadata,
    );
    map['department'] = Variable<String>(department);
    map['subject'] = Variable<String>(subject);
    map['raw_schedule_text'] = Variable<String>(rawScheduleText);
    map['raw_location_text'] = Variable<String>(rawLocationText);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  NthuCatalogCoursesCompanion toCompanion(bool nullToAbsent) {
    return NthuCatalogCoursesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      termCode: Value(termCode),
      officialCourseCode: Value(officialCourseCode),
      chineseName: Value(chineseName),
      englishName: Value(englishName),
      credits: Value(credits),
      teachingLanguage: Value(teachingLanguage),
      instructorNames: Value(instructorNames),
      notes: Value(notes),
      cancellationFlag: Value(cancellationFlag),
      restrictions: Value(restrictions),
      requiredElectiveMetadata: Value(requiredElectiveMetadata),
      department: Value(department),
      subject: Value(subject),
      rawScheduleText: Value(rawScheduleText),
      rawLocationText: Value(rawLocationText),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory NthuCatalogCourse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NthuCatalogCourse(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      termCode: serializer.fromJson<String>(json['termCode']),
      officialCourseCode: serializer.fromJson<String>(
        json['officialCourseCode'],
      ),
      chineseName: serializer.fromJson<String>(json['chineseName']),
      englishName: serializer.fromJson<String>(json['englishName']),
      credits: serializer.fromJson<double>(json['credits']),
      teachingLanguage: serializer.fromJson<String>(json['teachingLanguage']),
      instructorNames: serializer.fromJson<String>(json['instructorNames']),
      notes: serializer.fromJson<String>(json['notes']),
      cancellationFlag: serializer.fromJson<String>(json['cancellationFlag']),
      restrictions: serializer.fromJson<String>(json['restrictions']),
      requiredElectiveMetadata: serializer.fromJson<String>(
        json['requiredElectiveMetadata'],
      ),
      department: serializer.fromJson<String>(json['department']),
      subject: serializer.fromJson<String>(json['subject']),
      rawScheduleText: serializer.fromJson<String>(json['rawScheduleText']),
      rawLocationText: serializer.fromJson<String>(json['rawLocationText']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'termCode': serializer.toJson<String>(termCode),
      'officialCourseCode': serializer.toJson<String>(officialCourseCode),
      'chineseName': serializer.toJson<String>(chineseName),
      'englishName': serializer.toJson<String>(englishName),
      'credits': serializer.toJson<double>(credits),
      'teachingLanguage': serializer.toJson<String>(teachingLanguage),
      'instructorNames': serializer.toJson<String>(instructorNames),
      'notes': serializer.toJson<String>(notes),
      'cancellationFlag': serializer.toJson<String>(cancellationFlag),
      'restrictions': serializer.toJson<String>(restrictions),
      'requiredElectiveMetadata': serializer.toJson<String>(
        requiredElectiveMetadata,
      ),
      'department': serializer.toJson<String>(department),
      'subject': serializer.toJson<String>(subject),
      'rawScheduleText': serializer.toJson<String>(rawScheduleText),
      'rawLocationText': serializer.toJson<String>(rawLocationText),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  NthuCatalogCourse copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? termCode,
    String? officialCourseCode,
    String? chineseName,
    String? englishName,
    double? credits,
    String? teachingLanguage,
    String? instructorNames,
    String? notes,
    String? cancellationFlag,
    String? restrictions,
    String? requiredElectiveMetadata,
    String? department,
    String? subject,
    String? rawScheduleText,
    String? rawLocationText,
    DateTime? fetchedAt,
  }) => NthuCatalogCourse(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    termCode: termCode ?? this.termCode,
    officialCourseCode: officialCourseCode ?? this.officialCourseCode,
    chineseName: chineseName ?? this.chineseName,
    englishName: englishName ?? this.englishName,
    credits: credits ?? this.credits,
    teachingLanguage: teachingLanguage ?? this.teachingLanguage,
    instructorNames: instructorNames ?? this.instructorNames,
    notes: notes ?? this.notes,
    cancellationFlag: cancellationFlag ?? this.cancellationFlag,
    restrictions: restrictions ?? this.restrictions,
    requiredElectiveMetadata:
        requiredElectiveMetadata ?? this.requiredElectiveMetadata,
    department: department ?? this.department,
    subject: subject ?? this.subject,
    rawScheduleText: rawScheduleText ?? this.rawScheduleText,
    rawLocationText: rawLocationText ?? this.rawLocationText,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  NthuCatalogCourse copyWithCompanion(NthuCatalogCoursesCompanion data) {
    return NthuCatalogCourse(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      termCode: data.termCode.present ? data.termCode.value : this.termCode,
      officialCourseCode: data.officialCourseCode.present
          ? data.officialCourseCode.value
          : this.officialCourseCode,
      chineseName: data.chineseName.present
          ? data.chineseName.value
          : this.chineseName,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      credits: data.credits.present ? data.credits.value : this.credits,
      teachingLanguage: data.teachingLanguage.present
          ? data.teachingLanguage.value
          : this.teachingLanguage,
      instructorNames: data.instructorNames.present
          ? data.instructorNames.value
          : this.instructorNames,
      notes: data.notes.present ? data.notes.value : this.notes,
      cancellationFlag: data.cancellationFlag.present
          ? data.cancellationFlag.value
          : this.cancellationFlag,
      restrictions: data.restrictions.present
          ? data.restrictions.value
          : this.restrictions,
      requiredElectiveMetadata: data.requiredElectiveMetadata.present
          ? data.requiredElectiveMetadata.value
          : this.requiredElectiveMetadata,
      department: data.department.present
          ? data.department.value
          : this.department,
      subject: data.subject.present ? data.subject.value : this.subject,
      rawScheduleText: data.rawScheduleText.present
          ? data.rawScheduleText.value
          : this.rawScheduleText,
      rawLocationText: data.rawLocationText.present
          ? data.rawLocationText.value
          : this.rawLocationText,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NthuCatalogCourse(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('termCode: $termCode, ')
          ..write('officialCourseCode: $officialCourseCode, ')
          ..write('chineseName: $chineseName, ')
          ..write('englishName: $englishName, ')
          ..write('credits: $credits, ')
          ..write('teachingLanguage: $teachingLanguage, ')
          ..write('instructorNames: $instructorNames, ')
          ..write('notes: $notes, ')
          ..write('cancellationFlag: $cancellationFlag, ')
          ..write('restrictions: $restrictions, ')
          ..write('requiredElectiveMetadata: $requiredElectiveMetadata, ')
          ..write('department: $department, ')
          ..write('subject: $subject, ')
          ..write('rawScheduleText: $rawScheduleText, ')
          ..write('rawLocationText: $rawLocationText, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    termCode,
    officialCourseCode,
    chineseName,
    englishName,
    credits,
    teachingLanguage,
    instructorNames,
    notes,
    cancellationFlag,
    restrictions,
    requiredElectiveMetadata,
    department,
    subject,
    rawScheduleText,
    rawLocationText,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NthuCatalogCourse &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.termCode == this.termCode &&
          other.officialCourseCode == this.officialCourseCode &&
          other.chineseName == this.chineseName &&
          other.englishName == this.englishName &&
          other.credits == this.credits &&
          other.teachingLanguage == this.teachingLanguage &&
          other.instructorNames == this.instructorNames &&
          other.notes == this.notes &&
          other.cancellationFlag == this.cancellationFlag &&
          other.restrictions == this.restrictions &&
          other.requiredElectiveMetadata == this.requiredElectiveMetadata &&
          other.department == this.department &&
          other.subject == this.subject &&
          other.rawScheduleText == this.rawScheduleText &&
          other.rawLocationText == this.rawLocationText &&
          other.fetchedAt == this.fetchedAt);
}

class NthuCatalogCoursesCompanion extends UpdateCompanion<NthuCatalogCourse> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> termCode;
  final Value<String> officialCourseCode;
  final Value<String> chineseName;
  final Value<String> englishName;
  final Value<double> credits;
  final Value<String> teachingLanguage;
  final Value<String> instructorNames;
  final Value<String> notes;
  final Value<String> cancellationFlag;
  final Value<String> restrictions;
  final Value<String> requiredElectiveMetadata;
  final Value<String> department;
  final Value<String> subject;
  final Value<String> rawScheduleText;
  final Value<String> rawLocationText;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const NthuCatalogCoursesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.termCode = const Value.absent(),
    this.officialCourseCode = const Value.absent(),
    this.chineseName = const Value.absent(),
    this.englishName = const Value.absent(),
    this.credits = const Value.absent(),
    this.teachingLanguage = const Value.absent(),
    this.instructorNames = const Value.absent(),
    this.notes = const Value.absent(),
    this.cancellationFlag = const Value.absent(),
    this.restrictions = const Value.absent(),
    this.requiredElectiveMetadata = const Value.absent(),
    this.department = const Value.absent(),
    this.subject = const Value.absent(),
    this.rawScheduleText = const Value.absent(),
    this.rawLocationText = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NthuCatalogCoursesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String termCode,
    required String officialCourseCode,
    required String chineseName,
    required String englishName,
    required double credits,
    required String teachingLanguage,
    required String instructorNames,
    required String notes,
    required String cancellationFlag,
    required String restrictions,
    required String requiredElectiveMetadata,
    required String department,
    required String subject,
    required String rawScheduleText,
    required String rawLocationText,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       termCode = Value(termCode),
       officialCourseCode = Value(officialCourseCode),
       chineseName = Value(chineseName),
       englishName = Value(englishName),
       credits = Value(credits),
       teachingLanguage = Value(teachingLanguage),
       instructorNames = Value(instructorNames),
       notes = Value(notes),
       cancellationFlag = Value(cancellationFlag),
       restrictions = Value(restrictions),
       requiredElectiveMetadata = Value(requiredElectiveMetadata),
       department = Value(department),
       subject = Value(subject),
       rawScheduleText = Value(rawScheduleText),
       rawLocationText = Value(rawLocationText),
       fetchedAt = Value(fetchedAt);
  static Insertable<NthuCatalogCourse> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? termCode,
    Expression<String>? officialCourseCode,
    Expression<String>? chineseName,
    Expression<String>? englishName,
    Expression<double>? credits,
    Expression<String>? teachingLanguage,
    Expression<String>? instructorNames,
    Expression<String>? notes,
    Expression<String>? cancellationFlag,
    Expression<String>? restrictions,
    Expression<String>? requiredElectiveMetadata,
    Expression<String>? department,
    Expression<String>? subject,
    Expression<String>? rawScheduleText,
    Expression<String>? rawLocationText,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (termCode != null) 'term_code': termCode,
      if (officialCourseCode != null)
        'official_course_code': officialCourseCode,
      if (chineseName != null) 'chinese_name': chineseName,
      if (englishName != null) 'english_name': englishName,
      if (credits != null) 'credits': credits,
      if (teachingLanguage != null) 'teaching_language': teachingLanguage,
      if (instructorNames != null) 'instructor_names': instructorNames,
      if (notes != null) 'notes': notes,
      if (cancellationFlag != null) 'cancellation_flag': cancellationFlag,
      if (restrictions != null) 'restrictions': restrictions,
      if (requiredElectiveMetadata != null)
        'required_elective_metadata': requiredElectiveMetadata,
      if (department != null) 'department': department,
      if (subject != null) 'subject': subject,
      if (rawScheduleText != null) 'raw_schedule_text': rawScheduleText,
      if (rawLocationText != null) 'raw_location_text': rawLocationText,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NthuCatalogCoursesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? termCode,
    Value<String>? officialCourseCode,
    Value<String>? chineseName,
    Value<String>? englishName,
    Value<double>? credits,
    Value<String>? teachingLanguage,
    Value<String>? instructorNames,
    Value<String>? notes,
    Value<String>? cancellationFlag,
    Value<String>? restrictions,
    Value<String>? requiredElectiveMetadata,
    Value<String>? department,
    Value<String>? subject,
    Value<String>? rawScheduleText,
    Value<String>? rawLocationText,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return NthuCatalogCoursesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      termCode: termCode ?? this.termCode,
      officialCourseCode: officialCourseCode ?? this.officialCourseCode,
      chineseName: chineseName ?? this.chineseName,
      englishName: englishName ?? this.englishName,
      credits: credits ?? this.credits,
      teachingLanguage: teachingLanguage ?? this.teachingLanguage,
      instructorNames: instructorNames ?? this.instructorNames,
      notes: notes ?? this.notes,
      cancellationFlag: cancellationFlag ?? this.cancellationFlag,
      restrictions: restrictions ?? this.restrictions,
      requiredElectiveMetadata:
          requiredElectiveMetadata ?? this.requiredElectiveMetadata,
      department: department ?? this.department,
      subject: subject ?? this.subject,
      rawScheduleText: rawScheduleText ?? this.rawScheduleText,
      rawLocationText: rawLocationText ?? this.rawLocationText,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (termCode.present) {
      map['term_code'] = Variable<String>(termCode.value);
    }
    if (officialCourseCode.present) {
      map['official_course_code'] = Variable<String>(officialCourseCode.value);
    }
    if (chineseName.present) {
      map['chinese_name'] = Variable<String>(chineseName.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (teachingLanguage.present) {
      map['teaching_language'] = Variable<String>(teachingLanguage.value);
    }
    if (instructorNames.present) {
      map['instructor_names'] = Variable<String>(instructorNames.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (cancellationFlag.present) {
      map['cancellation_flag'] = Variable<String>(cancellationFlag.value);
    }
    if (restrictions.present) {
      map['restrictions'] = Variable<String>(restrictions.value);
    }
    if (requiredElectiveMetadata.present) {
      map['required_elective_metadata'] = Variable<String>(
        requiredElectiveMetadata.value,
      );
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (rawScheduleText.present) {
      map['raw_schedule_text'] = Variable<String>(rawScheduleText.value);
    }
    if (rawLocationText.present) {
      map['raw_location_text'] = Variable<String>(rawLocationText.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NthuCatalogCoursesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('termCode: $termCode, ')
          ..write('officialCourseCode: $officialCourseCode, ')
          ..write('chineseName: $chineseName, ')
          ..write('englishName: $englishName, ')
          ..write('credits: $credits, ')
          ..write('teachingLanguage: $teachingLanguage, ')
          ..write('instructorNames: $instructorNames, ')
          ..write('notes: $notes, ')
          ..write('cancellationFlag: $cancellationFlag, ')
          ..write('restrictions: $restrictions, ')
          ..write('requiredElectiveMetadata: $requiredElectiveMetadata, ')
          ..write('department: $department, ')
          ..write('subject: $subject, ')
          ..write('rawScheduleText: $rawScheduleText, ')
          ..write('rawLocationText: $rawLocationText, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseCodeMeta = const VerificationMeta(
    'courseCode',
  );
  @override
  late final GeneratedColumn<String> courseCode = GeneratedColumn<String>(
    'course_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
    'credits',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _semesterIdMeta = const VerificationMeta(
    'semesterId',
  );
  @override
  late final GeneratedColumn<String> semesterId = GeneratedColumn<String>(
    'semester_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES semesters (id)',
    ),
  );
  static const VerificationMeta _graduationCategoryIdMeta =
      const VerificationMeta('graduationCategoryId');
  @override
  late final GeneratedColumn<String> graduationCategoryId =
      GeneratedColumn<String>(
        'graduation_category_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES graduation_categories (id)',
        ),
      );
  @override
  late final GeneratedColumnWithTypeConverter<CourseStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CourseStatus>($CoursesTable.$converterstatus);
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _professorMeta = const VerificationMeta(
    'professor',
  );
  @override
  late final GeneratedColumn<String> professor = GeneratedColumn<String>(
    'professor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogCourseIdMeta = const VerificationMeta(
    'catalogCourseId',
  );
  @override
  late final GeneratedColumn<String> catalogCourseId = GeneratedColumn<String>(
    'catalog_course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nthu_catalog_courses (id)',
    ),
  );
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teachingLanguageMeta = const VerificationMeta(
    'teachingLanguage',
  );
  @override
  late final GeneratedColumn<String> teachingLanguage = GeneratedColumn<String>(
    'teaching_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    courseCode,
    courseName,
    credits,
    semesterId,
    graduationCategoryId,
    status,
    location,
    professor,
    notes,
    catalogCourseId,
    englishName,
    teachingLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Course> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('course_code')) {
      context.handle(
        _courseCodeMeta,
        courseCode.isAcceptableOrUnknown(data['course_code']!, _courseCodeMeta),
      );
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    } else if (isInserting) {
      context.missing(_creditsMeta);
    }
    if (data.containsKey('semester_id')) {
      context.handle(
        _semesterIdMeta,
        semesterId.isAcceptableOrUnknown(data['semester_id']!, _semesterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_semesterIdMeta);
    }
    if (data.containsKey('graduation_category_id')) {
      context.handle(
        _graduationCategoryIdMeta,
        graduationCategoryId.isAcceptableOrUnknown(
          data['graduation_category_id']!,
          _graduationCategoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_graduationCategoryIdMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('professor')) {
      context.handle(
        _professorMeta,
        professor.isAcceptableOrUnknown(data['professor']!, _professorMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('catalog_course_id')) {
      context.handle(
        _catalogCourseIdMeta,
        catalogCourseId.isAcceptableOrUnknown(
          data['catalog_course_id']!,
          _catalogCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    }
    if (data.containsKey('teaching_language')) {
      context.handle(
        _teachingLanguageMeta,
        teachingLanguage.isAcceptableOrUnknown(
          data['teaching_language']!,
          _teachingLanguageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      courseCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_code'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credits'],
      )!,
      semesterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}semester_id'],
      )!,
      graduationCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}graduation_category_id'],
      )!,
      status: $CoursesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      professor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}professor'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      catalogCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_course_id'],
      ),
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      ),
      teachingLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teaching_language'],
      ),
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CourseStatus, String, String> $converterstatus =
      const EnumNameConverter<CourseStatus>(CourseStatus.values);
}

class Course extends DataClass implements Insertable<Course> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String courseCode;
  final String courseName;
  final double credits;
  final String semesterId;
  final String graduationCategoryId;
  final CourseStatus status;
  final String? location;
  final String? professor;
  final String? notes;
  final String? catalogCourseId;
  final String? englishName;
  final String? teachingLanguage;
  const Course({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.semesterId,
    required this.graduationCategoryId,
    required this.status,
    this.location,
    this.professor,
    this.notes,
    this.catalogCourseId,
    this.englishName,
    this.teachingLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['course_code'] = Variable<String>(courseCode);
    map['course_name'] = Variable<String>(courseName);
    map['credits'] = Variable<double>(credits);
    map['semester_id'] = Variable<String>(semesterId);
    map['graduation_category_id'] = Variable<String>(graduationCategoryId);
    {
      map['status'] = Variable<String>(
        $CoursesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || professor != null) {
      map['professor'] = Variable<String>(professor);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || catalogCourseId != null) {
      map['catalog_course_id'] = Variable<String>(catalogCourseId);
    }
    if (!nullToAbsent || englishName != null) {
      map['english_name'] = Variable<String>(englishName);
    }
    if (!nullToAbsent || teachingLanguage != null) {
      map['teaching_language'] = Variable<String>(teachingLanguage);
    }
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      courseCode: Value(courseCode),
      courseName: Value(courseName),
      credits: Value(credits),
      semesterId: Value(semesterId),
      graduationCategoryId: Value(graduationCategoryId),
      status: Value(status),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      professor: professor == null && nullToAbsent
          ? const Value.absent()
          : Value(professor),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      catalogCourseId: catalogCourseId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogCourseId),
      englishName: englishName == null && nullToAbsent
          ? const Value.absent()
          : Value(englishName),
      teachingLanguage: teachingLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(teachingLanguage),
    );
  }

  factory Course.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      courseCode: serializer.fromJson<String>(json['courseCode']),
      courseName: serializer.fromJson<String>(json['courseName']),
      credits: serializer.fromJson<double>(json['credits']),
      semesterId: serializer.fromJson<String>(json['semesterId']),
      graduationCategoryId: serializer.fromJson<String>(
        json['graduationCategoryId'],
      ),
      status: $CoursesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      location: serializer.fromJson<String?>(json['location']),
      professor: serializer.fromJson<String?>(json['professor']),
      notes: serializer.fromJson<String?>(json['notes']),
      catalogCourseId: serializer.fromJson<String?>(json['catalogCourseId']),
      englishName: serializer.fromJson<String?>(json['englishName']),
      teachingLanguage: serializer.fromJson<String?>(json['teachingLanguage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'courseCode': serializer.toJson<String>(courseCode),
      'courseName': serializer.toJson<String>(courseName),
      'credits': serializer.toJson<double>(credits),
      'semesterId': serializer.toJson<String>(semesterId),
      'graduationCategoryId': serializer.toJson<String>(graduationCategoryId),
      'status': serializer.toJson<String>(
        $CoursesTable.$converterstatus.toJson(status),
      ),
      'location': serializer.toJson<String?>(location),
      'professor': serializer.toJson<String?>(professor),
      'notes': serializer.toJson<String?>(notes),
      'catalogCourseId': serializer.toJson<String?>(catalogCourseId),
      'englishName': serializer.toJson<String?>(englishName),
      'teachingLanguage': serializer.toJson<String?>(teachingLanguage),
    };
  }

  Course copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? courseCode,
    String? courseName,
    double? credits,
    String? semesterId,
    String? graduationCategoryId,
    CourseStatus? status,
    Value<String?> location = const Value.absent(),
    Value<String?> professor = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> catalogCourseId = const Value.absent(),
    Value<String?> englishName = const Value.absent(),
    Value<String?> teachingLanguage = const Value.absent(),
  }) => Course(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    courseCode: courseCode ?? this.courseCode,
    courseName: courseName ?? this.courseName,
    credits: credits ?? this.credits,
    semesterId: semesterId ?? this.semesterId,
    graduationCategoryId: graduationCategoryId ?? this.graduationCategoryId,
    status: status ?? this.status,
    location: location.present ? location.value : this.location,
    professor: professor.present ? professor.value : this.professor,
    notes: notes.present ? notes.value : this.notes,
    catalogCourseId: catalogCourseId.present
        ? catalogCourseId.value
        : this.catalogCourseId,
    englishName: englishName.present ? englishName.value : this.englishName,
    teachingLanguage: teachingLanguage.present
        ? teachingLanguage.value
        : this.teachingLanguage,
  );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      courseCode: data.courseCode.present
          ? data.courseCode.value
          : this.courseCode,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      credits: data.credits.present ? data.credits.value : this.credits,
      semesterId: data.semesterId.present
          ? data.semesterId.value
          : this.semesterId,
      graduationCategoryId: data.graduationCategoryId.present
          ? data.graduationCategoryId.value
          : this.graduationCategoryId,
      status: data.status.present ? data.status.value : this.status,
      location: data.location.present ? data.location.value : this.location,
      professor: data.professor.present ? data.professor.value : this.professor,
      notes: data.notes.present ? data.notes.value : this.notes,
      catalogCourseId: data.catalogCourseId.present
          ? data.catalogCourseId.value
          : this.catalogCourseId,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      teachingLanguage: data.teachingLanguage.present
          ? data.teachingLanguage.value
          : this.teachingLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseCode: $courseCode, ')
          ..write('courseName: $courseName, ')
          ..write('credits: $credits, ')
          ..write('semesterId: $semesterId, ')
          ..write('graduationCategoryId: $graduationCategoryId, ')
          ..write('status: $status, ')
          ..write('location: $location, ')
          ..write('professor: $professor, ')
          ..write('notes: $notes, ')
          ..write('catalogCourseId: $catalogCourseId, ')
          ..write('englishName: $englishName, ')
          ..write('teachingLanguage: $teachingLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    courseCode,
    courseName,
    credits,
    semesterId,
    graduationCategoryId,
    status,
    location,
    professor,
    notes,
    catalogCourseId,
    englishName,
    teachingLanguage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.courseCode == this.courseCode &&
          other.courseName == this.courseName &&
          other.credits == this.credits &&
          other.semesterId == this.semesterId &&
          other.graduationCategoryId == this.graduationCategoryId &&
          other.status == this.status &&
          other.location == this.location &&
          other.professor == this.professor &&
          other.notes == this.notes &&
          other.catalogCourseId == this.catalogCourseId &&
          other.englishName == this.englishName &&
          other.teachingLanguage == this.teachingLanguage);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> courseCode;
  final Value<String> courseName;
  final Value<double> credits;
  final Value<String> semesterId;
  final Value<String> graduationCategoryId;
  final Value<CourseStatus> status;
  final Value<String?> location;
  final Value<String?> professor;
  final Value<String?> notes;
  final Value<String?> catalogCourseId;
  final Value<String?> englishName;
  final Value<String?> teachingLanguage;
  final Value<int> rowid;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.courseCode = const Value.absent(),
    this.courseName = const Value.absent(),
    this.credits = const Value.absent(),
    this.semesterId = const Value.absent(),
    this.graduationCategoryId = const Value.absent(),
    this.status = const Value.absent(),
    this.location = const Value.absent(),
    this.professor = const Value.absent(),
    this.notes = const Value.absent(),
    this.catalogCourseId = const Value.absent(),
    this.englishName = const Value.absent(),
    this.teachingLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.courseCode = const Value.absent(),
    required String courseName,
    required double credits,
    required String semesterId,
    required String graduationCategoryId,
    required CourseStatus status,
    this.location = const Value.absent(),
    this.professor = const Value.absent(),
    this.notes = const Value.absent(),
    this.catalogCourseId = const Value.absent(),
    this.englishName = const Value.absent(),
    this.teachingLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseName = Value(courseName),
       credits = Value(credits),
       semesterId = Value(semesterId),
       graduationCategoryId = Value(graduationCategoryId),
       status = Value(status);
  static Insertable<Course> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? courseCode,
    Expression<String>? courseName,
    Expression<double>? credits,
    Expression<String>? semesterId,
    Expression<String>? graduationCategoryId,
    Expression<String>? status,
    Expression<String>? location,
    Expression<String>? professor,
    Expression<String>? notes,
    Expression<String>? catalogCourseId,
    Expression<String>? englishName,
    Expression<String>? teachingLanguage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (courseCode != null) 'course_code': courseCode,
      if (courseName != null) 'course_name': courseName,
      if (credits != null) 'credits': credits,
      if (semesterId != null) 'semester_id': semesterId,
      if (graduationCategoryId != null)
        'graduation_category_id': graduationCategoryId,
      if (status != null) 'status': status,
      if (location != null) 'location': location,
      if (professor != null) 'professor': professor,
      if (notes != null) 'notes': notes,
      if (catalogCourseId != null) 'catalog_course_id': catalogCourseId,
      if (englishName != null) 'english_name': englishName,
      if (teachingLanguage != null) 'teaching_language': teachingLanguage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? courseCode,
    Value<String>? courseName,
    Value<double>? credits,
    Value<String>? semesterId,
    Value<String>? graduationCategoryId,
    Value<CourseStatus>? status,
    Value<String?>? location,
    Value<String?>? professor,
    Value<String?>? notes,
    Value<String?>? catalogCourseId,
    Value<String?>? englishName,
    Value<String?>? teachingLanguage,
    Value<int>? rowid,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
      semesterId: semesterId ?? this.semesterId,
      graduationCategoryId: graduationCategoryId ?? this.graduationCategoryId,
      status: status ?? this.status,
      location: location ?? this.location,
      professor: professor ?? this.professor,
      notes: notes ?? this.notes,
      catalogCourseId: catalogCourseId ?? this.catalogCourseId,
      englishName: englishName ?? this.englishName,
      teachingLanguage: teachingLanguage ?? this.teachingLanguage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (courseCode.present) {
      map['course_code'] = Variable<String>(courseCode.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (semesterId.present) {
      map['semester_id'] = Variable<String>(semesterId.value);
    }
    if (graduationCategoryId.present) {
      map['graduation_category_id'] = Variable<String>(
        graduationCategoryId.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CoursesTable.$converterstatus.toSql(status.value),
      );
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (professor.present) {
      map['professor'] = Variable<String>(professor.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (catalogCourseId.present) {
      map['catalog_course_id'] = Variable<String>(catalogCourseId.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (teachingLanguage.present) {
      map['teaching_language'] = Variable<String>(teachingLanguage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseCode: $courseCode, ')
          ..write('courseName: $courseName, ')
          ..write('credits: $credits, ')
          ..write('semesterId: $semesterId, ')
          ..write('graduationCategoryId: $graduationCategoryId, ')
          ..write('status: $status, ')
          ..write('location: $location, ')
          ..write('professor: $professor, ')
          ..write('notes: $notes, ')
          ..write('catalogCourseId: $catalogCourseId, ')
          ..write('englishName: $englishName, ')
          ..write('teachingLanguage: $teachingLanguage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  const Tag({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
  }) => Tag(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deletedAt, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseTagsTable extends CourseTags
    with TableInfo<$CourseTagsTable, CourseTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    courseId,
    tagId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {courseId, tagId},
  ];
  @override
  CourseTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $CourseTagsTable createAlias(String alias) {
    return $CourseTagsTable(attachedDatabase, alias);
  }
}

class CourseTag extends DataClass implements Insertable<CourseTag> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String courseId;
  final String tagId;
  const CourseTag({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.courseId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['course_id'] = Variable<String>(courseId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  CourseTagsCompanion toCompanion(bool nullToAbsent) {
    return CourseTagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      courseId: Value(courseId),
      tagId: Value(tagId),
    );
  }

  factory CourseTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseTag(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      courseId: serializer.fromJson<String>(json['courseId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'courseId': serializer.toJson<String>(courseId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  CourseTag copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? courseId,
    String? tagId,
  }) => CourseTag(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    courseId: courseId ?? this.courseId,
    tagId: tagId ?? this.tagId,
  );
  CourseTag copyWithCompanion(CourseTagsCompanion data) {
    return CourseTag(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseTag(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseId: $courseId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, courseId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseTag &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.courseId == this.courseId &&
          other.tagId == this.tagId);
}

class CourseTagsCompanion extends UpdateCompanion<CourseTag> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> courseId;
  final Value<String> tagId;
  final Value<int> rowid;
  const CourseTagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.courseId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseTagsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String courseId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       tagId = Value(tagId);
  static Insertable<CourseTag> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? courseId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (courseId != null) 'course_id': courseId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseTagsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? courseId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return CourseTagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      courseId: courseId ?? this.courseId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseTagsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseId: $courseId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassMeetingsTable extends ClassMeetings
    with TableInfo<$ClassMeetingsTable, ClassMeeting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassMeetingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationOverrideMeta = const VerificationMeta(
    'locationOverride',
  );
  @override
  late final GeneratedColumn<String> locationOverride = GeneratedColumn<String>(
    'location_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayCodeMeta = const VerificationMeta(
    'dayCode',
  );
  @override
  late final GeneratedColumn<String> dayCode = GeneratedColumn<String>(
    'day_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startPeriodMeta = const VerificationMeta(
    'startPeriod',
  );
  @override
  late final GeneratedColumn<String> startPeriod = GeneratedColumn<String>(
    'start_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endPeriodMeta = const VerificationMeta(
    'endPeriod',
  );
  @override
  late final GeneratedColumn<String> endPeriod = GeneratedColumn<String>(
    'end_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    courseId,
    dayOfWeek,
    startTime,
    endTime,
    locationOverride,
    dayCode,
    startPeriod,
    endPeriod,
    needsReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_meetings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassMeeting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('location_override')) {
      context.handle(
        _locationOverrideMeta,
        locationOverride.isAcceptableOrUnknown(
          data['location_override']!,
          _locationOverrideMeta,
        ),
      );
    }
    if (data.containsKey('day_code')) {
      context.handle(
        _dayCodeMeta,
        dayCode.isAcceptableOrUnknown(data['day_code']!, _dayCodeMeta),
      );
    }
    if (data.containsKey('start_period')) {
      context.handle(
        _startPeriodMeta,
        startPeriod.isAcceptableOrUnknown(
          data['start_period']!,
          _startPeriodMeta,
        ),
      );
    }
    if (data.containsKey('end_period')) {
      context.handle(
        _endPeriodMeta,
        endPeriod.isAcceptableOrUnknown(data['end_period']!, _endPeriodMeta),
      );
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassMeeting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassMeeting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      )!,
      locationOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_override'],
      ),
      dayCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_code'],
      ),
      startPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_period'],
      ),
      endPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_period'],
      ),
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
    );
  }

  @override
  $ClassMeetingsTable createAlias(String alias) {
    return $ClassMeetingsTable(attachedDatabase, alias);
  }
}

class ClassMeeting extends DataClass implements Insertable<ClassMeeting> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String courseId;
  final int dayOfWeek;
  final int startTime;
  final int endTime;
  final String? locationOverride;
  final String? dayCode;
  final String? startPeriod;
  final String? endPeriod;
  final bool needsReview;
  const ClassMeeting({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.courseId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.locationOverride,
    this.dayCode,
    this.startPeriod,
    this.endPeriod,
    required this.needsReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['course_id'] = Variable<String>(courseId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_time'] = Variable<int>(startTime);
    map['end_time'] = Variable<int>(endTime);
    if (!nullToAbsent || locationOverride != null) {
      map['location_override'] = Variable<String>(locationOverride);
    }
    if (!nullToAbsent || dayCode != null) {
      map['day_code'] = Variable<String>(dayCode);
    }
    if (!nullToAbsent || startPeriod != null) {
      map['start_period'] = Variable<String>(startPeriod);
    }
    if (!nullToAbsent || endPeriod != null) {
      map['end_period'] = Variable<String>(endPeriod);
    }
    map['needs_review'] = Variable<bool>(needsReview);
    return map;
  }

  ClassMeetingsCompanion toCompanion(bool nullToAbsent) {
    return ClassMeetingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      courseId: Value(courseId),
      dayOfWeek: Value(dayOfWeek),
      startTime: Value(startTime),
      endTime: Value(endTime),
      locationOverride: locationOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(locationOverride),
      dayCode: dayCode == null && nullToAbsent
          ? const Value.absent()
          : Value(dayCode),
      startPeriod: startPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(startPeriod),
      endPeriod: endPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(endPeriod),
      needsReview: Value(needsReview),
    );
  }

  factory ClassMeeting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassMeeting(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      courseId: serializer.fromJson<String>(json['courseId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int>(json['endTime']),
      locationOverride: serializer.fromJson<String?>(json['locationOverride']),
      dayCode: serializer.fromJson<String?>(json['dayCode']),
      startPeriod: serializer.fromJson<String?>(json['startPeriod']),
      endPeriod: serializer.fromJson<String?>(json['endPeriod']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'courseId': serializer.toJson<String>(courseId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int>(endTime),
      'locationOverride': serializer.toJson<String?>(locationOverride),
      'dayCode': serializer.toJson<String?>(dayCode),
      'startPeriod': serializer.toJson<String?>(startPeriod),
      'endPeriod': serializer.toJson<String?>(endPeriod),
      'needsReview': serializer.toJson<bool>(needsReview),
    };
  }

  ClassMeeting copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? courseId,
    int? dayOfWeek,
    int? startTime,
    int? endTime,
    Value<String?> locationOverride = const Value.absent(),
    Value<String?> dayCode = const Value.absent(),
    Value<String?> startPeriod = const Value.absent(),
    Value<String?> endPeriod = const Value.absent(),
    bool? needsReview,
  }) => ClassMeeting(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    courseId: courseId ?? this.courseId,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    locationOverride: locationOverride.present
        ? locationOverride.value
        : this.locationOverride,
    dayCode: dayCode.present ? dayCode.value : this.dayCode,
    startPeriod: startPeriod.present ? startPeriod.value : this.startPeriod,
    endPeriod: endPeriod.present ? endPeriod.value : this.endPeriod,
    needsReview: needsReview ?? this.needsReview,
  );
  ClassMeeting copyWithCompanion(ClassMeetingsCompanion data) {
    return ClassMeeting(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      locationOverride: data.locationOverride.present
          ? data.locationOverride.value
          : this.locationOverride,
      dayCode: data.dayCode.present ? data.dayCode.value : this.dayCode,
      startPeriod: data.startPeriod.present
          ? data.startPeriod.value
          : this.startPeriod,
      endPeriod: data.endPeriod.present ? data.endPeriod.value : this.endPeriod,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassMeeting(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseId: $courseId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('locationOverride: $locationOverride, ')
          ..write('dayCode: $dayCode, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('needsReview: $needsReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    courseId,
    dayOfWeek,
    startTime,
    endTime,
    locationOverride,
    dayCode,
    startPeriod,
    endPeriod,
    needsReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassMeeting &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.courseId == this.courseId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.locationOverride == this.locationOverride &&
          other.dayCode == this.dayCode &&
          other.startPeriod == this.startPeriod &&
          other.endPeriod == this.endPeriod &&
          other.needsReview == this.needsReview);
}

class ClassMeetingsCompanion extends UpdateCompanion<ClassMeeting> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> courseId;
  final Value<int> dayOfWeek;
  final Value<int> startTime;
  final Value<int> endTime;
  final Value<String?> locationOverride;
  final Value<String?> dayCode;
  final Value<String?> startPeriod;
  final Value<String?> endPeriod;
  final Value<bool> needsReview;
  final Value<int> rowid;
  const ClassMeetingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.courseId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.locationOverride = const Value.absent(),
    this.dayCode = const Value.absent(),
    this.startPeriod = const Value.absent(),
    this.endPeriod = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassMeetingsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String courseId,
    required int dayOfWeek,
    required int startTime,
    required int endTime,
    this.locationOverride = const Value.absent(),
    this.dayCode = const Value.absent(),
    this.startPeriod = const Value.absent(),
    this.endPeriod = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       dayOfWeek = Value(dayOfWeek),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<ClassMeeting> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? courseId,
    Expression<int>? dayOfWeek,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<String>? locationOverride,
    Expression<String>? dayCode,
    Expression<String>? startPeriod,
    Expression<String>? endPeriod,
    Expression<bool>? needsReview,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (courseId != null) 'course_id': courseId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (locationOverride != null) 'location_override': locationOverride,
      if (dayCode != null) 'day_code': dayCode,
      if (startPeriod != null) 'start_period': startPeriod,
      if (endPeriod != null) 'end_period': endPeriod,
      if (needsReview != null) 'needs_review': needsReview,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassMeetingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? courseId,
    Value<int>? dayOfWeek,
    Value<int>? startTime,
    Value<int>? endTime,
    Value<String?>? locationOverride,
    Value<String?>? dayCode,
    Value<String?>? startPeriod,
    Value<String?>? endPeriod,
    Value<bool>? needsReview,
    Value<int>? rowid,
  }) {
    return ClassMeetingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      courseId: courseId ?? this.courseId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      locationOverride: locationOverride ?? this.locationOverride,
      dayCode: dayCode ?? this.dayCode,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      needsReview: needsReview ?? this.needsReview,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (locationOverride.present) {
      map['location_override'] = Variable<String>(locationOverride.value);
    }
    if (dayCode.present) {
      map['day_code'] = Variable<String>(dayCode.value);
    }
    if (startPeriod.present) {
      map['start_period'] = Variable<String>(startPeriod.value);
    }
    if (endPeriod.present) {
      map['end_period'] = Variable<String>(endPeriod.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassMeetingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseId: $courseId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('locationOverride: $locationOverride, ')
          ..write('dayCode: $dayCode, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('needsReview: $needsReview, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleExceptionsTable extends ScheduleExceptions
    with TableInfo<$ScheduleExceptionsTable, ScheduleException> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleExceptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<String> meetingId = GeneratedColumn<String>(
    'meeting_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES class_meetings (id)',
    ),
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
  @override
  late final GeneratedColumnWithTypeConverter<ExceptionType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExceptionType>($ScheduleExceptionsTable.$convertertype);
  static const VerificationMeta _replacementStartTimeMeta =
      const VerificationMeta('replacementStartTime');
  @override
  late final GeneratedColumn<int> replacementStartTime = GeneratedColumn<int>(
    'replacement_start_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacementEndTimeMeta =
      const VerificationMeta('replacementEndTime');
  @override
  late final GeneratedColumn<int> replacementEndTime = GeneratedColumn<int>(
    'replacement_end_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacementLocationMeta =
      const VerificationMeta('replacementLocation');
  @override
  late final GeneratedColumn<String> replacementLocation =
      GeneratedColumn<String>(
        'replacement_location',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _replacementDayCodeMeta =
      const VerificationMeta('replacementDayCode');
  @override
  late final GeneratedColumn<String> replacementDayCode =
      GeneratedColumn<String>(
        'replacement_day_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _replacementStartPeriodMeta =
      const VerificationMeta('replacementStartPeriod');
  @override
  late final GeneratedColumn<String> replacementStartPeriod =
      GeneratedColumn<String>(
        'replacement_start_period',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _replacementEndPeriodMeta =
      const VerificationMeta('replacementEndPeriod');
  @override
  late final GeneratedColumn<String> replacementEndPeriod =
      GeneratedColumn<String>(
        'replacement_end_period',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    courseId,
    meetingId,
    date,
    type,
    replacementStartTime,
    replacementEndTime,
    replacementLocation,
    note,
    replacementDayCode,
    replacementStartPeriod,
    replacementEndPeriod,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_exceptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleException> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('replacement_start_time')) {
      context.handle(
        _replacementStartTimeMeta,
        replacementStartTime.isAcceptableOrUnknown(
          data['replacement_start_time']!,
          _replacementStartTimeMeta,
        ),
      );
    }
    if (data.containsKey('replacement_end_time')) {
      context.handle(
        _replacementEndTimeMeta,
        replacementEndTime.isAcceptableOrUnknown(
          data['replacement_end_time']!,
          _replacementEndTimeMeta,
        ),
      );
    }
    if (data.containsKey('replacement_location')) {
      context.handle(
        _replacementLocationMeta,
        replacementLocation.isAcceptableOrUnknown(
          data['replacement_location']!,
          _replacementLocationMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('replacement_day_code')) {
      context.handle(
        _replacementDayCodeMeta,
        replacementDayCode.isAcceptableOrUnknown(
          data['replacement_day_code']!,
          _replacementDayCodeMeta,
        ),
      );
    }
    if (data.containsKey('replacement_start_period')) {
      context.handle(
        _replacementStartPeriodMeta,
        replacementStartPeriod.isAcceptableOrUnknown(
          data['replacement_start_period']!,
          _replacementStartPeriodMeta,
        ),
      );
    }
    if (data.containsKey('replacement_end_period')) {
      context.handle(
        _replacementEndPeriodMeta,
        replacementEndPeriod.isAcceptableOrUnknown(
          data['replacement_end_period']!,
          _replacementEndPeriodMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleException map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleException(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: $ScheduleExceptionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      replacementStartTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}replacement_start_time'],
      ),
      replacementEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}replacement_end_time'],
      ),
      replacementLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replacement_location'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      replacementDayCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replacement_day_code'],
      ),
      replacementStartPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replacement_start_period'],
      ),
      replacementEndPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replacement_end_period'],
      ),
    );
  }

  @override
  $ScheduleExceptionsTable createAlias(String alias) {
    return $ScheduleExceptionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExceptionType, String, String> $convertertype =
      const EnumNameConverter<ExceptionType>(ExceptionType.values);
}

class ScheduleException extends DataClass
    implements Insertable<ScheduleException> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String courseId;
  final String? meetingId;
  final DateTime date;
  final ExceptionType type;
  final int? replacementStartTime;
  final int? replacementEndTime;
  final String? replacementLocation;
  final String? note;
  final String? replacementDayCode;
  final String? replacementStartPeriod;
  final String? replacementEndPeriod;
  const ScheduleException({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.courseId,
    this.meetingId,
    required this.date,
    required this.type,
    this.replacementStartTime,
    this.replacementEndTime,
    this.replacementLocation,
    this.note,
    this.replacementDayCode,
    this.replacementStartPeriod,
    this.replacementEndPeriod,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['course_id'] = Variable<String>(courseId);
    if (!nullToAbsent || meetingId != null) {
      map['meeting_id'] = Variable<String>(meetingId);
    }
    map['date'] = Variable<DateTime>(date);
    {
      map['type'] = Variable<String>(
        $ScheduleExceptionsTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || replacementStartTime != null) {
      map['replacement_start_time'] = Variable<int>(replacementStartTime);
    }
    if (!nullToAbsent || replacementEndTime != null) {
      map['replacement_end_time'] = Variable<int>(replacementEndTime);
    }
    if (!nullToAbsent || replacementLocation != null) {
      map['replacement_location'] = Variable<String>(replacementLocation);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || replacementDayCode != null) {
      map['replacement_day_code'] = Variable<String>(replacementDayCode);
    }
    if (!nullToAbsent || replacementStartPeriod != null) {
      map['replacement_start_period'] = Variable<String>(
        replacementStartPeriod,
      );
    }
    if (!nullToAbsent || replacementEndPeriod != null) {
      map['replacement_end_period'] = Variable<String>(replacementEndPeriod);
    }
    return map;
  }

  ScheduleExceptionsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleExceptionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      courseId: Value(courseId),
      meetingId: meetingId == null && nullToAbsent
          ? const Value.absent()
          : Value(meetingId),
      date: Value(date),
      type: Value(type),
      replacementStartTime: replacementStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(replacementStartTime),
      replacementEndTime: replacementEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(replacementEndTime),
      replacementLocation: replacementLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(replacementLocation),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      replacementDayCode: replacementDayCode == null && nullToAbsent
          ? const Value.absent()
          : Value(replacementDayCode),
      replacementStartPeriod: replacementStartPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(replacementStartPeriod),
      replacementEndPeriod: replacementEndPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(replacementEndPeriod),
    );
  }

  factory ScheduleException.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleException(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      courseId: serializer.fromJson<String>(json['courseId']),
      meetingId: serializer.fromJson<String?>(json['meetingId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: $ScheduleExceptionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      replacementStartTime: serializer.fromJson<int?>(
        json['replacementStartTime'],
      ),
      replacementEndTime: serializer.fromJson<int?>(json['replacementEndTime']),
      replacementLocation: serializer.fromJson<String?>(
        json['replacementLocation'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      replacementDayCode: serializer.fromJson<String?>(
        json['replacementDayCode'],
      ),
      replacementStartPeriod: serializer.fromJson<String?>(
        json['replacementStartPeriod'],
      ),
      replacementEndPeriod: serializer.fromJson<String?>(
        json['replacementEndPeriod'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'courseId': serializer.toJson<String>(courseId),
      'meetingId': serializer.toJson<String?>(meetingId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(
        $ScheduleExceptionsTable.$convertertype.toJson(type),
      ),
      'replacementStartTime': serializer.toJson<int?>(replacementStartTime),
      'replacementEndTime': serializer.toJson<int?>(replacementEndTime),
      'replacementLocation': serializer.toJson<String?>(replacementLocation),
      'note': serializer.toJson<String?>(note),
      'replacementDayCode': serializer.toJson<String?>(replacementDayCode),
      'replacementStartPeriod': serializer.toJson<String?>(
        replacementStartPeriod,
      ),
      'replacementEndPeriod': serializer.toJson<String?>(replacementEndPeriod),
    };
  }

  ScheduleException copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? courseId,
    Value<String?> meetingId = const Value.absent(),
    DateTime? date,
    ExceptionType? type,
    Value<int?> replacementStartTime = const Value.absent(),
    Value<int?> replacementEndTime = const Value.absent(),
    Value<String?> replacementLocation = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> replacementDayCode = const Value.absent(),
    Value<String?> replacementStartPeriod = const Value.absent(),
    Value<String?> replacementEndPeriod = const Value.absent(),
  }) => ScheduleException(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    courseId: courseId ?? this.courseId,
    meetingId: meetingId.present ? meetingId.value : this.meetingId,
    date: date ?? this.date,
    type: type ?? this.type,
    replacementStartTime: replacementStartTime.present
        ? replacementStartTime.value
        : this.replacementStartTime,
    replacementEndTime: replacementEndTime.present
        ? replacementEndTime.value
        : this.replacementEndTime,
    replacementLocation: replacementLocation.present
        ? replacementLocation.value
        : this.replacementLocation,
    note: note.present ? note.value : this.note,
    replacementDayCode: replacementDayCode.present
        ? replacementDayCode.value
        : this.replacementDayCode,
    replacementStartPeriod: replacementStartPeriod.present
        ? replacementStartPeriod.value
        : this.replacementStartPeriod,
    replacementEndPeriod: replacementEndPeriod.present
        ? replacementEndPeriod.value
        : this.replacementEndPeriod,
  );
  ScheduleException copyWithCompanion(ScheduleExceptionsCompanion data) {
    return ScheduleException(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      replacementStartTime: data.replacementStartTime.present
          ? data.replacementStartTime.value
          : this.replacementStartTime,
      replacementEndTime: data.replacementEndTime.present
          ? data.replacementEndTime.value
          : this.replacementEndTime,
      replacementLocation: data.replacementLocation.present
          ? data.replacementLocation.value
          : this.replacementLocation,
      note: data.note.present ? data.note.value : this.note,
      replacementDayCode: data.replacementDayCode.present
          ? data.replacementDayCode.value
          : this.replacementDayCode,
      replacementStartPeriod: data.replacementStartPeriod.present
          ? data.replacementStartPeriod.value
          : this.replacementStartPeriod,
      replacementEndPeriod: data.replacementEndPeriod.present
          ? data.replacementEndPeriod.value
          : this.replacementEndPeriod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleException(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseId: $courseId, ')
          ..write('meetingId: $meetingId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('replacementStartTime: $replacementStartTime, ')
          ..write('replacementEndTime: $replacementEndTime, ')
          ..write('replacementLocation: $replacementLocation, ')
          ..write('note: $note, ')
          ..write('replacementDayCode: $replacementDayCode, ')
          ..write('replacementStartPeriod: $replacementStartPeriod, ')
          ..write('replacementEndPeriod: $replacementEndPeriod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    courseId,
    meetingId,
    date,
    type,
    replacementStartTime,
    replacementEndTime,
    replacementLocation,
    note,
    replacementDayCode,
    replacementStartPeriod,
    replacementEndPeriod,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleException &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.courseId == this.courseId &&
          other.meetingId == this.meetingId &&
          other.date == this.date &&
          other.type == this.type &&
          other.replacementStartTime == this.replacementStartTime &&
          other.replacementEndTime == this.replacementEndTime &&
          other.replacementLocation == this.replacementLocation &&
          other.note == this.note &&
          other.replacementDayCode == this.replacementDayCode &&
          other.replacementStartPeriod == this.replacementStartPeriod &&
          other.replacementEndPeriod == this.replacementEndPeriod);
}

class ScheduleExceptionsCompanion extends UpdateCompanion<ScheduleException> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> courseId;
  final Value<String?> meetingId;
  final Value<DateTime> date;
  final Value<ExceptionType> type;
  final Value<int?> replacementStartTime;
  final Value<int?> replacementEndTime;
  final Value<String?> replacementLocation;
  final Value<String?> note;
  final Value<String?> replacementDayCode;
  final Value<String?> replacementStartPeriod;
  final Value<String?> replacementEndPeriod;
  final Value<int> rowid;
  const ScheduleExceptionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.courseId = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.replacementStartTime = const Value.absent(),
    this.replacementEndTime = const Value.absent(),
    this.replacementLocation = const Value.absent(),
    this.note = const Value.absent(),
    this.replacementDayCode = const Value.absent(),
    this.replacementStartPeriod = const Value.absent(),
    this.replacementEndPeriod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleExceptionsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String courseId,
    this.meetingId = const Value.absent(),
    required DateTime date,
    required ExceptionType type,
    this.replacementStartTime = const Value.absent(),
    this.replacementEndTime = const Value.absent(),
    this.replacementLocation = const Value.absent(),
    this.note = const Value.absent(),
    this.replacementDayCode = const Value.absent(),
    this.replacementStartPeriod = const Value.absent(),
    this.replacementEndPeriod = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       date = Value(date),
       type = Value(type);
  static Insertable<ScheduleException> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? courseId,
    Expression<String>? meetingId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? replacementStartTime,
    Expression<int>? replacementEndTime,
    Expression<String>? replacementLocation,
    Expression<String>? note,
    Expression<String>? replacementDayCode,
    Expression<String>? replacementStartPeriod,
    Expression<String>? replacementEndPeriod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (courseId != null) 'course_id': courseId,
      if (meetingId != null) 'meeting_id': meetingId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (replacementStartTime != null)
        'replacement_start_time': replacementStartTime,
      if (replacementEndTime != null)
        'replacement_end_time': replacementEndTime,
      if (replacementLocation != null)
        'replacement_location': replacementLocation,
      if (note != null) 'note': note,
      if (replacementDayCode != null)
        'replacement_day_code': replacementDayCode,
      if (replacementStartPeriod != null)
        'replacement_start_period': replacementStartPeriod,
      if (replacementEndPeriod != null)
        'replacement_end_period': replacementEndPeriod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleExceptionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? courseId,
    Value<String?>? meetingId,
    Value<DateTime>? date,
    Value<ExceptionType>? type,
    Value<int?>? replacementStartTime,
    Value<int?>? replacementEndTime,
    Value<String?>? replacementLocation,
    Value<String?>? note,
    Value<String?>? replacementDayCode,
    Value<String?>? replacementStartPeriod,
    Value<String?>? replacementEndPeriod,
    Value<int>? rowid,
  }) {
    return ScheduleExceptionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      courseId: courseId ?? this.courseId,
      meetingId: meetingId ?? this.meetingId,
      date: date ?? this.date,
      type: type ?? this.type,
      replacementStartTime: replacementStartTime ?? this.replacementStartTime,
      replacementEndTime: replacementEndTime ?? this.replacementEndTime,
      replacementLocation: replacementLocation ?? this.replacementLocation,
      note: note ?? this.note,
      replacementDayCode: replacementDayCode ?? this.replacementDayCode,
      replacementStartPeriod:
          replacementStartPeriod ?? this.replacementStartPeriod,
      replacementEndPeriod: replacementEndPeriod ?? this.replacementEndPeriod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<String>(meetingId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ScheduleExceptionsTable.$convertertype.toSql(type.value),
      );
    }
    if (replacementStartTime.present) {
      map['replacement_start_time'] = Variable<int>(replacementStartTime.value);
    }
    if (replacementEndTime.present) {
      map['replacement_end_time'] = Variable<int>(replacementEndTime.value);
    }
    if (replacementLocation.present) {
      map['replacement_location'] = Variable<String>(replacementLocation.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (replacementDayCode.present) {
      map['replacement_day_code'] = Variable<String>(replacementDayCode.value);
    }
    if (replacementStartPeriod.present) {
      map['replacement_start_period'] = Variable<String>(
        replacementStartPeriod.value,
      );
    }
    if (replacementEndPeriod.present) {
      map['replacement_end_period'] = Variable<String>(
        replacementEndPeriod.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleExceptionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('courseId: $courseId, ')
          ..write('meetingId: $meetingId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('replacementStartTime: $replacementStartTime, ')
          ..write('replacementEndTime: $replacementEndTime, ')
          ..write('replacementLocation: $replacementLocation, ')
          ..write('note: $note, ')
          ..write('replacementDayCode: $replacementDayCode, ')
          ..write('replacementStartPeriod: $replacementStartPeriod, ')
          ..write('replacementEndPeriod: $replacementEndPeriod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AcademicSettingsTable extends AcademicSettings
    with TableInfo<$AcademicSettingsTable, AcademicSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcademicSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requiredCreditsMeta = const VerificationMeta(
    'requiredCredits',
  );
  @override
  late final GeneratedColumn<double> requiredCredits = GeneratedColumn<double>(
    'required_credits',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setupDismissedMeta = const VerificationMeta(
    'setupDismissed',
  );
  @override
  late final GeneratedColumn<bool> setupDismissed = GeneratedColumn<bool>(
    'setup_dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("setup_dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    requiredCredits,
    setupDismissed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'academic_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AcademicSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('required_credits')) {
      context.handle(
        _requiredCreditsMeta,
        requiredCredits.isAcceptableOrUnknown(
          data['required_credits']!,
          _requiredCreditsMeta,
        ),
      );
    }
    if (data.containsKey('setup_dismissed')) {
      context.handle(
        _setupDismissedMeta,
        setupDismissed.isAcceptableOrUnknown(
          data['setup_dismissed']!,
          _setupDismissedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AcademicSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AcademicSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      requiredCredits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}required_credits'],
      ),
      setupDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}setup_dismissed'],
      )!,
    );
  }

  @override
  $AcademicSettingsTable createAlias(String alias) {
    return $AcademicSettingsTable(attachedDatabase, alias);
  }
}

class AcademicSetting extends DataClass implements Insertable<AcademicSetting> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final double? requiredCredits;
  final bool setupDismissed;
  const AcademicSetting({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.requiredCredits,
    required this.setupDismissed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || requiredCredits != null) {
      map['required_credits'] = Variable<double>(requiredCredits);
    }
    map['setup_dismissed'] = Variable<bool>(setupDismissed);
    return map;
  }

  AcademicSettingsCompanion toCompanion(bool nullToAbsent) {
    return AcademicSettingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      requiredCredits: requiredCredits == null && nullToAbsent
          ? const Value.absent()
          : Value(requiredCredits),
      setupDismissed: Value(setupDismissed),
    );
  }

  factory AcademicSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AcademicSetting(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      requiredCredits: serializer.fromJson<double?>(json['requiredCredits']),
      setupDismissed: serializer.fromJson<bool>(json['setupDismissed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'requiredCredits': serializer.toJson<double?>(requiredCredits),
      'setupDismissed': serializer.toJson<bool>(setupDismissed),
    };
  }

  AcademicSetting copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<double?> requiredCredits = const Value.absent(),
    bool? setupDismissed,
  }) => AcademicSetting(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    requiredCredits: requiredCredits.present
        ? requiredCredits.value
        : this.requiredCredits,
    setupDismissed: setupDismissed ?? this.setupDismissed,
  );
  AcademicSetting copyWithCompanion(AcademicSettingsCompanion data) {
    return AcademicSetting(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      requiredCredits: data.requiredCredits.present
          ? data.requiredCredits.value
          : this.requiredCredits,
      setupDismissed: data.setupDismissed.present
          ? data.setupDismissed.value
          : this.setupDismissed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AcademicSetting(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('requiredCredits: $requiredCredits, ')
          ..write('setupDismissed: $setupDismissed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    requiredCredits,
    setupDismissed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcademicSetting &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.requiredCredits == this.requiredCredits &&
          other.setupDismissed == this.setupDismissed);
}

class AcademicSettingsCompanion extends UpdateCompanion<AcademicSetting> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<double?> requiredCredits;
  final Value<bool> setupDismissed;
  final Value<int> rowid;
  const AcademicSettingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.requiredCredits = const Value.absent(),
    this.setupDismissed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AcademicSettingsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.requiredCredits = const Value.absent(),
    this.setupDismissed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AcademicSetting> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<double>? requiredCredits,
    Expression<bool>? setupDismissed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (requiredCredits != null) 'required_credits': requiredCredits,
      if (setupDismissed != null) 'setup_dismissed': setupDismissed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AcademicSettingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<double?>? requiredCredits,
    Value<bool>? setupDismissed,
    Value<int>? rowid,
  }) {
    return AcademicSettingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      requiredCredits: requiredCredits ?? this.requiredCredits,
      setupDismissed: setupDismissed ?? this.setupDismissed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (requiredCredits.present) {
      map['required_credits'] = Variable<double>(requiredCredits.value);
    }
    if (setupDismissed.present) {
      map['setup_dismissed'] = Variable<bool>(setupDismissed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcademicSettingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('requiredCredits: $requiredCredits, ')
          ..write('setupDismissed: $setupDismissed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NthuCatalogMeetingsTable extends NthuCatalogMeetings
    with TableInfo<$NthuCatalogMeetingsTable, NthuCatalogMeeting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NthuCatalogMeetingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogCourseIdMeta = const VerificationMeta(
    'catalogCourseId',
  );
  @override
  late final GeneratedColumn<String> catalogCourseId = GeneratedColumn<String>(
    'catalog_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nthu_catalog_courses (id)',
    ),
  );
  static const VerificationMeta _dayCodeMeta = const VerificationMeta(
    'dayCode',
  );
  @override
  late final GeneratedColumn<String> dayCode = GeneratedColumn<String>(
    'day_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startPeriodMeta = const VerificationMeta(
    'startPeriod',
  );
  @override
  late final GeneratedColumn<String> startPeriod = GeneratedColumn<String>(
    'start_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endPeriodMeta = const VerificationMeta(
    'endPeriod',
  );
  @override
  late final GeneratedColumn<String> endPeriod = GeneratedColumn<String>(
    'end_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleCodeMeta = const VerificationMeta(
    'scheduleCode',
  );
  @override
  late final GeneratedColumn<String> scheduleCode = GeneratedColumn<String>(
    'schedule_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    catalogCourseId,
    dayCode,
    startPeriod,
    endPeriod,
    scheduleCode,
    location,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nthu_catalog_meetings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NthuCatalogMeeting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('catalog_course_id')) {
      context.handle(
        _catalogCourseIdMeta,
        catalogCourseId.isAcceptableOrUnknown(
          data['catalog_course_id']!,
          _catalogCourseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogCourseIdMeta);
    }
    if (data.containsKey('day_code')) {
      context.handle(
        _dayCodeMeta,
        dayCode.isAcceptableOrUnknown(data['day_code']!, _dayCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_dayCodeMeta);
    }
    if (data.containsKey('start_period')) {
      context.handle(
        _startPeriodMeta,
        startPeriod.isAcceptableOrUnknown(
          data['start_period']!,
          _startPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startPeriodMeta);
    }
    if (data.containsKey('end_period')) {
      context.handle(
        _endPeriodMeta,
        endPeriod.isAcceptableOrUnknown(data['end_period']!, _endPeriodMeta),
      );
    } else if (isInserting) {
      context.missing(_endPeriodMeta);
    }
    if (data.containsKey('schedule_code')) {
      context.handle(
        _scheduleCodeMeta,
        scheduleCode.isAcceptableOrUnknown(
          data['schedule_code']!,
          _scheduleCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleCodeMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NthuCatalogMeeting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NthuCatalogMeeting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      catalogCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_course_id'],
      )!,
      dayCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_code'],
      )!,
      startPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_period'],
      )!,
      endPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_period'],
      )!,
      scheduleCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_code'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
    );
  }

  @override
  $NthuCatalogMeetingsTable createAlias(String alias) {
    return $NthuCatalogMeetingsTable(attachedDatabase, alias);
  }
}

class NthuCatalogMeeting extends DataClass
    implements Insertable<NthuCatalogMeeting> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String catalogCourseId;
  final String dayCode;
  final String startPeriod;
  final String endPeriod;
  final String scheduleCode;
  final String location;
  const NthuCatalogMeeting({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.catalogCourseId,
    required this.dayCode,
    required this.startPeriod,
    required this.endPeriod,
    required this.scheduleCode,
    required this.location,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['catalog_course_id'] = Variable<String>(catalogCourseId);
    map['day_code'] = Variable<String>(dayCode);
    map['start_period'] = Variable<String>(startPeriod);
    map['end_period'] = Variable<String>(endPeriod);
    map['schedule_code'] = Variable<String>(scheduleCode);
    map['location'] = Variable<String>(location);
    return map;
  }

  NthuCatalogMeetingsCompanion toCompanion(bool nullToAbsent) {
    return NthuCatalogMeetingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      catalogCourseId: Value(catalogCourseId),
      dayCode: Value(dayCode),
      startPeriod: Value(startPeriod),
      endPeriod: Value(endPeriod),
      scheduleCode: Value(scheduleCode),
      location: Value(location),
    );
  }

  factory NthuCatalogMeeting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NthuCatalogMeeting(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      catalogCourseId: serializer.fromJson<String>(json['catalogCourseId']),
      dayCode: serializer.fromJson<String>(json['dayCode']),
      startPeriod: serializer.fromJson<String>(json['startPeriod']),
      endPeriod: serializer.fromJson<String>(json['endPeriod']),
      scheduleCode: serializer.fromJson<String>(json['scheduleCode']),
      location: serializer.fromJson<String>(json['location']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'catalogCourseId': serializer.toJson<String>(catalogCourseId),
      'dayCode': serializer.toJson<String>(dayCode),
      'startPeriod': serializer.toJson<String>(startPeriod),
      'endPeriod': serializer.toJson<String>(endPeriod),
      'scheduleCode': serializer.toJson<String>(scheduleCode),
      'location': serializer.toJson<String>(location),
    };
  }

  NthuCatalogMeeting copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? catalogCourseId,
    String? dayCode,
    String? startPeriod,
    String? endPeriod,
    String? scheduleCode,
    String? location,
  }) => NthuCatalogMeeting(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    catalogCourseId: catalogCourseId ?? this.catalogCourseId,
    dayCode: dayCode ?? this.dayCode,
    startPeriod: startPeriod ?? this.startPeriod,
    endPeriod: endPeriod ?? this.endPeriod,
    scheduleCode: scheduleCode ?? this.scheduleCode,
    location: location ?? this.location,
  );
  NthuCatalogMeeting copyWithCompanion(NthuCatalogMeetingsCompanion data) {
    return NthuCatalogMeeting(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      catalogCourseId: data.catalogCourseId.present
          ? data.catalogCourseId.value
          : this.catalogCourseId,
      dayCode: data.dayCode.present ? data.dayCode.value : this.dayCode,
      startPeriod: data.startPeriod.present
          ? data.startPeriod.value
          : this.startPeriod,
      endPeriod: data.endPeriod.present ? data.endPeriod.value : this.endPeriod,
      scheduleCode: data.scheduleCode.present
          ? data.scheduleCode.value
          : this.scheduleCode,
      location: data.location.present ? data.location.value : this.location,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NthuCatalogMeeting(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('catalogCourseId: $catalogCourseId, ')
          ..write('dayCode: $dayCode, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('scheduleCode: $scheduleCode, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    catalogCourseId,
    dayCode,
    startPeriod,
    endPeriod,
    scheduleCode,
    location,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NthuCatalogMeeting &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.catalogCourseId == this.catalogCourseId &&
          other.dayCode == this.dayCode &&
          other.startPeriod == this.startPeriod &&
          other.endPeriod == this.endPeriod &&
          other.scheduleCode == this.scheduleCode &&
          other.location == this.location);
}

class NthuCatalogMeetingsCompanion extends UpdateCompanion<NthuCatalogMeeting> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> catalogCourseId;
  final Value<String> dayCode;
  final Value<String> startPeriod;
  final Value<String> endPeriod;
  final Value<String> scheduleCode;
  final Value<String> location;
  final Value<int> rowid;
  const NthuCatalogMeetingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.catalogCourseId = const Value.absent(),
    this.dayCode = const Value.absent(),
    this.startPeriod = const Value.absent(),
    this.endPeriod = const Value.absent(),
    this.scheduleCode = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NthuCatalogMeetingsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String catalogCourseId,
    required String dayCode,
    required String startPeriod,
    required String endPeriod,
    required String scheduleCode,
    required String location,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       catalogCourseId = Value(catalogCourseId),
       dayCode = Value(dayCode),
       startPeriod = Value(startPeriod),
       endPeriod = Value(endPeriod),
       scheduleCode = Value(scheduleCode),
       location = Value(location);
  static Insertable<NthuCatalogMeeting> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? catalogCourseId,
    Expression<String>? dayCode,
    Expression<String>? startPeriod,
    Expression<String>? endPeriod,
    Expression<String>? scheduleCode,
    Expression<String>? location,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (catalogCourseId != null) 'catalog_course_id': catalogCourseId,
      if (dayCode != null) 'day_code': dayCode,
      if (startPeriod != null) 'start_period': startPeriod,
      if (endPeriod != null) 'end_period': endPeriod,
      if (scheduleCode != null) 'schedule_code': scheduleCode,
      if (location != null) 'location': location,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NthuCatalogMeetingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? catalogCourseId,
    Value<String>? dayCode,
    Value<String>? startPeriod,
    Value<String>? endPeriod,
    Value<String>? scheduleCode,
    Value<String>? location,
    Value<int>? rowid,
  }) {
    return NthuCatalogMeetingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      catalogCourseId: catalogCourseId ?? this.catalogCourseId,
      dayCode: dayCode ?? this.dayCode,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      scheduleCode: scheduleCode ?? this.scheduleCode,
      location: location ?? this.location,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (catalogCourseId.present) {
      map['catalog_course_id'] = Variable<String>(catalogCourseId.value);
    }
    if (dayCode.present) {
      map['day_code'] = Variable<String>(dayCode.value);
    }
    if (startPeriod.present) {
      map['start_period'] = Variable<String>(startPeriod.value);
    }
    if (endPeriod.present) {
      map['end_period'] = Variable<String>(endPeriod.value);
    }
    if (scheduleCode.present) {
      map['schedule_code'] = Variable<String>(scheduleCode.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NthuCatalogMeetingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('catalogCourseId: $catalogCourseId, ')
          ..write('dayCode: $dayCode, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('scheduleCode: $scheduleCode, ')
          ..write('location: $location, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AcademicDatabase extends GeneratedDatabase {
  _$AcademicDatabase(QueryExecutor e) : super(e);
  $AcademicDatabaseManager get managers => $AcademicDatabaseManager(this);
  late final $SemestersTable semesters = $SemestersTable(this);
  late final $GraduationCategoriesTable graduationCategories =
      $GraduationCategoriesTable(this);
  late final $NthuCatalogTermsTable nthuCatalogTerms = $NthuCatalogTermsTable(
    this,
  );
  late final $NthuCatalogCoursesTable nthuCatalogCourses =
      $NthuCatalogCoursesTable(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CourseTagsTable courseTags = $CourseTagsTable(this);
  late final $ClassMeetingsTable classMeetings = $ClassMeetingsTable(this);
  late final $ScheduleExceptionsTable scheduleExceptions =
      $ScheduleExceptionsTable(this);
  late final $AcademicSettingsTable academicSettings = $AcademicSettingsTable(
    this,
  );
  late final $NthuCatalogMeetingsTable nthuCatalogMeetings =
      $NthuCatalogMeetingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    semesters,
    graduationCategories,
    nthuCatalogTerms,
    nthuCatalogCourses,
    courses,
    tags,
    courseTags,
    classMeetings,
    scheduleExceptions,
    academicSettings,
    nthuCatalogMeetings,
  ];
}

typedef $$SemestersTableCreateCompanionBuilder =
    SemestersCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      required String academicYear,
      required String term,
      required DateTime startDate,
      required DateTime endDate,
      required SemesterStatus status,
      Value<String?> nthuTermCode,
      Value<int> rowid,
    });
typedef $$SemestersTableUpdateCompanionBuilder =
    SemestersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String> academicYear,
      Value<String> term,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<SemesterStatus> status,
      Value<String?> nthuTermCode,
      Value<int> rowid,
    });

final class $$SemestersTableReferences
    extends BaseReferences<_$AcademicDatabase, $SemestersTable, Semester> {
  $$SemestersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CoursesTable, List<Course>> _coursesRefsTable(
    _$AcademicDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courses,
    aliasName: 'semesters__id__courses__semester_id',
  );

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.semesterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SemestersTableFilterComposer
    extends Composer<_$AcademicDatabase, $SemestersTable> {
  $$SemestersTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
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

  ColumnWithTypeConverterFilters<SemesterStatus, SemesterStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get nthuTermCode => $composableBuilder(
    column: $table.nthuTermCode,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> coursesRefs(
    Expression<bool> Function($$CoursesTableFilterComposer f) f,
  ) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.semesterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SemestersTableOrderingComposer
    extends Composer<_$AcademicDatabase, $SemestersTable> {
  $$SemestersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nthuTermCode => $composableBuilder(
    column: $table.nthuTermCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SemestersTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $SemestersTable> {
  $$SemestersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SemesterStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get nthuTermCode => $composableBuilder(
    column: $table.nthuTermCode,
    builder: (column) => column,
  );

  Expression<T> coursesRefs<T extends Object>(
    Expression<T> Function($$CoursesTableAnnotationComposer a) f,
  ) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.semesterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SemestersTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $SemestersTable,
          Semester,
          $$SemestersTableFilterComposer,
          $$SemestersTableOrderingComposer,
          $$SemestersTableAnnotationComposer,
          $$SemestersTableCreateCompanionBuilder,
          $$SemestersTableUpdateCompanionBuilder,
          (Semester, $$SemestersTableReferences),
          Semester,
          PrefetchHooks Function({bool coursesRefs})
        > {
  $$SemestersTableTableManager(_$AcademicDatabase db, $SemestersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SemestersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SemestersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SemestersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> academicYear = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<SemesterStatus> status = const Value.absent(),
                Value<String?> nthuTermCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SemestersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                academicYear: academicYear,
                term: term,
                startDate: startDate,
                endDate: endDate,
                status: status,
                nthuTermCode: nthuTermCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                required String academicYear,
                required String term,
                required DateTime startDate,
                required DateTime endDate,
                required SemesterStatus status,
                Value<String?> nthuTermCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SemestersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                academicYear: academicYear,
                term: term,
                startDate: startDate,
                endDate: endDate,
                status: status,
                nthuTermCode: nthuTermCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SemestersTable, Semester>(table),
                  $$SemestersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({coursesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (coursesRefs) db.courses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (coursesRefs)
                    await $_getPrefetchedData<
                      Semester,
                      $SemestersTable,
                      Course
                    >(
                      currentTable: table,
                      referencedTable: $$SemestersTableReferences
                          ._coursesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SemestersTableReferences(db, table, p0).coursesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.semesterId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SemestersTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $SemestersTable,
      Semester,
      $$SemestersTableFilterComposer,
      $$SemestersTableOrderingComposer,
      $$SemestersTableAnnotationComposer,
      $$SemestersTableCreateCompanionBuilder,
      $$SemestersTableUpdateCompanionBuilder,
      (Semester, $$SemestersTableReferences),
      Semester,
      PrefetchHooks Function({bool coursesRefs})
    >;
typedef $$GraduationCategoriesTableCreateCompanionBuilder =
    GraduationCategoriesCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      Value<double?> requiredCredits,
      Value<String?> description,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$GraduationCategoriesTableUpdateCompanionBuilder =
    GraduationCategoriesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<double?> requiredCredits,
      Value<String?> description,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });

final class $$GraduationCategoriesTableReferences
    extends
        BaseReferences<
          _$AcademicDatabase,
          $GraduationCategoriesTable,
          GraduationCategory
        > {
  $$GraduationCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CoursesTable, List<Course>> _coursesRefsTable(
    _$AcademicDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courses,
    aliasName: 'graduation_categories__id__courses__graduation_category_id',
  );

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager($_db, $_db.courses).filter(
      (f) => f.graduationCategoryId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GraduationCategoriesTableFilterComposer
    extends Composer<_$AcademicDatabase, $GraduationCategoriesTable> {
  $$GraduationCategoriesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get requiredCredits => $composableBuilder(
    column: $table.requiredCredits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> coursesRefs(
    Expression<bool> Function($$CoursesTableFilterComposer f) f,
  ) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.graduationCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GraduationCategoriesTableOrderingComposer
    extends Composer<_$AcademicDatabase, $GraduationCategoriesTable> {
  $$GraduationCategoriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get requiredCredits => $composableBuilder(
    column: $table.requiredCredits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GraduationCategoriesTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $GraduationCategoriesTable> {
  $$GraduationCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get requiredCredits => $composableBuilder(
    column: $table.requiredCredits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> coursesRefs<T extends Object>(
    Expression<T> Function($$CoursesTableAnnotationComposer a) f,
  ) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.graduationCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GraduationCategoriesTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $GraduationCategoriesTable,
          GraduationCategory,
          $$GraduationCategoriesTableFilterComposer,
          $$GraduationCategoriesTableOrderingComposer,
          $$GraduationCategoriesTableAnnotationComposer,
          $$GraduationCategoriesTableCreateCompanionBuilder,
          $$GraduationCategoriesTableUpdateCompanionBuilder,
          (GraduationCategory, $$GraduationCategoriesTableReferences),
          GraduationCategory,
          PrefetchHooks Function({bool coursesRefs})
        > {
  $$GraduationCategoriesTableTableManager(
    _$AcademicDatabase db,
    $GraduationCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraduationCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GraduationCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GraduationCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> requiredCredits = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraduationCategoriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                requiredCredits: requiredCredits,
                description: description,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<double?> requiredCredits = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraduationCategoriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                requiredCredits: requiredCredits,
                description: description,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GraduationCategoriesTable, GraduationCategory>(
                    table,
                  ),
                  $$GraduationCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({coursesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (coursesRefs) db.courses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (coursesRefs)
                    await $_getPrefetchedData<
                      GraduationCategory,
                      $GraduationCategoriesTable,
                      Course
                    >(
                      currentTable: table,
                      referencedTable: $$GraduationCategoriesTableReferences
                          ._coursesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GraduationCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).coursesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.graduationCategoryId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GraduationCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $GraduationCategoriesTable,
      GraduationCategory,
      $$GraduationCategoriesTableFilterComposer,
      $$GraduationCategoriesTableOrderingComposer,
      $$GraduationCategoriesTableAnnotationComposer,
      $$GraduationCategoriesTableCreateCompanionBuilder,
      $$GraduationCategoriesTableUpdateCompanionBuilder,
      (GraduationCategory, $$GraduationCategoriesTableReferences),
      GraduationCategory,
      PrefetchHooks Function({bool coursesRefs})
    >;
typedef $$NthuCatalogTermsTableCreateCompanionBuilder =
    NthuCatalogTermsCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String termCode,
      required String displayName,
      required DateTime fetchedAt,
      required String sourceType,
      required String sourceUrl,
      Value<DateTime?> sourceUpdatedAt,
      Value<int> rowid,
    });
typedef $$NthuCatalogTermsTableUpdateCompanionBuilder =
    NthuCatalogTermsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> termCode,
      Value<String> displayName,
      Value<DateTime> fetchedAt,
      Value<String> sourceType,
      Value<String> sourceUrl,
      Value<DateTime?> sourceUpdatedAt,
      Value<int> rowid,
    });

final class $$NthuCatalogTermsTableReferences
    extends
        BaseReferences<
          _$AcademicDatabase,
          $NthuCatalogTermsTable,
          NthuCatalogTerm
        > {
  $$NthuCatalogTermsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$NthuCatalogCoursesTable, List<NthuCatalogCourse>>
  _nthuCatalogCoursesRefsTable(_$AcademicDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.nthuCatalogCourses,
        aliasName:
            'nthu_catalog_terms__term_code__nthu_catalog_courses__term_code',
      );

  $$NthuCatalogCoursesTableProcessedTableManager get nthuCatalogCoursesRefs {
    final manager =
        $$NthuCatalogCoursesTableTableManager(
          $_db,
          $_db.nthuCatalogCourses,
        ).filter(
          (f) =>
              f.termCode.termCode.sqlEquals($_itemColumn<String>('term_code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _nthuCatalogCoursesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NthuCatalogTermsTableFilterComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogTermsTable> {
  $$NthuCatalogTermsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get termCode => $composableBuilder(
    column: $table.termCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sourceUpdatedAt => $composableBuilder(
    column: $table.sourceUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> nthuCatalogCoursesRefs(
    Expression<bool> Function($$NthuCatalogCoursesTableFilterComposer f) f,
  ) {
    final $$NthuCatalogCoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCode,
      referencedTable: $db.nthuCatalogCourses,
      getReferencedColumn: (t) => t.termCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogCoursesTableFilterComposer(
            $db: $db,
            $table: $db.nthuCatalogCourses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NthuCatalogTermsTableOrderingComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogTermsTable> {
  $$NthuCatalogTermsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termCode => $composableBuilder(
    column: $table.termCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sourceUpdatedAt => $composableBuilder(
    column: $table.sourceUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NthuCatalogTermsTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogTermsTable> {
  $$NthuCatalogTermsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get termCode =>
      $composableBuilder(column: $table.termCode, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get sourceUpdatedAt => $composableBuilder(
    column: $table.sourceUpdatedAt,
    builder: (column) => column,
  );

  Expression<T> nthuCatalogCoursesRefs<T extends Object>(
    Expression<T> Function($$NthuCatalogCoursesTableAnnotationComposer a) f,
  ) {
    final $$NthuCatalogCoursesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCode,
          referencedTable: $db.nthuCatalogCourses,
          getReferencedColumn: (t) => t.termCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NthuCatalogCoursesTableAnnotationComposer(
                $db: $db,
                $table: $db.nthuCatalogCourses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NthuCatalogTermsTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $NthuCatalogTermsTable,
          NthuCatalogTerm,
          $$NthuCatalogTermsTableFilterComposer,
          $$NthuCatalogTermsTableOrderingComposer,
          $$NthuCatalogTermsTableAnnotationComposer,
          $$NthuCatalogTermsTableCreateCompanionBuilder,
          $$NthuCatalogTermsTableUpdateCompanionBuilder,
          (NthuCatalogTerm, $$NthuCatalogTermsTableReferences),
          NthuCatalogTerm,
          PrefetchHooks Function({bool nthuCatalogCoursesRefs})
        > {
  $$NthuCatalogTermsTableTableManager(
    _$AcademicDatabase db,
    $NthuCatalogTermsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NthuCatalogTermsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NthuCatalogTermsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NthuCatalogTermsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> termCode = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<DateTime?> sourceUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NthuCatalogTermsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                termCode: termCode,
                displayName: displayName,
                fetchedAt: fetchedAt,
                sourceType: sourceType,
                sourceUrl: sourceUrl,
                sourceUpdatedAt: sourceUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String termCode,
                required String displayName,
                required DateTime fetchedAt,
                required String sourceType,
                required String sourceUrl,
                Value<DateTime?> sourceUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NthuCatalogTermsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                termCode: termCode,
                displayName: displayName,
                fetchedAt: fetchedAt,
                sourceType: sourceType,
                sourceUrl: sourceUrl,
                sourceUpdatedAt: sourceUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NthuCatalogTermsTable, NthuCatalogTerm>(table),
                  $$NthuCatalogTermsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({nthuCatalogCoursesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (nthuCatalogCoursesRefs) db.nthuCatalogCourses,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (nthuCatalogCoursesRefs)
                    await $_getPrefetchedData<
                      NthuCatalogTerm,
                      $NthuCatalogTermsTable,
                      NthuCatalogCourse
                    >(
                      currentTable: table,
                      referencedTable: $$NthuCatalogTermsTableReferences
                          ._nthuCatalogCoursesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NthuCatalogTermsTableReferences(
                            db,
                            table,
                            p0,
                          ).nthuCatalogCoursesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.termCode == item.termCode,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NthuCatalogTermsTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $NthuCatalogTermsTable,
      NthuCatalogTerm,
      $$NthuCatalogTermsTableFilterComposer,
      $$NthuCatalogTermsTableOrderingComposer,
      $$NthuCatalogTermsTableAnnotationComposer,
      $$NthuCatalogTermsTableCreateCompanionBuilder,
      $$NthuCatalogTermsTableUpdateCompanionBuilder,
      (NthuCatalogTerm, $$NthuCatalogTermsTableReferences),
      NthuCatalogTerm,
      PrefetchHooks Function({bool nthuCatalogCoursesRefs})
    >;
typedef $$NthuCatalogCoursesTableCreateCompanionBuilder =
    NthuCatalogCoursesCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String termCode,
      required String officialCourseCode,
      required String chineseName,
      required String englishName,
      required double credits,
      required String teachingLanguage,
      required String instructorNames,
      required String notes,
      required String cancellationFlag,
      required String restrictions,
      required String requiredElectiveMetadata,
      required String department,
      required String subject,
      required String rawScheduleText,
      required String rawLocationText,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$NthuCatalogCoursesTableUpdateCompanionBuilder =
    NthuCatalogCoursesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> termCode,
      Value<String> officialCourseCode,
      Value<String> chineseName,
      Value<String> englishName,
      Value<double> credits,
      Value<String> teachingLanguage,
      Value<String> instructorNames,
      Value<String> notes,
      Value<String> cancellationFlag,
      Value<String> restrictions,
      Value<String> requiredElectiveMetadata,
      Value<String> department,
      Value<String> subject,
      Value<String> rawScheduleText,
      Value<String> rawLocationText,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

final class $$NthuCatalogCoursesTableReferences
    extends
        BaseReferences<
          _$AcademicDatabase,
          $NthuCatalogCoursesTable,
          NthuCatalogCourse
        > {
  $$NthuCatalogCoursesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NthuCatalogTermsTable _termCodeTable(_$AcademicDatabase db) =>
      db.nthuCatalogTerms.createAlias(
        'nthu_catalog_courses__term_code__nthu_catalog_terms__term_code',
      );

  $$NthuCatalogTermsTableProcessedTableManager get termCode {
    final $_column = $_itemColumn<String>('term_code')!;

    final manager = $$NthuCatalogTermsTableTableManager(
      $_db,
      $_db.nthuCatalogTerms,
    ).filter((f) => f.termCode.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CoursesTable, List<Course>> _coursesRefsTable(
    _$AcademicDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courses,
    aliasName: 'nthu_catalog_courses__id__courses__catalog_course_id',
  );

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager($_db, $_db.courses).filter(
      (f) => f.catalogCourseId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NthuCatalogMeetingsTable,
    List<NthuCatalogMeeting>
  >
  _nthuCatalogMeetingsRefsTable(
    _$AcademicDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.nthuCatalogMeetings,
    aliasName:
        'nthu_catalog_courses__id__nthu_catalog_meetings__catalog_course_id',
  );

  $$NthuCatalogMeetingsTableProcessedTableManager get nthuCatalogMeetingsRefs {
    final manager =
        $$NthuCatalogMeetingsTableTableManager(
          $_db,
          $_db.nthuCatalogMeetings,
        ).filter(
          (f) => f.catalogCourseId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _nthuCatalogMeetingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NthuCatalogCoursesTableFilterComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogCoursesTable> {
  $$NthuCatalogCoursesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officialCourseCode => $composableBuilder(
    column: $table.officialCourseCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chineseName => $composableBuilder(
    column: $table.chineseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teachingLanguage => $composableBuilder(
    column: $table.teachingLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructorNames => $composableBuilder(
    column: $table.instructorNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancellationFlag => $composableBuilder(
    column: $table.cancellationFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restrictions => $composableBuilder(
    column: $table.restrictions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requiredElectiveMetadata => $composableBuilder(
    column: $table.requiredElectiveMetadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawScheduleText => $composableBuilder(
    column: $table.rawScheduleText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawLocationText => $composableBuilder(
    column: $table.rawLocationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NthuCatalogTermsTableFilterComposer get termCode {
    final $$NthuCatalogTermsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCode,
      referencedTable: $db.nthuCatalogTerms,
      getReferencedColumn: (t) => t.termCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogTermsTableFilterComposer(
            $db: $db,
            $table: $db.nthuCatalogTerms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> coursesRefs(
    Expression<bool> Function($$CoursesTableFilterComposer f) f,
  ) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.catalogCourseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> nthuCatalogMeetingsRefs(
    Expression<bool> Function($$NthuCatalogMeetingsTableFilterComposer f) f,
  ) {
    final $$NthuCatalogMeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nthuCatalogMeetings,
      getReferencedColumn: (t) => t.catalogCourseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogMeetingsTableFilterComposer(
            $db: $db,
            $table: $db.nthuCatalogMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NthuCatalogCoursesTableOrderingComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogCoursesTable> {
  $$NthuCatalogCoursesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officialCourseCode => $composableBuilder(
    column: $table.officialCourseCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chineseName => $composableBuilder(
    column: $table.chineseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teachingLanguage => $composableBuilder(
    column: $table.teachingLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructorNames => $composableBuilder(
    column: $table.instructorNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancellationFlag => $composableBuilder(
    column: $table.cancellationFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restrictions => $composableBuilder(
    column: $table.restrictions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requiredElectiveMetadata => $composableBuilder(
    column: $table.requiredElectiveMetadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawScheduleText => $composableBuilder(
    column: $table.rawScheduleText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawLocationText => $composableBuilder(
    column: $table.rawLocationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NthuCatalogTermsTableOrderingComposer get termCode {
    final $$NthuCatalogTermsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCode,
      referencedTable: $db.nthuCatalogTerms,
      getReferencedColumn: (t) => t.termCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogTermsTableOrderingComposer(
            $db: $db,
            $table: $db.nthuCatalogTerms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NthuCatalogCoursesTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogCoursesTable> {
  $$NthuCatalogCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get officialCourseCode => $composableBuilder(
    column: $table.officialCourseCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chineseName => $composableBuilder(
    column: $table.chineseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<String> get teachingLanguage => $composableBuilder(
    column: $table.teachingLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructorNames => $composableBuilder(
    column: $table.instructorNames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get cancellationFlag => $composableBuilder(
    column: $table.cancellationFlag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restrictions => $composableBuilder(
    column: $table.restrictions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requiredElectiveMetadata => $composableBuilder(
    column: $table.requiredElectiveMetadata,
    builder: (column) => column,
  );

  GeneratedColumn<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get rawScheduleText => $composableBuilder(
    column: $table.rawScheduleText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawLocationText => $composableBuilder(
    column: $table.rawLocationText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$NthuCatalogTermsTableAnnotationComposer get termCode {
    final $$NthuCatalogTermsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCode,
      referencedTable: $db.nthuCatalogTerms,
      getReferencedColumn: (t) => t.termCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogTermsTableAnnotationComposer(
            $db: $db,
            $table: $db.nthuCatalogTerms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> coursesRefs<T extends Object>(
    Expression<T> Function($$CoursesTableAnnotationComposer a) f,
  ) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.catalogCourseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> nthuCatalogMeetingsRefs<T extends Object>(
    Expression<T> Function($$NthuCatalogMeetingsTableAnnotationComposer a) f,
  ) {
    final $$NthuCatalogMeetingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.nthuCatalogMeetings,
          getReferencedColumn: (t) => t.catalogCourseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NthuCatalogMeetingsTableAnnotationComposer(
                $db: $db,
                $table: $db.nthuCatalogMeetings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NthuCatalogCoursesTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $NthuCatalogCoursesTable,
          NthuCatalogCourse,
          $$NthuCatalogCoursesTableFilterComposer,
          $$NthuCatalogCoursesTableOrderingComposer,
          $$NthuCatalogCoursesTableAnnotationComposer,
          $$NthuCatalogCoursesTableCreateCompanionBuilder,
          $$NthuCatalogCoursesTableUpdateCompanionBuilder,
          (NthuCatalogCourse, $$NthuCatalogCoursesTableReferences),
          NthuCatalogCourse,
          PrefetchHooks Function({
            bool termCode,
            bool coursesRefs,
            bool nthuCatalogMeetingsRefs,
          })
        > {
  $$NthuCatalogCoursesTableTableManager(
    _$AcademicDatabase db,
    $NthuCatalogCoursesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NthuCatalogCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NthuCatalogCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NthuCatalogCoursesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> termCode = const Value.absent(),
                Value<String> officialCourseCode = const Value.absent(),
                Value<String> chineseName = const Value.absent(),
                Value<String> englishName = const Value.absent(),
                Value<double> credits = const Value.absent(),
                Value<String> teachingLanguage = const Value.absent(),
                Value<String> instructorNames = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> cancellationFlag = const Value.absent(),
                Value<String> restrictions = const Value.absent(),
                Value<String> requiredElectiveMetadata = const Value.absent(),
                Value<String> department = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> rawScheduleText = const Value.absent(),
                Value<String> rawLocationText = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NthuCatalogCoursesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                termCode: termCode,
                officialCourseCode: officialCourseCode,
                chineseName: chineseName,
                englishName: englishName,
                credits: credits,
                teachingLanguage: teachingLanguage,
                instructorNames: instructorNames,
                notes: notes,
                cancellationFlag: cancellationFlag,
                restrictions: restrictions,
                requiredElectiveMetadata: requiredElectiveMetadata,
                department: department,
                subject: subject,
                rawScheduleText: rawScheduleText,
                rawLocationText: rawLocationText,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String termCode,
                required String officialCourseCode,
                required String chineseName,
                required String englishName,
                required double credits,
                required String teachingLanguage,
                required String instructorNames,
                required String notes,
                required String cancellationFlag,
                required String restrictions,
                required String requiredElectiveMetadata,
                required String department,
                required String subject,
                required String rawScheduleText,
                required String rawLocationText,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => NthuCatalogCoursesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                termCode: termCode,
                officialCourseCode: officialCourseCode,
                chineseName: chineseName,
                englishName: englishName,
                credits: credits,
                teachingLanguage: teachingLanguage,
                instructorNames: instructorNames,
                notes: notes,
                cancellationFlag: cancellationFlag,
                restrictions: restrictions,
                requiredElectiveMetadata: requiredElectiveMetadata,
                department: department,
                subject: subject,
                rawScheduleText: rawScheduleText,
                rawLocationText: rawLocationText,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NthuCatalogCoursesTable, NthuCatalogCourse>(
                    table,
                  ),
                  $$NthuCatalogCoursesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                termCode = false,
                coursesRefs = false,
                nthuCatalogMeetingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (coursesRefs) db.courses,
                    if (nthuCatalogMeetingsRefs) db.nthuCatalogMeetings,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (termCode) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termCode,
                                    referencedTable:
                                        $$NthuCatalogCoursesTableReferences
                                            ._termCodeTable(db),
                                    referencedColumn:
                                        $$NthuCatalogCoursesTableReferences
                                            ._termCodeTable(db)
                                            .termCode,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (coursesRefs)
                        await $_getPrefetchedData<
                          NthuCatalogCourse,
                          $NthuCatalogCoursesTable,
                          Course
                        >(
                          currentTable: table,
                          referencedTable: $$NthuCatalogCoursesTableReferences
                              ._coursesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NthuCatalogCoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).coursesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogCourseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (nthuCatalogMeetingsRefs)
                        await $_getPrefetchedData<
                          NthuCatalogCourse,
                          $NthuCatalogCoursesTable,
                          NthuCatalogMeeting
                        >(
                          currentTable: table,
                          referencedTable: $$NthuCatalogCoursesTableReferences
                              ._nthuCatalogMeetingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NthuCatalogCoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).nthuCatalogMeetingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogCourseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NthuCatalogCoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $NthuCatalogCoursesTable,
      NthuCatalogCourse,
      $$NthuCatalogCoursesTableFilterComposer,
      $$NthuCatalogCoursesTableOrderingComposer,
      $$NthuCatalogCoursesTableAnnotationComposer,
      $$NthuCatalogCoursesTableCreateCompanionBuilder,
      $$NthuCatalogCoursesTableUpdateCompanionBuilder,
      (NthuCatalogCourse, $$NthuCatalogCoursesTableReferences),
      NthuCatalogCourse,
      PrefetchHooks Function({
        bool termCode,
        bool coursesRefs,
        bool nthuCatalogMeetingsRefs,
      })
    >;
typedef $$CoursesTableCreateCompanionBuilder =
    CoursesCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> courseCode,
      required String courseName,
      required double credits,
      required String semesterId,
      required String graduationCategoryId,
      required CourseStatus status,
      Value<String?> location,
      Value<String?> professor,
      Value<String?> notes,
      Value<String?> catalogCourseId,
      Value<String?> englishName,
      Value<String?> teachingLanguage,
      Value<int> rowid,
    });
typedef $$CoursesTableUpdateCompanionBuilder =
    CoursesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> courseCode,
      Value<String> courseName,
      Value<double> credits,
      Value<String> semesterId,
      Value<String> graduationCategoryId,
      Value<CourseStatus> status,
      Value<String?> location,
      Value<String?> professor,
      Value<String?> notes,
      Value<String?> catalogCourseId,
      Value<String?> englishName,
      Value<String?> teachingLanguage,
      Value<int> rowid,
    });

final class $$CoursesTableReferences
    extends BaseReferences<_$AcademicDatabase, $CoursesTable, Course> {
  $$CoursesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SemestersTable _semesterIdTable(_$AcademicDatabase db) =>
      db.semesters.createAlias('courses__semester_id__semesters__id');

  $$SemestersTableProcessedTableManager get semesterId {
    final $_column = $_itemColumn<String>('semester_id')!;

    final manager = $$SemestersTableTableManager(
      $_db,
      $_db.semesters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_semesterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GraduationCategoriesTable _graduationCategoryIdTable(
    _$AcademicDatabase db,
  ) => db.graduationCategories.createAlias(
    'courses__graduation_category_id__graduation_categories__id',
  );

  $$GraduationCategoriesTableProcessedTableManager get graduationCategoryId {
    final $_column = $_itemColumn<String>('graduation_category_id')!;

    final manager = $$GraduationCategoriesTableTableManager(
      $_db,
      $_db.graduationCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _graduationCategoryIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $NthuCatalogCoursesTable _catalogCourseIdTable(
    _$AcademicDatabase db,
  ) => db.nthuCatalogCourses.createAlias(
    'courses__catalog_course_id__nthu_catalog_courses__id',
  );

  $$NthuCatalogCoursesTableProcessedTableManager? get catalogCourseId {
    final $_column = $_itemColumn<String>('catalog_course_id');
    if ($_column == null) return null;
    final manager = $$NthuCatalogCoursesTableTableManager(
      $_db,
      $_db.nthuCatalogCourses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogCourseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CourseTagsTable, List<CourseTag>>
  _courseTagsRefsTable(_$AcademicDatabase db) => MultiTypedResultKey.fromTable(
    db.courseTags,
    aliasName: 'courses__id__course_tags__course_id',
  );

  $$CourseTagsTableProcessedTableManager get courseTagsRefs {
    final manager = $$CourseTagsTableTableManager(
      $_db,
      $_db.courseTags,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_courseTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ClassMeetingsTable, List<ClassMeeting>>
  _classMeetingsRefsTable(_$AcademicDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.classMeetings,
        aliasName: 'courses__id__class_meetings__course_id',
      );

  $$ClassMeetingsTableProcessedTableManager get classMeetingsRefs {
    final manager = $$ClassMeetingsTableTableManager(
      $_db,
      $_db.classMeetings,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_classMeetingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScheduleExceptionsTable, List<ScheduleException>>
  _scheduleExceptionsRefsTable(_$AcademicDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduleExceptions,
        aliasName: 'courses__id__schedule_exceptions__course_id',
      );

  $$ScheduleExceptionsTableProcessedTableManager get scheduleExceptionsRefs {
    final manager = $$ScheduleExceptionsTableTableManager(
      $_db,
      $_db.scheduleExceptions,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduleExceptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoursesTableFilterComposer
    extends Composer<_$AcademicDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CourseStatus, CourseStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get professor => $composableBuilder(
    column: $table.professor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teachingLanguage => $composableBuilder(
    column: $table.teachingLanguage,
    builder: (column) => ColumnFilters(column),
  );

  $$SemestersTableFilterComposer get semesterId {
    final $$SemestersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.semesterId,
      referencedTable: $db.semesters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemestersTableFilterComposer(
            $db: $db,
            $table: $db.semesters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GraduationCategoriesTableFilterComposer get graduationCategoryId {
    final $$GraduationCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.graduationCategoryId,
      referencedTable: $db.graduationCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraduationCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.graduationCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NthuCatalogCoursesTableFilterComposer get catalogCourseId {
    final $$NthuCatalogCoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogCourseId,
      referencedTable: $db.nthuCatalogCourses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogCoursesTableFilterComposer(
            $db: $db,
            $table: $db.nthuCatalogCourses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> courseTagsRefs(
    Expression<bool> Function($$CourseTagsTableFilterComposer f) f,
  ) {
    final $$CourseTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseTags,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTagsTableFilterComposer(
            $db: $db,
            $table: $db.courseTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> classMeetingsRefs(
    Expression<bool> Function($$ClassMeetingsTableFilterComposer f) f,
  ) {
    final $$ClassMeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classMeetings,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassMeetingsTableFilterComposer(
            $db: $db,
            $table: $db.classMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduleExceptionsRefs(
    Expression<bool> Function($$ScheduleExceptionsTableFilterComposer f) f,
  ) {
    final $$ScheduleExceptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleExceptions,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleExceptionsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleExceptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AcademicDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get professor => $composableBuilder(
    column: $table.professor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teachingLanguage => $composableBuilder(
    column: $table.teachingLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  $$SemestersTableOrderingComposer get semesterId {
    final $$SemestersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.semesterId,
      referencedTable: $db.semesters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemestersTableOrderingComposer(
            $db: $db,
            $table: $db.semesters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GraduationCategoriesTableOrderingComposer get graduationCategoryId {
    final $$GraduationCategoriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.graduationCategoryId,
          referencedTable: $db.graduationCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GraduationCategoriesTableOrderingComposer(
                $db: $db,
                $table: $db.graduationCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$NthuCatalogCoursesTableOrderingComposer get catalogCourseId {
    final $$NthuCatalogCoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogCourseId,
      referencedTable: $db.nthuCatalogCourses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogCoursesTableOrderingComposer(
            $db: $db,
            $table: $db.nthuCatalogCourses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CourseStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get professor =>
      $composableBuilder(column: $table.professor, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teachingLanguage => $composableBuilder(
    column: $table.teachingLanguage,
    builder: (column) => column,
  );

  $$SemestersTableAnnotationComposer get semesterId {
    final $$SemestersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.semesterId,
      referencedTable: $db.semesters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemestersTableAnnotationComposer(
            $db: $db,
            $table: $db.semesters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GraduationCategoriesTableAnnotationComposer get graduationCategoryId {
    final $$GraduationCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.graduationCategoryId,
          referencedTable: $db.graduationCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GraduationCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.graduationCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$NthuCatalogCoursesTableAnnotationComposer get catalogCourseId {
    final $$NthuCatalogCoursesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogCourseId,
          referencedTable: $db.nthuCatalogCourses,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NthuCatalogCoursesTableAnnotationComposer(
                $db: $db,
                $table: $db.nthuCatalogCourses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> courseTagsRefs<T extends Object>(
    Expression<T> Function($$CourseTagsTableAnnotationComposer a) f,
  ) {
    final $$CourseTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseTags,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> classMeetingsRefs<T extends Object>(
    Expression<T> Function($$ClassMeetingsTableAnnotationComposer a) f,
  ) {
    final $$ClassMeetingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classMeetings,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassMeetingsTableAnnotationComposer(
            $db: $db,
            $table: $db.classMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scheduleExceptionsRefs<T extends Object>(
    Expression<T> Function($$ScheduleExceptionsTableAnnotationComposer a) f,
  ) {
    final $$ScheduleExceptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleExceptions,
          getReferencedColumn: (t) => t.courseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleExceptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleExceptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $CoursesTable,
          Course,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (Course, $$CoursesTableReferences),
          Course,
          PrefetchHooks Function({
            bool semesterId,
            bool graduationCategoryId,
            bool catalogCourseId,
            bool courseTagsRefs,
            bool classMeetingsRefs,
            bool scheduleExceptionsRefs,
          })
        > {
  $$CoursesTableTableManager(_$AcademicDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> courseCode = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<double> credits = const Value.absent(),
                Value<String> semesterId = const Value.absent(),
                Value<String> graduationCategoryId = const Value.absent(),
                Value<CourseStatus> status = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> professor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> catalogCourseId = const Value.absent(),
                Value<String?> englishName = const Value.absent(),
                Value<String?> teachingLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseCode: courseCode,
                courseName: courseName,
                credits: credits,
                semesterId: semesterId,
                graduationCategoryId: graduationCategoryId,
                status: status,
                location: location,
                professor: professor,
                notes: notes,
                catalogCourseId: catalogCourseId,
                englishName: englishName,
                teachingLanguage: teachingLanguage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> courseCode = const Value.absent(),
                required String courseName,
                required double credits,
                required String semesterId,
                required String graduationCategoryId,
                required CourseStatus status,
                Value<String?> location = const Value.absent(),
                Value<String?> professor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> catalogCourseId = const Value.absent(),
                Value<String?> englishName = const Value.absent(),
                Value<String?> teachingLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseCode: courseCode,
                courseName: courseName,
                credits: credits,
                semesterId: semesterId,
                graduationCategoryId: graduationCategoryId,
                status: status,
                location: location,
                professor: professor,
                notes: notes,
                catalogCourseId: catalogCourseId,
                englishName: englishName,
                teachingLanguage: teachingLanguage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoursesTable, Course>(table),
                  $$CoursesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                semesterId = false,
                graduationCategoryId = false,
                catalogCourseId = false,
                courseTagsRefs = false,
                classMeetingsRefs = false,
                scheduleExceptionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseTagsRefs) db.courseTags,
                    if (classMeetingsRefs) db.classMeetings,
                    if (scheduleExceptionsRefs) db.scheduleExceptions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (semesterId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.semesterId,
                                    referencedTable: $$CoursesTableReferences
                                        ._semesterIdTable(db),
                                    referencedColumn: $$CoursesTableReferences
                                        ._semesterIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (graduationCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.graduationCategoryId,
                                    referencedTable: $$CoursesTableReferences
                                        ._graduationCategoryIdTable(db),
                                    referencedColumn: $$CoursesTableReferences
                                        ._graduationCategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (catalogCourseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogCourseId,
                                    referencedTable: $$CoursesTableReferences
                                        ._catalogCourseIdTable(db),
                                    referencedColumn: $$CoursesTableReferences
                                        ._catalogCourseIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseTagsRefs)
                        await $_getPrefetchedData<
                          Course,
                          $CoursesTable,
                          CourseTag
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._courseTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).courseTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (classMeetingsRefs)
                        await $_getPrefetchedData<
                          Course,
                          $CoursesTable,
                          ClassMeeting
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._classMeetingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).classMeetingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduleExceptionsRefs)
                        await $_getPrefetchedData<
                          Course,
                          $CoursesTable,
                          ScheduleException
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._scheduleExceptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleExceptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $CoursesTable,
      Course,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (Course, $$CoursesTableReferences),
      Course,
      PrefetchHooks Function({
        bool semesterId,
        bool graduationCategoryId,
        bool catalogCourseId,
        bool courseTagsRefs,
        bool classMeetingsRefs,
        bool scheduleExceptionsRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AcademicDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CourseTagsTable, List<CourseTag>>
  _courseTagsRefsTable(_$AcademicDatabase db) => MultiTypedResultKey.fromTable(
    db.courseTags,
    aliasName: 'tags__id__course_tags__tag_id',
  );

  $$CourseTagsTableProcessedTableManager get courseTagsRefs {
    final manager = $$CourseTagsTableTableManager(
      $_db,
      $_db.courseTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_courseTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer
    extends Composer<_$AcademicDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> courseTagsRefs(
    Expression<bool> Function($$CourseTagsTableFilterComposer f) f,
  ) {
    final $$CourseTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTagsTableFilterComposer(
            $db: $db,
            $table: $db.courseTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer
    extends Composer<_$AcademicDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> courseTagsRefs<T extends Object>(
    Expression<T> Function($$CourseTagsTableAnnotationComposer a) f,
  ) {
    final $$CourseTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool courseTagsRefs})
        > {
  $$TagsTableTableManager(_$AcademicDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({courseTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (courseTagsRefs) db.courseTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (courseTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, CourseTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._courseTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).courseTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool courseTagsRefs})
    >;
typedef $$CourseTagsTableCreateCompanionBuilder =
    CourseTagsCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String courseId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$CourseTagsTableUpdateCompanionBuilder =
    CourseTagsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> courseId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$CourseTagsTableReferences
    extends BaseReferences<_$AcademicDatabase, $CourseTagsTable, CourseTag> {
  $$CourseTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CoursesTable _courseIdTable(_$AcademicDatabase db) =>
      db.courses.createAlias('course_tags__course_id__courses__id');

  $$CoursesTableProcessedTableManager get courseId {
    final $_column = $_itemColumn<String>('course_id')!;

    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AcademicDatabase db) =>
      db.tags.createAlias('course_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CourseTagsTableFilterComposer
    extends Composer<_$AcademicDatabase, $CourseTagsTable> {
  $$CourseTagsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseTagsTableOrderingComposer
    extends Composer<_$AcademicDatabase, $CourseTagsTable> {
  $$CourseTagsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseTagsTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $CourseTagsTable> {
  $$CourseTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseTagsTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $CourseTagsTable,
          CourseTag,
          $$CourseTagsTableFilterComposer,
          $$CourseTagsTableOrderingComposer,
          $$CourseTagsTableAnnotationComposer,
          $$CourseTagsTableCreateCompanionBuilder,
          $$CourseTagsTableUpdateCompanionBuilder,
          (CourseTag, $$CourseTagsTableReferences),
          CourseTag,
          PrefetchHooks Function({bool courseId, bool tagId})
        > {
  $$CourseTagsTableTableManager(_$AcademicDatabase db, $CourseTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseTagsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseId: courseId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String courseId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => CourseTagsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseId: courseId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CourseTagsTable, CourseTag>(table),
                  $$CourseTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({courseId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (courseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.courseId,
                                referencedTable: $$CourseTagsTableReferences
                                    ._courseIdTable(db),
                                referencedColumn: $$CourseTagsTableReferences
                                    ._courseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$CourseTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$CourseTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CourseTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $CourseTagsTable,
      CourseTag,
      $$CourseTagsTableFilterComposer,
      $$CourseTagsTableOrderingComposer,
      $$CourseTagsTableAnnotationComposer,
      $$CourseTagsTableCreateCompanionBuilder,
      $$CourseTagsTableUpdateCompanionBuilder,
      (CourseTag, $$CourseTagsTableReferences),
      CourseTag,
      PrefetchHooks Function({bool courseId, bool tagId})
    >;
typedef $$ClassMeetingsTableCreateCompanionBuilder =
    ClassMeetingsCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String courseId,
      required int dayOfWeek,
      required int startTime,
      required int endTime,
      Value<String?> locationOverride,
      Value<String?> dayCode,
      Value<String?> startPeriod,
      Value<String?> endPeriod,
      Value<bool> needsReview,
      Value<int> rowid,
    });
typedef $$ClassMeetingsTableUpdateCompanionBuilder =
    ClassMeetingsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> courseId,
      Value<int> dayOfWeek,
      Value<int> startTime,
      Value<int> endTime,
      Value<String?> locationOverride,
      Value<String?> dayCode,
      Value<String?> startPeriod,
      Value<String?> endPeriod,
      Value<bool> needsReview,
      Value<int> rowid,
    });

final class $$ClassMeetingsTableReferences
    extends
        BaseReferences<_$AcademicDatabase, $ClassMeetingsTable, ClassMeeting> {
  $$ClassMeetingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoursesTable _courseIdTable(_$AcademicDatabase db) =>
      db.courses.createAlias('class_meetings__course_id__courses__id');

  $$CoursesTableProcessedTableManager get courseId {
    final $_column = $_itemColumn<String>('course_id')!;

    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScheduleExceptionsTable, List<ScheduleException>>
  _scheduleExceptionsRefsTable(_$AcademicDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduleExceptions,
        aliasName: 'class_meetings__id__schedule_exceptions__meeting_id',
      );

  $$ScheduleExceptionsTableProcessedTableManager get scheduleExceptionsRefs {
    final manager = $$ScheduleExceptionsTableTableManager(
      $_db,
      $_db.scheduleExceptions,
    ).filter((f) => f.meetingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduleExceptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClassMeetingsTableFilterComposer
    extends Composer<_$AcademicDatabase, $ClassMeetingsTable> {
  $$ClassMeetingsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationOverride => $composableBuilder(
    column: $table.locationOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayCode => $composableBuilder(
    column: $table.dayCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scheduleExceptionsRefs(
    Expression<bool> Function($$ScheduleExceptionsTableFilterComposer f) f,
  ) {
    final $$ScheduleExceptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleExceptions,
      getReferencedColumn: (t) => t.meetingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleExceptionsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleExceptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClassMeetingsTableOrderingComposer
    extends Composer<_$AcademicDatabase, $ClassMeetingsTable> {
  $$ClassMeetingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationOverride => $composableBuilder(
    column: $table.locationOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayCode => $composableBuilder(
    column: $table.dayCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassMeetingsTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $ClassMeetingsTable> {
  $$ClassMeetingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get locationOverride => $composableBuilder(
    column: $table.locationOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayCode =>
      $composableBuilder(column: $table.dayCode, builder: (column) => column);

  GeneratedColumn<String> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endPeriod =>
      $composableBuilder(column: $table.endPeriod, builder: (column) => column);

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scheduleExceptionsRefs<T extends Object>(
    Expression<T> Function($$ScheduleExceptionsTableAnnotationComposer a) f,
  ) {
    final $$ScheduleExceptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleExceptions,
          getReferencedColumn: (t) => t.meetingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleExceptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleExceptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ClassMeetingsTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $ClassMeetingsTable,
          ClassMeeting,
          $$ClassMeetingsTableFilterComposer,
          $$ClassMeetingsTableOrderingComposer,
          $$ClassMeetingsTableAnnotationComposer,
          $$ClassMeetingsTableCreateCompanionBuilder,
          $$ClassMeetingsTableUpdateCompanionBuilder,
          (ClassMeeting, $$ClassMeetingsTableReferences),
          ClassMeeting,
          PrefetchHooks Function({bool courseId, bool scheduleExceptionsRefs})
        > {
  $$ClassMeetingsTableTableManager(
    _$AcademicDatabase db,
    $ClassMeetingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassMeetingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassMeetingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassMeetingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int> endTime = const Value.absent(),
                Value<String?> locationOverride = const Value.absent(),
                Value<String?> dayCode = const Value.absent(),
                Value<String?> startPeriod = const Value.absent(),
                Value<String?> endPeriod = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassMeetingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseId: courseId,
                dayOfWeek: dayOfWeek,
                startTime: startTime,
                endTime: endTime,
                locationOverride: locationOverride,
                dayCode: dayCode,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                needsReview: needsReview,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String courseId,
                required int dayOfWeek,
                required int startTime,
                required int endTime,
                Value<String?> locationOverride = const Value.absent(),
                Value<String?> dayCode = const Value.absent(),
                Value<String?> startPeriod = const Value.absent(),
                Value<String?> endPeriod = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassMeetingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseId: courseId,
                dayOfWeek: dayOfWeek,
                startTime: startTime,
                endTime: endTime,
                locationOverride: locationOverride,
                dayCode: dayCode,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                needsReview: needsReview,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClassMeetingsTable, ClassMeeting>(table),
                  $$ClassMeetingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({courseId = false, scheduleExceptionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleExceptionsRefs) db.scheduleExceptions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (courseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.courseId,
                                    referencedTable:
                                        $$ClassMeetingsTableReferences
                                            ._courseIdTable(db),
                                    referencedColumn:
                                        $$ClassMeetingsTableReferences
                                            ._courseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleExceptionsRefs)
                        await $_getPrefetchedData<
                          ClassMeeting,
                          $ClassMeetingsTable,
                          ScheduleException
                        >(
                          currentTable: table,
                          referencedTable: $$ClassMeetingsTableReferences
                              ._scheduleExceptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassMeetingsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleExceptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.meetingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClassMeetingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $ClassMeetingsTable,
      ClassMeeting,
      $$ClassMeetingsTableFilterComposer,
      $$ClassMeetingsTableOrderingComposer,
      $$ClassMeetingsTableAnnotationComposer,
      $$ClassMeetingsTableCreateCompanionBuilder,
      $$ClassMeetingsTableUpdateCompanionBuilder,
      (ClassMeeting, $$ClassMeetingsTableReferences),
      ClassMeeting,
      PrefetchHooks Function({bool courseId, bool scheduleExceptionsRefs})
    >;
typedef $$ScheduleExceptionsTableCreateCompanionBuilder =
    ScheduleExceptionsCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String courseId,
      Value<String?> meetingId,
      required DateTime date,
      required ExceptionType type,
      Value<int?> replacementStartTime,
      Value<int?> replacementEndTime,
      Value<String?> replacementLocation,
      Value<String?> note,
      Value<String?> replacementDayCode,
      Value<String?> replacementStartPeriod,
      Value<String?> replacementEndPeriod,
      Value<int> rowid,
    });
typedef $$ScheduleExceptionsTableUpdateCompanionBuilder =
    ScheduleExceptionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> courseId,
      Value<String?> meetingId,
      Value<DateTime> date,
      Value<ExceptionType> type,
      Value<int?> replacementStartTime,
      Value<int?> replacementEndTime,
      Value<String?> replacementLocation,
      Value<String?> note,
      Value<String?> replacementDayCode,
      Value<String?> replacementStartPeriod,
      Value<String?> replacementEndPeriod,
      Value<int> rowid,
    });

final class $$ScheduleExceptionsTableReferences
    extends
        BaseReferences<
          _$AcademicDatabase,
          $ScheduleExceptionsTable,
          ScheduleException
        > {
  $$ScheduleExceptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoursesTable _courseIdTable(_$AcademicDatabase db) =>
      db.courses.createAlias('schedule_exceptions__course_id__courses__id');

  $$CoursesTableProcessedTableManager get courseId {
    final $_column = $_itemColumn<String>('course_id')!;

    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClassMeetingsTable _meetingIdTable(_$AcademicDatabase db) => db
      .classMeetings
      .createAlias('schedule_exceptions__meeting_id__class_meetings__id');

  $$ClassMeetingsTableProcessedTableManager? get meetingId {
    final $_column = $_itemColumn<String>('meeting_id');
    if ($_column == null) return null;
    final manager = $$ClassMeetingsTableTableManager(
      $_db,
      $_db.classMeetings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_meetingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduleExceptionsTableFilterComposer
    extends Composer<_$AcademicDatabase, $ScheduleExceptionsTable> {
  $$ScheduleExceptionsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExceptionType, ExceptionType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get replacementStartTime => $composableBuilder(
    column: $table.replacementStartTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replacementEndTime => $composableBuilder(
    column: $table.replacementEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacementLocation => $composableBuilder(
    column: $table.replacementLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacementDayCode => $composableBuilder(
    column: $table.replacementDayCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacementStartPeriod => $composableBuilder(
    column: $table.replacementStartPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacementEndPeriod => $composableBuilder(
    column: $table.replacementEndPeriod,
    builder: (column) => ColumnFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClassMeetingsTableFilterComposer get meetingId {
    final $$ClassMeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.classMeetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassMeetingsTableFilterComposer(
            $db: $db,
            $table: $db.classMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleExceptionsTableOrderingComposer
    extends Composer<_$AcademicDatabase, $ScheduleExceptionsTable> {
  $$ScheduleExceptionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replacementStartTime => $composableBuilder(
    column: $table.replacementStartTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replacementEndTime => $composableBuilder(
    column: $table.replacementEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacementLocation => $composableBuilder(
    column: $table.replacementLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacementDayCode => $composableBuilder(
    column: $table.replacementDayCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacementStartPeriod => $composableBuilder(
    column: $table.replacementStartPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacementEndPeriod => $composableBuilder(
    column: $table.replacementEndPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClassMeetingsTableOrderingComposer get meetingId {
    final $$ClassMeetingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.classMeetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassMeetingsTableOrderingComposer(
            $db: $db,
            $table: $db.classMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleExceptionsTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $ScheduleExceptionsTable> {
  $$ScheduleExceptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExceptionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get replacementStartTime => $composableBuilder(
    column: $table.replacementStartTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replacementEndTime => $composableBuilder(
    column: $table.replacementEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replacementLocation => $composableBuilder(
    column: $table.replacementLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get replacementDayCode => $composableBuilder(
    column: $table.replacementDayCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replacementStartPeriod => $composableBuilder(
    column: $table.replacementStartPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replacementEndPeriod => $composableBuilder(
    column: $table.replacementEndPeriod,
    builder: (column) => column,
  );

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClassMeetingsTableAnnotationComposer get meetingId {
    final $$ClassMeetingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.classMeetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassMeetingsTableAnnotationComposer(
            $db: $db,
            $table: $db.classMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleExceptionsTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $ScheduleExceptionsTable,
          ScheduleException,
          $$ScheduleExceptionsTableFilterComposer,
          $$ScheduleExceptionsTableOrderingComposer,
          $$ScheduleExceptionsTableAnnotationComposer,
          $$ScheduleExceptionsTableCreateCompanionBuilder,
          $$ScheduleExceptionsTableUpdateCompanionBuilder,
          (ScheduleException, $$ScheduleExceptionsTableReferences),
          ScheduleException,
          PrefetchHooks Function({bool courseId, bool meetingId})
        > {
  $$ScheduleExceptionsTableTableManager(
    _$AcademicDatabase db,
    $ScheduleExceptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleExceptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleExceptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleExceptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String?> meetingId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<ExceptionType> type = const Value.absent(),
                Value<int?> replacementStartTime = const Value.absent(),
                Value<int?> replacementEndTime = const Value.absent(),
                Value<String?> replacementLocation = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> replacementDayCode = const Value.absent(),
                Value<String?> replacementStartPeriod = const Value.absent(),
                Value<String?> replacementEndPeriod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleExceptionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseId: courseId,
                meetingId: meetingId,
                date: date,
                type: type,
                replacementStartTime: replacementStartTime,
                replacementEndTime: replacementEndTime,
                replacementLocation: replacementLocation,
                note: note,
                replacementDayCode: replacementDayCode,
                replacementStartPeriod: replacementStartPeriod,
                replacementEndPeriod: replacementEndPeriod,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String courseId,
                Value<String?> meetingId = const Value.absent(),
                required DateTime date,
                required ExceptionType type,
                Value<int?> replacementStartTime = const Value.absent(),
                Value<int?> replacementEndTime = const Value.absent(),
                Value<String?> replacementLocation = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> replacementDayCode = const Value.absent(),
                Value<String?> replacementStartPeriod = const Value.absent(),
                Value<String?> replacementEndPeriod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleExceptionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                courseId: courseId,
                meetingId: meetingId,
                date: date,
                type: type,
                replacementStartTime: replacementStartTime,
                replacementEndTime: replacementEndTime,
                replacementLocation: replacementLocation,
                note: note,
                replacementDayCode: replacementDayCode,
                replacementStartPeriod: replacementStartPeriod,
                replacementEndPeriod: replacementEndPeriod,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduleExceptionsTable, ScheduleException>(
                    table,
                  ),
                  $$ScheduleExceptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({courseId = false, meetingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (courseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.courseId,
                                referencedTable:
                                    $$ScheduleExceptionsTableReferences
                                        ._courseIdTable(db),
                                referencedColumn:
                                    $$ScheduleExceptionsTableReferences
                                        ._courseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (meetingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.meetingId,
                                referencedTable:
                                    $$ScheduleExceptionsTableReferences
                                        ._meetingIdTable(db),
                                referencedColumn:
                                    $$ScheduleExceptionsTableReferences
                                        ._meetingIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduleExceptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $ScheduleExceptionsTable,
      ScheduleException,
      $$ScheduleExceptionsTableFilterComposer,
      $$ScheduleExceptionsTableOrderingComposer,
      $$ScheduleExceptionsTableAnnotationComposer,
      $$ScheduleExceptionsTableCreateCompanionBuilder,
      $$ScheduleExceptionsTableUpdateCompanionBuilder,
      (ScheduleException, $$ScheduleExceptionsTableReferences),
      ScheduleException,
      PrefetchHooks Function({bool courseId, bool meetingId})
    >;
typedef $$AcademicSettingsTableCreateCompanionBuilder =
    AcademicSettingsCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<double?> requiredCredits,
      Value<bool> setupDismissed,
      Value<int> rowid,
    });
typedef $$AcademicSettingsTableUpdateCompanionBuilder =
    AcademicSettingsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<double?> requiredCredits,
      Value<bool> setupDismissed,
      Value<int> rowid,
    });

class $$AcademicSettingsTableFilterComposer
    extends Composer<_$AcademicDatabase, $AcademicSettingsTable> {
  $$AcademicSettingsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get requiredCredits => $composableBuilder(
    column: $table.requiredCredits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get setupDismissed => $composableBuilder(
    column: $table.setupDismissed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AcademicSettingsTableOrderingComposer
    extends Composer<_$AcademicDatabase, $AcademicSettingsTable> {
  $$AcademicSettingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get requiredCredits => $composableBuilder(
    column: $table.requiredCredits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get setupDismissed => $composableBuilder(
    column: $table.setupDismissed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcademicSettingsTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $AcademicSettingsTable> {
  $$AcademicSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<double> get requiredCredits => $composableBuilder(
    column: $table.requiredCredits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get setupDismissed => $composableBuilder(
    column: $table.setupDismissed,
    builder: (column) => column,
  );
}

class $$AcademicSettingsTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $AcademicSettingsTable,
          AcademicSetting,
          $$AcademicSettingsTableFilterComposer,
          $$AcademicSettingsTableOrderingComposer,
          $$AcademicSettingsTableAnnotationComposer,
          $$AcademicSettingsTableCreateCompanionBuilder,
          $$AcademicSettingsTableUpdateCompanionBuilder,
          (
            AcademicSetting,
            BaseReferences<
              _$AcademicDatabase,
              $AcademicSettingsTable,
              AcademicSetting
            >,
          ),
          AcademicSetting,
          PrefetchHooks Function()
        > {
  $$AcademicSettingsTableTableManager(
    _$AcademicDatabase db,
    $AcademicSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcademicSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcademicSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcademicSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<double?> requiredCredits = const Value.absent(),
                Value<bool> setupDismissed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AcademicSettingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                requiredCredits: requiredCredits,
                setupDismissed: setupDismissed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<double?> requiredCredits = const Value.absent(),
                Value<bool> setupDismissed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AcademicSettingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                requiredCredits: requiredCredits,
                setupDismissed: setupDismissed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AcademicSettingsTable, AcademicSetting>(table),
                  BaseReferences<
                    _$AcademicDatabase,
                    $AcademicSettingsTable,
                    AcademicSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AcademicSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $AcademicSettingsTable,
      AcademicSetting,
      $$AcademicSettingsTableFilterComposer,
      $$AcademicSettingsTableOrderingComposer,
      $$AcademicSettingsTableAnnotationComposer,
      $$AcademicSettingsTableCreateCompanionBuilder,
      $$AcademicSettingsTableUpdateCompanionBuilder,
      (
        AcademicSetting,
        BaseReferences<
          _$AcademicDatabase,
          $AcademicSettingsTable,
          AcademicSetting
        >,
      ),
      AcademicSetting,
      PrefetchHooks Function()
    >;
typedef $$NthuCatalogMeetingsTableCreateCompanionBuilder =
    NthuCatalogMeetingsCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String catalogCourseId,
      required String dayCode,
      required String startPeriod,
      required String endPeriod,
      required String scheduleCode,
      required String location,
      Value<int> rowid,
    });
typedef $$NthuCatalogMeetingsTableUpdateCompanionBuilder =
    NthuCatalogMeetingsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> catalogCourseId,
      Value<String> dayCode,
      Value<String> startPeriod,
      Value<String> endPeriod,
      Value<String> scheduleCode,
      Value<String> location,
      Value<int> rowid,
    });

final class $$NthuCatalogMeetingsTableReferences
    extends
        BaseReferences<
          _$AcademicDatabase,
          $NthuCatalogMeetingsTable,
          NthuCatalogMeeting
        > {
  $$NthuCatalogMeetingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NthuCatalogCoursesTable _catalogCourseIdTable(
    _$AcademicDatabase db,
  ) => db.nthuCatalogCourses.createAlias(
    'nthu_catalog_meetings__catalog_course_id__nthu_catalog_courses__id',
  );

  $$NthuCatalogCoursesTableProcessedTableManager get catalogCourseId {
    final $_column = $_itemColumn<String>('catalog_course_id')!;

    final manager = $$NthuCatalogCoursesTableTableManager(
      $_db,
      $_db.nthuCatalogCourses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogCourseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NthuCatalogMeetingsTableFilterComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogMeetingsTable> {
  $$NthuCatalogMeetingsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayCode => $composableBuilder(
    column: $table.dayCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleCode => $composableBuilder(
    column: $table.scheduleCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  $$NthuCatalogCoursesTableFilterComposer get catalogCourseId {
    final $$NthuCatalogCoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogCourseId,
      referencedTable: $db.nthuCatalogCourses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogCoursesTableFilterComposer(
            $db: $db,
            $table: $db.nthuCatalogCourses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NthuCatalogMeetingsTableOrderingComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogMeetingsTable> {
  $$NthuCatalogMeetingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayCode => $composableBuilder(
    column: $table.dayCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleCode => $composableBuilder(
    column: $table.scheduleCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  $$NthuCatalogCoursesTableOrderingComposer get catalogCourseId {
    final $$NthuCatalogCoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogCourseId,
      referencedTable: $db.nthuCatalogCourses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NthuCatalogCoursesTableOrderingComposer(
            $db: $db,
            $table: $db.nthuCatalogCourses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NthuCatalogMeetingsTableAnnotationComposer
    extends Composer<_$AcademicDatabase, $NthuCatalogMeetingsTable> {
  $$NthuCatalogMeetingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get dayCode =>
      $composableBuilder(column: $table.dayCode, builder: (column) => column);

  GeneratedColumn<String> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endPeriod =>
      $composableBuilder(column: $table.endPeriod, builder: (column) => column);

  GeneratedColumn<String> get scheduleCode => $composableBuilder(
    column: $table.scheduleCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  $$NthuCatalogCoursesTableAnnotationComposer get catalogCourseId {
    final $$NthuCatalogCoursesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogCourseId,
          referencedTable: $db.nthuCatalogCourses,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NthuCatalogCoursesTableAnnotationComposer(
                $db: $db,
                $table: $db.nthuCatalogCourses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NthuCatalogMeetingsTableTableManager
    extends
        RootTableManager<
          _$AcademicDatabase,
          $NthuCatalogMeetingsTable,
          NthuCatalogMeeting,
          $$NthuCatalogMeetingsTableFilterComposer,
          $$NthuCatalogMeetingsTableOrderingComposer,
          $$NthuCatalogMeetingsTableAnnotationComposer,
          $$NthuCatalogMeetingsTableCreateCompanionBuilder,
          $$NthuCatalogMeetingsTableUpdateCompanionBuilder,
          (NthuCatalogMeeting, $$NthuCatalogMeetingsTableReferences),
          NthuCatalogMeeting,
          PrefetchHooks Function({bool catalogCourseId})
        > {
  $$NthuCatalogMeetingsTableTableManager(
    _$AcademicDatabase db,
    $NthuCatalogMeetingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NthuCatalogMeetingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NthuCatalogMeetingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NthuCatalogMeetingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> catalogCourseId = const Value.absent(),
                Value<String> dayCode = const Value.absent(),
                Value<String> startPeriod = const Value.absent(),
                Value<String> endPeriod = const Value.absent(),
                Value<String> scheduleCode = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NthuCatalogMeetingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                catalogCourseId: catalogCourseId,
                dayCode: dayCode,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                scheduleCode: scheduleCode,
                location: location,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String catalogCourseId,
                required String dayCode,
                required String startPeriod,
                required String endPeriod,
                required String scheduleCode,
                required String location,
                Value<int> rowid = const Value.absent(),
              }) => NthuCatalogMeetingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                catalogCourseId: catalogCourseId,
                dayCode: dayCode,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                scheduleCode: scheduleCode,
                location: location,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NthuCatalogMeetingsTable, NthuCatalogMeeting>(
                    table,
                  ),
                  $$NthuCatalogMeetingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catalogCourseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (catalogCourseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.catalogCourseId,
                                referencedTable:
                                    $$NthuCatalogMeetingsTableReferences
                                        ._catalogCourseIdTable(db),
                                referencedColumn:
                                    $$NthuCatalogMeetingsTableReferences
                                        ._catalogCourseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NthuCatalogMeetingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AcademicDatabase,
      $NthuCatalogMeetingsTable,
      NthuCatalogMeeting,
      $$NthuCatalogMeetingsTableFilterComposer,
      $$NthuCatalogMeetingsTableOrderingComposer,
      $$NthuCatalogMeetingsTableAnnotationComposer,
      $$NthuCatalogMeetingsTableCreateCompanionBuilder,
      $$NthuCatalogMeetingsTableUpdateCompanionBuilder,
      (NthuCatalogMeeting, $$NthuCatalogMeetingsTableReferences),
      NthuCatalogMeeting,
      PrefetchHooks Function({bool catalogCourseId})
    >;

class $AcademicDatabaseManager {
  final _$AcademicDatabase _db;
  $AcademicDatabaseManager(this._db);
  $$SemestersTableTableManager get semesters =>
      $$SemestersTableTableManager(_db, _db.semesters);
  $$GraduationCategoriesTableTableManager get graduationCategories =>
      $$GraduationCategoriesTableTableManager(_db, _db.graduationCategories);
  $$NthuCatalogTermsTableTableManager get nthuCatalogTerms =>
      $$NthuCatalogTermsTableTableManager(_db, _db.nthuCatalogTerms);
  $$NthuCatalogCoursesTableTableManager get nthuCatalogCourses =>
      $$NthuCatalogCoursesTableTableManager(_db, _db.nthuCatalogCourses);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$CourseTagsTableTableManager get courseTags =>
      $$CourseTagsTableTableManager(_db, _db.courseTags);
  $$ClassMeetingsTableTableManager get classMeetings =>
      $$ClassMeetingsTableTableManager(_db, _db.classMeetings);
  $$ScheduleExceptionsTableTableManager get scheduleExceptions =>
      $$ScheduleExceptionsTableTableManager(_db, _db.scheduleExceptions);
  $$AcademicSettingsTableTableManager get academicSettings =>
      $$AcademicSettingsTableTableManager(_db, _db.academicSettings);
  $$NthuCatalogMeetingsTableTableManager get nthuCatalogMeetings =>
      $$NthuCatalogMeetingsTableTableManager(_db, _db.nthuCatalogMeetings);
}
