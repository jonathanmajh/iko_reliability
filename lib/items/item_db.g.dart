// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_db.dart';

// ignore_for_file: type=lint
class $ItemCachesTable extends ItemCaches
    with TableInfo<$ItemCachesTable, ItemCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemnumMeta =
      const VerificationMeta('itemnum');
  @override
  late final GeneratedColumn<String> itemnum = GeneratedColumn<String>(
      'itemnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changedDateMeta =
      const VerificationMeta('changedDate');
  @override
  late final GeneratedColumn<String> changedDate = GeneratedColumn<String>(
      'changed_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _searchTextMeta =
      const VerificationMeta('searchText');
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
      'search_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _glClassMeta =
      const VerificationMeta('glClass');
  @override
  late final GeneratedColumn<String> glClass = GeneratedColumn<String>(
      'gl_class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
      'uom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commodityGroupMeta =
      const VerificationMeta('commodityGroup');
  @override
  late final GeneratedColumn<String> commodityGroup = GeneratedColumn<String>(
      'commodity_group', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _extSearchTextMeta =
      const VerificationMeta('extSearchText');
  @override
  late final GeneratedColumn<String> extSearchText = GeneratedColumn<String>(
      'ext_search_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _extDescriptionMeta =
      const VerificationMeta('extDescription');
  @override
  late final GeneratedColumn<String> extDescription = GeneratedColumn<String>(
      'ext_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        itemnum,
        description,
        details,
        changedDate,
        searchText,
        glClass,
        uom,
        commodityGroup,
        extSearchText,
        extDescription
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itemCache';
  @override
  VerificationContext validateIntegrity(Insertable<ItemCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('itemnum')) {
      context.handle(_itemnumMeta,
          itemnum.isAcceptableOrUnknown(data['itemnum']!, _itemnumMeta));
    } else if (isInserting) {
      context.missing(_itemnumMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    } else if (isInserting) {
      context.missing(_detailsMeta);
    }
    if (data.containsKey('changed_date')) {
      context.handle(
          _changedDateMeta,
          changedDate.isAcceptableOrUnknown(
              data['changed_date']!, _changedDateMeta));
    } else if (isInserting) {
      context.missing(_changedDateMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
          _searchTextMeta,
          searchText.isAcceptableOrUnknown(
              data['search_text']!, _searchTextMeta));
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    if (data.containsKey('gl_class')) {
      context.handle(_glClassMeta,
          glClass.isAcceptableOrUnknown(data['gl_class']!, _glClassMeta));
    } else if (isInserting) {
      context.missing(_glClassMeta);
    }
    if (data.containsKey('uom')) {
      context.handle(
          _uomMeta, uom.isAcceptableOrUnknown(data['uom']!, _uomMeta));
    } else if (isInserting) {
      context.missing(_uomMeta);
    }
    if (data.containsKey('commodity_group')) {
      context.handle(
          _commodityGroupMeta,
          commodityGroup.isAcceptableOrUnknown(
              data['commodity_group']!, _commodityGroupMeta));
    } else if (isInserting) {
      context.missing(_commodityGroupMeta);
    }
    if (data.containsKey('ext_search_text')) {
      context.handle(
          _extSearchTextMeta,
          extSearchText.isAcceptableOrUnknown(
              data['ext_search_text']!, _extSearchTextMeta));
    } else if (isInserting) {
      context.missing(_extSearchTextMeta);
    }
    if (data.containsKey('ext_description')) {
      context.handle(
          _extDescriptionMeta,
          extDescription.isAcceptableOrUnknown(
              data['ext_description']!, _extDescriptionMeta));
    } else if (isInserting) {
      context.missing(_extDescriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemnum};
  @override
  ItemCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemCache(
      itemnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}itemnum'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details'])!,
      changedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changed_date'])!,
      searchText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_text'])!,
      glClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gl_class'])!,
      uom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uom'])!,
      commodityGroup: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}commodity_group'])!,
      extSearchText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ext_search_text'])!,
      extDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ext_description'])!,
    );
  }

  @override
  $ItemCachesTable createAlias(String alias) {
    return $ItemCachesTable(attachedDatabase, alias);
  }
}

class ItemCache extends DataClass implements Insertable<ItemCache> {
  final String itemnum;
  final String description;
  final String details;
  final String changedDate;
  final String searchText;
  final String glClass;
  final String uom;
  final String commodityGroup;
  final String extSearchText;
  final String extDescription;
  const ItemCache(
      {required this.itemnum,
      required this.description,
      required this.details,
      required this.changedDate,
      required this.searchText,
      required this.glClass,
      required this.uom,
      required this.commodityGroup,
      required this.extSearchText,
      required this.extDescription});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['itemnum'] = Variable<String>(itemnum);
    map['description'] = Variable<String>(description);
    map['details'] = Variable<String>(details);
    map['changed_date'] = Variable<String>(changedDate);
    map['search_text'] = Variable<String>(searchText);
    map['gl_class'] = Variable<String>(glClass);
    map['uom'] = Variable<String>(uom);
    map['commodity_group'] = Variable<String>(commodityGroup);
    map['ext_search_text'] = Variable<String>(extSearchText);
    map['ext_description'] = Variable<String>(extDescription);
    return map;
  }

  ItemCachesCompanion toCompanion(bool nullToAbsent) {
    return ItemCachesCompanion(
      itemnum: Value(itemnum),
      description: Value(description),
      details: Value(details),
      changedDate: Value(changedDate),
      searchText: Value(searchText),
      glClass: Value(glClass),
      uom: Value(uom),
      commodityGroup: Value(commodityGroup),
      extSearchText: Value(extSearchText),
      extDescription: Value(extDescription),
    );
  }

  factory ItemCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemCache(
      itemnum: serializer.fromJson<String>(json['itemnum']),
      description: serializer.fromJson<String>(json['description']),
      details: serializer.fromJson<String>(json['details']),
      changedDate: serializer.fromJson<String>(json['changedDate']),
      searchText: serializer.fromJson<String>(json['searchText']),
      glClass: serializer.fromJson<String>(json['glClass']),
      uom: serializer.fromJson<String>(json['uom']),
      commodityGroup: serializer.fromJson<String>(json['commodityGroup']),
      extSearchText: serializer.fromJson<String>(json['extSearchText']),
      extDescription: serializer.fromJson<String>(json['extDescription']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemnum': serializer.toJson<String>(itemnum),
      'description': serializer.toJson<String>(description),
      'details': serializer.toJson<String>(details),
      'changedDate': serializer.toJson<String>(changedDate),
      'searchText': serializer.toJson<String>(searchText),
      'glClass': serializer.toJson<String>(glClass),
      'uom': serializer.toJson<String>(uom),
      'commodityGroup': serializer.toJson<String>(commodityGroup),
      'extSearchText': serializer.toJson<String>(extSearchText),
      'extDescription': serializer.toJson<String>(extDescription),
    };
  }

  ItemCache copyWith(
          {String? itemnum,
          String? description,
          String? details,
          String? changedDate,
          String? searchText,
          String? glClass,
          String? uom,
          String? commodityGroup,
          String? extSearchText,
          String? extDescription}) =>
      ItemCache(
        itemnum: itemnum ?? this.itemnum,
        description: description ?? this.description,
        details: details ?? this.details,
        changedDate: changedDate ?? this.changedDate,
        searchText: searchText ?? this.searchText,
        glClass: glClass ?? this.glClass,
        uom: uom ?? this.uom,
        commodityGroup: commodityGroup ?? this.commodityGroup,
        extSearchText: extSearchText ?? this.extSearchText,
        extDescription: extDescription ?? this.extDescription,
      );
  ItemCache copyWithCompanion(ItemCachesCompanion data) {
    return ItemCache(
      itemnum: data.itemnum.present ? data.itemnum.value : this.itemnum,
      description:
          data.description.present ? data.description.value : this.description,
      details: data.details.present ? data.details.value : this.details,
      changedDate:
          data.changedDate.present ? data.changedDate.value : this.changedDate,
      searchText:
          data.searchText.present ? data.searchText.value : this.searchText,
      glClass: data.glClass.present ? data.glClass.value : this.glClass,
      uom: data.uom.present ? data.uom.value : this.uom,
      commodityGroup: data.commodityGroup.present
          ? data.commodityGroup.value
          : this.commodityGroup,
      extSearchText: data.extSearchText.present
          ? data.extSearchText.value
          : this.extSearchText,
      extDescription: data.extDescription.present
          ? data.extDescription.value
          : this.extDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemCache(')
          ..write('itemnum: $itemnum, ')
          ..write('description: $description, ')
          ..write('details: $details, ')
          ..write('changedDate: $changedDate, ')
          ..write('searchText: $searchText, ')
          ..write('glClass: $glClass, ')
          ..write('uom: $uom, ')
          ..write('commodityGroup: $commodityGroup, ')
          ..write('extSearchText: $extSearchText, ')
          ..write('extDescription: $extDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemnum, description, details, changedDate,
      searchText, glClass, uom, commodityGroup, extSearchText, extDescription);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemCache &&
          other.itemnum == this.itemnum &&
          other.description == this.description &&
          other.details == this.details &&
          other.changedDate == this.changedDate &&
          other.searchText == this.searchText &&
          other.glClass == this.glClass &&
          other.uom == this.uom &&
          other.commodityGroup == this.commodityGroup &&
          other.extSearchText == this.extSearchText &&
          other.extDescription == this.extDescription);
}

class ItemCachesCompanion extends UpdateCompanion<ItemCache> {
  final Value<String> itemnum;
  final Value<String> description;
  final Value<String> details;
  final Value<String> changedDate;
  final Value<String> searchText;
  final Value<String> glClass;
  final Value<String> uom;
  final Value<String> commodityGroup;
  final Value<String> extSearchText;
  final Value<String> extDescription;
  final Value<int> rowid;
  const ItemCachesCompanion({
    this.itemnum = const Value.absent(),
    this.description = const Value.absent(),
    this.details = const Value.absent(),
    this.changedDate = const Value.absent(),
    this.searchText = const Value.absent(),
    this.glClass = const Value.absent(),
    this.uom = const Value.absent(),
    this.commodityGroup = const Value.absent(),
    this.extSearchText = const Value.absent(),
    this.extDescription = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemCachesCompanion.insert({
    required String itemnum,
    required String description,
    required String details,
    required String changedDate,
    required String searchText,
    required String glClass,
    required String uom,
    required String commodityGroup,
    required String extSearchText,
    required String extDescription,
    this.rowid = const Value.absent(),
  })  : itemnum = Value(itemnum),
        description = Value(description),
        details = Value(details),
        changedDate = Value(changedDate),
        searchText = Value(searchText),
        glClass = Value(glClass),
        uom = Value(uom),
        commodityGroup = Value(commodityGroup),
        extSearchText = Value(extSearchText),
        extDescription = Value(extDescription);
  static Insertable<ItemCache> custom({
    Expression<String>? itemnum,
    Expression<String>? description,
    Expression<String>? details,
    Expression<String>? changedDate,
    Expression<String>? searchText,
    Expression<String>? glClass,
    Expression<String>? uom,
    Expression<String>? commodityGroup,
    Expression<String>? extSearchText,
    Expression<String>? extDescription,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemnum != null) 'itemnum': itemnum,
      if (description != null) 'description': description,
      if (details != null) 'details': details,
      if (changedDate != null) 'changed_date': changedDate,
      if (searchText != null) 'search_text': searchText,
      if (glClass != null) 'gl_class': glClass,
      if (uom != null) 'uom': uom,
      if (commodityGroup != null) 'commodity_group': commodityGroup,
      if (extSearchText != null) 'ext_search_text': extSearchText,
      if (extDescription != null) 'ext_description': extDescription,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemCachesCompanion copyWith(
      {Value<String>? itemnum,
      Value<String>? description,
      Value<String>? details,
      Value<String>? changedDate,
      Value<String>? searchText,
      Value<String>? glClass,
      Value<String>? uom,
      Value<String>? commodityGroup,
      Value<String>? extSearchText,
      Value<String>? extDescription,
      Value<int>? rowid}) {
    return ItemCachesCompanion(
      itemnum: itemnum ?? this.itemnum,
      description: description ?? this.description,
      details: details ?? this.details,
      changedDate: changedDate ?? this.changedDate,
      searchText: searchText ?? this.searchText,
      glClass: glClass ?? this.glClass,
      uom: uom ?? this.uom,
      commodityGroup: commodityGroup ?? this.commodityGroup,
      extSearchText: extSearchText ?? this.extSearchText,
      extDescription: extDescription ?? this.extDescription,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemnum.present) {
      map['itemnum'] = Variable<String>(itemnum.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (changedDate.present) {
      map['changed_date'] = Variable<String>(changedDate.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (glClass.present) {
      map['gl_class'] = Variable<String>(glClass.value);
    }
    if (uom.present) {
      map['uom'] = Variable<String>(uom.value);
    }
    if (commodityGroup.present) {
      map['commodity_group'] = Variable<String>(commodityGroup.value);
    }
    if (extSearchText.present) {
      map['ext_search_text'] = Variable<String>(extSearchText.value);
    }
    if (extDescription.present) {
      map['ext_description'] = Variable<String>(extDescription.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemCachesCompanion(')
          ..write('itemnum: $itemnum, ')
          ..write('description: $description, ')
          ..write('details: $details, ')
          ..write('changedDate: $changedDate, ')
          ..write('searchText: $searchText, ')
          ..write('glClass: $glClass, ')
          ..write('uom: $uom, ')
          ..write('commodityGroup: $commodityGroup, ')
          ..write('extSearchText: $extSearchText, ')
          ..write('extDescription: $extDescription, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ItemDatabase extends GeneratedDatabase {
  _$ItemDatabase(QueryExecutor e) : super(e);
  $ItemDatabaseManager get managers => $ItemDatabaseManager(this);
  late final $ItemCachesTable itemCaches = $ItemCachesTable(this);
  Selectable<String> findItems(String search) {
    return customSelect(
        'SELECT itemnum FROM itemCache WHERE search_text LIKE ?1',
        variables: [
          Variable<String>(search)
        ],
        readsFrom: {
          itemCaches,
        }).map((QueryRow row) => row.read<String>('itemnum'));
  }

  Selectable<String> findItemsExt(String search) {
    return customSelect(
        'SELECT itemnum FROM itemCache WHERE ext_search_text LIKE ?1',
        variables: [
          Variable<String>(search)
        ],
        readsFrom: {
          itemCaches,
        }).map((QueryRow row) => row.read<String>('itemnum'));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [itemCaches];
}

typedef $$ItemCachesTableCreateCompanionBuilder = ItemCachesCompanion Function({
  required String itemnum,
  required String description,
  required String details,
  required String changedDate,
  required String searchText,
  required String glClass,
  required String uom,
  required String commodityGroup,
  required String extSearchText,
  required String extDescription,
  Value<int> rowid,
});
typedef $$ItemCachesTableUpdateCompanionBuilder = ItemCachesCompanion Function({
  Value<String> itemnum,
  Value<String> description,
  Value<String> details,
  Value<String> changedDate,
  Value<String> searchText,
  Value<String> glClass,
  Value<String> uom,
  Value<String> commodityGroup,
  Value<String> extSearchText,
  Value<String> extDescription,
  Value<int> rowid,
});

class $$ItemCachesTableFilterComposer
    extends Composer<_$ItemDatabase, $ItemCachesTable> {
  $$ItemCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemnum => $composableBuilder(
      column: $table.itemnum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changedDate => $composableBuilder(
      column: $table.changedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchText => $composableBuilder(
      column: $table.searchText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get glClass => $composableBuilder(
      column: $table.glClass, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uom => $composableBuilder(
      column: $table.uom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commodityGroup => $composableBuilder(
      column: $table.commodityGroup,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extSearchText => $composableBuilder(
      column: $table.extSearchText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extDescription => $composableBuilder(
      column: $table.extDescription,
      builder: (column) => ColumnFilters(column));
}

class $$ItemCachesTableOrderingComposer
    extends Composer<_$ItemDatabase, $ItemCachesTable> {
  $$ItemCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemnum => $composableBuilder(
      column: $table.itemnum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changedDate => $composableBuilder(
      column: $table.changedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchText => $composableBuilder(
      column: $table.searchText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get glClass => $composableBuilder(
      column: $table.glClass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uom => $composableBuilder(
      column: $table.uom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commodityGroup => $composableBuilder(
      column: $table.commodityGroup,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extSearchText => $composableBuilder(
      column: $table.extSearchText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extDescription => $composableBuilder(
      column: $table.extDescription,
      builder: (column) => ColumnOrderings(column));
}

class $$ItemCachesTableAnnotationComposer
    extends Composer<_$ItemDatabase, $ItemCachesTable> {
  $$ItemCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemnum =>
      $composableBuilder(column: $table.itemnum, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get changedDate => $composableBuilder(
      column: $table.changedDate, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
      column: $table.searchText, builder: (column) => column);

  GeneratedColumn<String> get glClass =>
      $composableBuilder(column: $table.glClass, builder: (column) => column);

  GeneratedColumn<String> get uom =>
      $composableBuilder(column: $table.uom, builder: (column) => column);

  GeneratedColumn<String> get commodityGroup => $composableBuilder(
      column: $table.commodityGroup, builder: (column) => column);

  GeneratedColumn<String> get extSearchText => $composableBuilder(
      column: $table.extSearchText, builder: (column) => column);

  GeneratedColumn<String> get extDescription => $composableBuilder(
      column: $table.extDescription, builder: (column) => column);
}

class $$ItemCachesTableTableManager extends RootTableManager<
    _$ItemDatabase,
    $ItemCachesTable,
    ItemCache,
    $$ItemCachesTableFilterComposer,
    $$ItemCachesTableOrderingComposer,
    $$ItemCachesTableAnnotationComposer,
    $$ItemCachesTableCreateCompanionBuilder,
    $$ItemCachesTableUpdateCompanionBuilder,
    (ItemCache, BaseReferences<_$ItemDatabase, $ItemCachesTable, ItemCache>),
    ItemCache,
    PrefetchHooks Function()> {
  $$ItemCachesTableTableManager(_$ItemDatabase db, $ItemCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemnum = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> details = const Value.absent(),
            Value<String> changedDate = const Value.absent(),
            Value<String> searchText = const Value.absent(),
            Value<String> glClass = const Value.absent(),
            Value<String> uom = const Value.absent(),
            Value<String> commodityGroup = const Value.absent(),
            Value<String> extSearchText = const Value.absent(),
            Value<String> extDescription = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemCachesCompanion(
            itemnum: itemnum,
            description: description,
            details: details,
            changedDate: changedDate,
            searchText: searchText,
            glClass: glClass,
            uom: uom,
            commodityGroup: commodityGroup,
            extSearchText: extSearchText,
            extDescription: extDescription,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemnum,
            required String description,
            required String details,
            required String changedDate,
            required String searchText,
            required String glClass,
            required String uom,
            required String commodityGroup,
            required String extSearchText,
            required String extDescription,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemCachesCompanion.insert(
            itemnum: itemnum,
            description: description,
            details: details,
            changedDate: changedDate,
            searchText: searchText,
            glClass: glClass,
            uom: uom,
            commodityGroup: commodityGroup,
            extSearchText: extSearchText,
            extDescription: extDescription,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemCachesTableProcessedTableManager = ProcessedTableManager<
    _$ItemDatabase,
    $ItemCachesTable,
    ItemCache,
    $$ItemCachesTableFilterComposer,
    $$ItemCachesTableOrderingComposer,
    $$ItemCachesTableAnnotationComposer,
    $$ItemCachesTableCreateCompanionBuilder,
    $$ItemCachesTableUpdateCompanionBuilder,
    (ItemCache, BaseReferences<_$ItemDatabase, $ItemCachesTable, ItemCache>),
    ItemCache,
    PrefetchHooks Function()>;

class $ItemDatabaseManager {
  final _$ItemDatabase _db;
  $ItemDatabaseManager(this._db);
  $$ItemCachesTableTableManager get itemCaches =>
      $$ItemCachesTableTableManager(_db, _db.itemCaches);
}
