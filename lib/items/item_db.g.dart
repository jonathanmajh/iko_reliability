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
      'details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _changedDateMeta =
      const VerificationMeta('changedDate');
  @override
  late final GeneratedColumn<String> changedDate = GeneratedColumn<String>(
      'changed_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _searchTextMeta =
      const VerificationMeta('searchText');
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
      'search_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _glClassMeta =
      const VerificationMeta('glClass');
  @override
  late final GeneratedColumn<String> glClass = GeneratedColumn<String>(
      'gl_class', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
      'uom', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commodityGroupMeta =
      const VerificationMeta('commodityGroup');
  @override
  late final GeneratedColumn<String> commodityGroup = GeneratedColumn<String>(
      'commodity_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extSearchTextMeta =
      const VerificationMeta('extSearchText');
  @override
  late final GeneratedColumn<String> extSearchText = GeneratedColumn<String>(
      'ext_search_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extDescriptionMeta =
      const VerificationMeta('extDescription');
  @override
  late final GeneratedColumn<String> extDescription = GeneratedColumn<String>(
      'ext_description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
    }
    if (data.containsKey('changed_date')) {
      context.handle(
          _changedDateMeta,
          changedDate.isAcceptableOrUnknown(
              data['changed_date']!, _changedDateMeta));
    }
    if (data.containsKey('search_text')) {
      context.handle(
          _searchTextMeta,
          searchText.isAcceptableOrUnknown(
              data['search_text']!, _searchTextMeta));
    }
    if (data.containsKey('gl_class')) {
      context.handle(_glClassMeta,
          glClass.isAcceptableOrUnknown(data['gl_class']!, _glClassMeta));
    }
    if (data.containsKey('uom')) {
      context.handle(
          _uomMeta, uom.isAcceptableOrUnknown(data['uom']!, _uomMeta));
    }
    if (data.containsKey('commodity_group')) {
      context.handle(
          _commodityGroupMeta,
          commodityGroup.isAcceptableOrUnknown(
              data['commodity_group']!, _commodityGroupMeta));
    }
    if (data.containsKey('ext_search_text')) {
      context.handle(
          _extSearchTextMeta,
          extSearchText.isAcceptableOrUnknown(
              data['ext_search_text']!, _extSearchTextMeta));
    }
    if (data.containsKey('ext_description')) {
      context.handle(
          _extDescriptionMeta,
          extDescription.isAcceptableOrUnknown(
              data['ext_description']!, _extDescriptionMeta));
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
          .read(DriftSqlType.string, data['${effectivePrefix}details']),
      changedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changed_date']),
      searchText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_text']),
      glClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gl_class']),
      uom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uom']),
      commodityGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commodity_group']),
      extSearchText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ext_search_text']),
      extDescription: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ext_description']),
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
  final String? details;
  final String? changedDate;
  final String? searchText;
  final String? glClass;
  final String? uom;
  final String? commodityGroup;
  final String? extSearchText;
  final String? extDescription;
  const ItemCache(
      {required this.itemnum,
      required this.description,
      this.details,
      this.changedDate,
      this.searchText,
      this.glClass,
      this.uom,
      this.commodityGroup,
      this.extSearchText,
      this.extDescription});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['itemnum'] = Variable<String>(itemnum);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || changedDate != null) {
      map['changed_date'] = Variable<String>(changedDate);
    }
    if (!nullToAbsent || searchText != null) {
      map['search_text'] = Variable<String>(searchText);
    }
    if (!nullToAbsent || glClass != null) {
      map['gl_class'] = Variable<String>(glClass);
    }
    if (!nullToAbsent || uom != null) {
      map['uom'] = Variable<String>(uom);
    }
    if (!nullToAbsent || commodityGroup != null) {
      map['commodity_group'] = Variable<String>(commodityGroup);
    }
    if (!nullToAbsent || extSearchText != null) {
      map['ext_search_text'] = Variable<String>(extSearchText);
    }
    if (!nullToAbsent || extDescription != null) {
      map['ext_description'] = Variable<String>(extDescription);
    }
    return map;
  }

  ItemCachesCompanion toCompanion(bool nullToAbsent) {
    return ItemCachesCompanion(
      itemnum: Value(itemnum),
      description: Value(description),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      changedDate: changedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(changedDate),
      searchText: searchText == null && nullToAbsent
          ? const Value.absent()
          : Value(searchText),
      glClass: glClass == null && nullToAbsent
          ? const Value.absent()
          : Value(glClass),
      uom: uom == null && nullToAbsent ? const Value.absent() : Value(uom),
      commodityGroup: commodityGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(commodityGroup),
      extSearchText: extSearchText == null && nullToAbsent
          ? const Value.absent()
          : Value(extSearchText),
      extDescription: extDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(extDescription),
    );
  }

  factory ItemCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemCache(
      itemnum: serializer.fromJson<String>(json['itemnum']),
      description: serializer.fromJson<String>(json['description']),
      details: serializer.fromJson<String?>(json['details']),
      changedDate: serializer.fromJson<String?>(json['changedDate']),
      searchText: serializer.fromJson<String?>(json['searchText']),
      glClass: serializer.fromJson<String?>(json['glClass']),
      uom: serializer.fromJson<String?>(json['uom']),
      commodityGroup: serializer.fromJson<String?>(json['commodityGroup']),
      extSearchText: serializer.fromJson<String?>(json['extSearchText']),
      extDescription: serializer.fromJson<String?>(json['extDescription']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemnum': serializer.toJson<String>(itemnum),
      'description': serializer.toJson<String>(description),
      'details': serializer.toJson<String?>(details),
      'changedDate': serializer.toJson<String?>(changedDate),
      'searchText': serializer.toJson<String?>(searchText),
      'glClass': serializer.toJson<String?>(glClass),
      'uom': serializer.toJson<String?>(uom),
      'commodityGroup': serializer.toJson<String?>(commodityGroup),
      'extSearchText': serializer.toJson<String?>(extSearchText),
      'extDescription': serializer.toJson<String?>(extDescription),
    };
  }

  ItemCache copyWith(
          {String? itemnum,
          String? description,
          Value<String?> details = const Value.absent(),
          Value<String?> changedDate = const Value.absent(),
          Value<String?> searchText = const Value.absent(),
          Value<String?> glClass = const Value.absent(),
          Value<String?> uom = const Value.absent(),
          Value<String?> commodityGroup = const Value.absent(),
          Value<String?> extSearchText = const Value.absent(),
          Value<String?> extDescription = const Value.absent()}) =>
      ItemCache(
        itemnum: itemnum ?? this.itemnum,
        description: description ?? this.description,
        details: details.present ? details.value : this.details,
        changedDate: changedDate.present ? changedDate.value : this.changedDate,
        searchText: searchText.present ? searchText.value : this.searchText,
        glClass: glClass.present ? glClass.value : this.glClass,
        uom: uom.present ? uom.value : this.uom,
        commodityGroup:
            commodityGroup.present ? commodityGroup.value : this.commodityGroup,
        extSearchText:
            extSearchText.present ? extSearchText.value : this.extSearchText,
        extDescription:
            extDescription.present ? extDescription.value : this.extDescription,
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
  final Value<String?> details;
  final Value<String?> changedDate;
  final Value<String?> searchText;
  final Value<String?> glClass;
  final Value<String?> uom;
  final Value<String?> commodityGroup;
  final Value<String?> extSearchText;
  final Value<String?> extDescription;
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
    this.details = const Value.absent(),
    this.changedDate = const Value.absent(),
    this.searchText = const Value.absent(),
    this.glClass = const Value.absent(),
    this.uom = const Value.absent(),
    this.commodityGroup = const Value.absent(),
    this.extSearchText = const Value.absent(),
    this.extDescription = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemnum = Value(itemnum),
        description = Value(description);
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
      Value<String?>? details,
      Value<String?>? changedDate,
      Value<String?>? searchText,
      Value<String?>? glClass,
      Value<String?>? uom,
      Value<String?>? commodityGroup,
      Value<String?>? extSearchText,
      Value<String?>? extDescription,
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

class $InventoryCachesTable extends InventoryCaches
    with TableInfo<$InventoryCachesTable, InventoryCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemnumMeta =
      const VerificationMeta('itemnum');
  @override
  late final GeneratedColumn<String> itemnum = GeneratedColumn<String>(
      'itemnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catalogcodeMeta =
      const VerificationMeta('catalogcode');
  @override
  late final GeneratedColumn<String> catalogcode = GeneratedColumn<String>(
      'catalogcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelnumMeta =
      const VerificationMeta('modelnum');
  @override
  late final GeneratedColumn<String> modelnum = GeneratedColumn<String>(
      'modelnum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vendorMeta = const VerificationMeta('vendor');
  @override
  late final GeneratedColumn<String> vendor = GeneratedColumn<String>(
      'vendor', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _companynameMeta =
      const VerificationMeta('companyname');
  @override
  late final GeneratedColumn<String> companyname = GeneratedColumn<String>(
      'companyname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rowstampMeta =
      const VerificationMeta('rowstamp');
  @override
  late final GeneratedColumn<String> rowstamp = GeneratedColumn<String>(
      'rowstamp', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _binnumMeta = const VerificationMeta('binnum');
  @override
  late final GeneratedColumn<String> binnum = GeneratedColumn<String>(
      'binnum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        itemnum,
        siteid,
        catalogcode,
        modelnum,
        vendor,
        manufacturer,
        companyname,
        rowstamp,
        location,
        binnum
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventoryCache';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('itemnum')) {
      context.handle(_itemnumMeta,
          itemnum.isAcceptableOrUnknown(data['itemnum']!, _itemnumMeta));
    } else if (isInserting) {
      context.missing(_itemnumMeta);
    }
    if (data.containsKey('siteid')) {
      context.handle(_siteidMeta,
          siteid.isAcceptableOrUnknown(data['siteid']!, _siteidMeta));
    } else if (isInserting) {
      context.missing(_siteidMeta);
    }
    if (data.containsKey('catalogcode')) {
      context.handle(
          _catalogcodeMeta,
          catalogcode.isAcceptableOrUnknown(
              data['catalogcode']!, _catalogcodeMeta));
    }
    if (data.containsKey('modelnum')) {
      context.handle(_modelnumMeta,
          modelnum.isAcceptableOrUnknown(data['modelnum']!, _modelnumMeta));
    }
    if (data.containsKey('vendor')) {
      context.handle(_vendorMeta,
          vendor.isAcceptableOrUnknown(data['vendor']!, _vendorMeta));
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    }
    if (data.containsKey('companyname')) {
      context.handle(
          _companynameMeta,
          companyname.isAcceptableOrUnknown(
              data['companyname']!, _companynameMeta));
    }
    if (data.containsKey('rowstamp')) {
      context.handle(_rowstampMeta,
          rowstamp.isAcceptableOrUnknown(data['rowstamp']!, _rowstampMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('binnum')) {
      context.handle(_binnumMeta,
          binnum.isAcceptableOrUnknown(data['binnum']!, _binnumMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemnum, location};
  @override
  InventoryCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryCache(
      itemnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}itemnum'])!,
      siteid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteid'])!,
      catalogcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalogcode']),
      modelnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modelnum']),
      vendor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor']),
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer']),
      companyname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}companyname']),
      rowstamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rowstamp']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      binnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}binnum']),
    );
  }

  @override
  $InventoryCachesTable createAlias(String alias) {
    return $InventoryCachesTable(attachedDatabase, alias);
  }
}

class InventoryCache extends DataClass implements Insertable<InventoryCache> {
  final String itemnum;
  final String siteid;
  final String? catalogcode;
  final String? modelnum;
  final String? vendor;
  final String? manufacturer;
  final String? companyname;
  final String? rowstamp;
  final String location;
  final String? binnum;
  const InventoryCache(
      {required this.itemnum,
      required this.siteid,
      this.catalogcode,
      this.modelnum,
      this.vendor,
      this.manufacturer,
      this.companyname,
      this.rowstamp,
      required this.location,
      this.binnum});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['itemnum'] = Variable<String>(itemnum);
    map['siteid'] = Variable<String>(siteid);
    if (!nullToAbsent || catalogcode != null) {
      map['catalogcode'] = Variable<String>(catalogcode);
    }
    if (!nullToAbsent || modelnum != null) {
      map['modelnum'] = Variable<String>(modelnum);
    }
    if (!nullToAbsent || vendor != null) {
      map['vendor'] = Variable<String>(vendor);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || companyname != null) {
      map['companyname'] = Variable<String>(companyname);
    }
    if (!nullToAbsent || rowstamp != null) {
      map['rowstamp'] = Variable<String>(rowstamp);
    }
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || binnum != null) {
      map['binnum'] = Variable<String>(binnum);
    }
    return map;
  }

  InventoryCachesCompanion toCompanion(bool nullToAbsent) {
    return InventoryCachesCompanion(
      itemnum: Value(itemnum),
      siteid: Value(siteid),
      catalogcode: catalogcode == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogcode),
      modelnum: modelnum == null && nullToAbsent
          ? const Value.absent()
          : Value(modelnum),
      vendor:
          vendor == null && nullToAbsent ? const Value.absent() : Value(vendor),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      companyname: companyname == null && nullToAbsent
          ? const Value.absent()
          : Value(companyname),
      rowstamp: rowstamp == null && nullToAbsent
          ? const Value.absent()
          : Value(rowstamp),
      location: Value(location),
      binnum:
          binnum == null && nullToAbsent ? const Value.absent() : Value(binnum),
    );
  }

  factory InventoryCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryCache(
      itemnum: serializer.fromJson<String>(json['itemnum']),
      siteid: serializer.fromJson<String>(json['siteid']),
      catalogcode: serializer.fromJson<String?>(json['catalogcode']),
      modelnum: serializer.fromJson<String?>(json['modelnum']),
      vendor: serializer.fromJson<String?>(json['vendor']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      companyname: serializer.fromJson<String?>(json['companyname']),
      rowstamp: serializer.fromJson<String?>(json['rowstamp']),
      location: serializer.fromJson<String>(json['location']),
      binnum: serializer.fromJson<String?>(json['binnum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemnum': serializer.toJson<String>(itemnum),
      'siteid': serializer.toJson<String>(siteid),
      'catalogcode': serializer.toJson<String?>(catalogcode),
      'modelnum': serializer.toJson<String?>(modelnum),
      'vendor': serializer.toJson<String?>(vendor),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'companyname': serializer.toJson<String?>(companyname),
      'rowstamp': serializer.toJson<String?>(rowstamp),
      'location': serializer.toJson<String>(location),
      'binnum': serializer.toJson<String?>(binnum),
    };
  }

  InventoryCache copyWith(
          {String? itemnum,
          String? siteid,
          Value<String?> catalogcode = const Value.absent(),
          Value<String?> modelnum = const Value.absent(),
          Value<String?> vendor = const Value.absent(),
          Value<String?> manufacturer = const Value.absent(),
          Value<String?> companyname = const Value.absent(),
          Value<String?> rowstamp = const Value.absent(),
          String? location,
          Value<String?> binnum = const Value.absent()}) =>
      InventoryCache(
        itemnum: itemnum ?? this.itemnum,
        siteid: siteid ?? this.siteid,
        catalogcode: catalogcode.present ? catalogcode.value : this.catalogcode,
        modelnum: modelnum.present ? modelnum.value : this.modelnum,
        vendor: vendor.present ? vendor.value : this.vendor,
        manufacturer:
            manufacturer.present ? manufacturer.value : this.manufacturer,
        companyname: companyname.present ? companyname.value : this.companyname,
        rowstamp: rowstamp.present ? rowstamp.value : this.rowstamp,
        location: location ?? this.location,
        binnum: binnum.present ? binnum.value : this.binnum,
      );
  InventoryCache copyWithCompanion(InventoryCachesCompanion data) {
    return InventoryCache(
      itemnum: data.itemnum.present ? data.itemnum.value : this.itemnum,
      siteid: data.siteid.present ? data.siteid.value : this.siteid,
      catalogcode:
          data.catalogcode.present ? data.catalogcode.value : this.catalogcode,
      modelnum: data.modelnum.present ? data.modelnum.value : this.modelnum,
      vendor: data.vendor.present ? data.vendor.value : this.vendor,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      companyname:
          data.companyname.present ? data.companyname.value : this.companyname,
      rowstamp: data.rowstamp.present ? data.rowstamp.value : this.rowstamp,
      location: data.location.present ? data.location.value : this.location,
      binnum: data.binnum.present ? data.binnum.value : this.binnum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCache(')
          ..write('itemnum: $itemnum, ')
          ..write('siteid: $siteid, ')
          ..write('catalogcode: $catalogcode, ')
          ..write('modelnum: $modelnum, ')
          ..write('vendor: $vendor, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('companyname: $companyname, ')
          ..write('rowstamp: $rowstamp, ')
          ..write('location: $location, ')
          ..write('binnum: $binnum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemnum, siteid, catalogcode, modelnum,
      vendor, manufacturer, companyname, rowstamp, location, binnum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryCache &&
          other.itemnum == this.itemnum &&
          other.siteid == this.siteid &&
          other.catalogcode == this.catalogcode &&
          other.modelnum == this.modelnum &&
          other.vendor == this.vendor &&
          other.manufacturer == this.manufacturer &&
          other.companyname == this.companyname &&
          other.rowstamp == this.rowstamp &&
          other.location == this.location &&
          other.binnum == this.binnum);
}

class InventoryCachesCompanion extends UpdateCompanion<InventoryCache> {
  final Value<String> itemnum;
  final Value<String> siteid;
  final Value<String?> catalogcode;
  final Value<String?> modelnum;
  final Value<String?> vendor;
  final Value<String?> manufacturer;
  final Value<String?> companyname;
  final Value<String?> rowstamp;
  final Value<String> location;
  final Value<String?> binnum;
  final Value<int> rowid;
  const InventoryCachesCompanion({
    this.itemnum = const Value.absent(),
    this.siteid = const Value.absent(),
    this.catalogcode = const Value.absent(),
    this.modelnum = const Value.absent(),
    this.vendor = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.companyname = const Value.absent(),
    this.rowstamp = const Value.absent(),
    this.location = const Value.absent(),
    this.binnum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCachesCompanion.insert({
    required String itemnum,
    required String siteid,
    this.catalogcode = const Value.absent(),
    this.modelnum = const Value.absent(),
    this.vendor = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.companyname = const Value.absent(),
    this.rowstamp = const Value.absent(),
    required String location,
    this.binnum = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemnum = Value(itemnum),
        siteid = Value(siteid),
        location = Value(location);
  static Insertable<InventoryCache> custom({
    Expression<String>? itemnum,
    Expression<String>? siteid,
    Expression<String>? catalogcode,
    Expression<String>? modelnum,
    Expression<String>? vendor,
    Expression<String>? manufacturer,
    Expression<String>? companyname,
    Expression<String>? rowstamp,
    Expression<String>? location,
    Expression<String>? binnum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemnum != null) 'itemnum': itemnum,
      if (siteid != null) 'siteid': siteid,
      if (catalogcode != null) 'catalogcode': catalogcode,
      if (modelnum != null) 'modelnum': modelnum,
      if (vendor != null) 'vendor': vendor,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (companyname != null) 'companyname': companyname,
      if (rowstamp != null) 'rowstamp': rowstamp,
      if (location != null) 'location': location,
      if (binnum != null) 'binnum': binnum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCachesCompanion copyWith(
      {Value<String>? itemnum,
      Value<String>? siteid,
      Value<String?>? catalogcode,
      Value<String?>? modelnum,
      Value<String?>? vendor,
      Value<String?>? manufacturer,
      Value<String?>? companyname,
      Value<String?>? rowstamp,
      Value<String>? location,
      Value<String?>? binnum,
      Value<int>? rowid}) {
    return InventoryCachesCompanion(
      itemnum: itemnum ?? this.itemnum,
      siteid: siteid ?? this.siteid,
      catalogcode: catalogcode ?? this.catalogcode,
      modelnum: modelnum ?? this.modelnum,
      vendor: vendor ?? this.vendor,
      manufacturer: manufacturer ?? this.manufacturer,
      companyname: companyname ?? this.companyname,
      rowstamp: rowstamp ?? this.rowstamp,
      location: location ?? this.location,
      binnum: binnum ?? this.binnum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemnum.present) {
      map['itemnum'] = Variable<String>(itemnum.value);
    }
    if (siteid.present) {
      map['siteid'] = Variable<String>(siteid.value);
    }
    if (catalogcode.present) {
      map['catalogcode'] = Variable<String>(catalogcode.value);
    }
    if (modelnum.present) {
      map['modelnum'] = Variable<String>(modelnum.value);
    }
    if (vendor.present) {
      map['vendor'] = Variable<String>(vendor.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (companyname.present) {
      map['companyname'] = Variable<String>(companyname.value);
    }
    if (rowstamp.present) {
      map['rowstamp'] = Variable<String>(rowstamp.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (binnum.present) {
      map['binnum'] = Variable<String>(binnum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCachesCompanion(')
          ..write('itemnum: $itemnum, ')
          ..write('siteid: $siteid, ')
          ..write('catalogcode: $catalogcode, ')
          ..write('modelnum: $modelnum, ')
          ..write('vendor: $vendor, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('companyname: $companyname, ')
          ..write('rowstamp: $rowstamp, ')
          ..write('location: $location, ')
          ..write('binnum: $binnum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManufacturersTable extends Manufacturers
    with TableInfo<$ManufacturersTable, Manufacturer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManufacturersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, fullName, shortName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manufacturers';
  @override
  VerificationContext validateIntegrity(Insertable<Manufacturer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Manufacturer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Manufacturer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name'])!,
    );
  }

  @override
  $ManufacturersTable createAlias(String alias) {
    return $ManufacturersTable(attachedDatabase, alias);
  }
}

class Manufacturer extends DataClass implements Insertable<Manufacturer> {
  final int id;
  final String fullName;
  final String shortName;
  const Manufacturer(
      {required this.id, required this.fullName, required this.shortName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['full_name'] = Variable<String>(fullName);
    map['short_name'] = Variable<String>(shortName);
    return map;
  }

  ManufacturersCompanion toCompanion(bool nullToAbsent) {
    return ManufacturersCompanion(
      id: Value(id),
      fullName: Value(fullName),
      shortName: Value(shortName),
    );
  }

  factory Manufacturer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Manufacturer(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      shortName: serializer.fromJson<String>(json['shortName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String>(fullName),
      'shortName': serializer.toJson<String>(shortName),
    };
  }

  Manufacturer copyWith({int? id, String? fullName, String? shortName}) =>
      Manufacturer(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        shortName: shortName ?? this.shortName,
      );
  Manufacturer copyWithCompanion(ManufacturersCompanion data) {
    return Manufacturer(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Manufacturer(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('shortName: $shortName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fullName, shortName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Manufacturer &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.shortName == this.shortName);
}

class ManufacturersCompanion extends UpdateCompanion<Manufacturer> {
  final Value<int> id;
  final Value<String> fullName;
  final Value<String> shortName;
  const ManufacturersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.shortName = const Value.absent(),
  });
  ManufacturersCompanion.insert({
    this.id = const Value.absent(),
    required String fullName,
    required String shortName,
  })  : fullName = Value(fullName),
        shortName = Value(shortName);
  static Insertable<Manufacturer> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? shortName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (shortName != null) 'short_name': shortName,
    });
  }

  ManufacturersCompanion copyWith(
      {Value<int>? id, Value<String>? fullName, Value<String>? shortName}) {
    return ManufacturersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      shortName: shortName ?? this.shortName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManufacturersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('shortName: $shortName')
          ..write(')'))
        .toString();
  }
}

class $AbbreviationsTable extends Abbreviations
    with TableInfo<$AbbreviationsTable, Abbreviation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbbreviationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _origTextMeta =
      const VerificationMeta('origText');
  @override
  late final GeneratedColumn<String> origText = GeneratedColumn<String>(
      'orig_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _replaceTextMeta =
      const VerificationMeta('replaceText');
  @override
  late final GeneratedColumn<String> replaceText = GeneratedColumn<String>(
      'replace_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, origText, replaceText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'abbreviations';
  @override
  VerificationContext validateIntegrity(Insertable<Abbreviation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('orig_text')) {
      context.handle(_origTextMeta,
          origText.isAcceptableOrUnknown(data['orig_text']!, _origTextMeta));
    } else if (isInserting) {
      context.missing(_origTextMeta);
    }
    if (data.containsKey('replace_text')) {
      context.handle(
          _replaceTextMeta,
          replaceText.isAcceptableOrUnknown(
              data['replace_text']!, _replaceTextMeta));
    } else if (isInserting) {
      context.missing(_replaceTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Abbreviation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Abbreviation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      origText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}orig_text'])!,
      replaceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}replace_text'])!,
    );
  }

  @override
  $AbbreviationsTable createAlias(String alias) {
    return $AbbreviationsTable(attachedDatabase, alias);
  }
}

class Abbreviation extends DataClass implements Insertable<Abbreviation> {
  final int id;
  final String origText;
  final String replaceText;
  const Abbreviation(
      {required this.id, required this.origText, required this.replaceText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['orig_text'] = Variable<String>(origText);
    map['replace_text'] = Variable<String>(replaceText);
    return map;
  }

  AbbreviationsCompanion toCompanion(bool nullToAbsent) {
    return AbbreviationsCompanion(
      id: Value(id),
      origText: Value(origText),
      replaceText: Value(replaceText),
    );
  }

  factory Abbreviation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Abbreviation(
      id: serializer.fromJson<int>(json['id']),
      origText: serializer.fromJson<String>(json['origText']),
      replaceText: serializer.fromJson<String>(json['replaceText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'origText': serializer.toJson<String>(origText),
      'replaceText': serializer.toJson<String>(replaceText),
    };
  }

  Abbreviation copyWith({int? id, String? origText, String? replaceText}) =>
      Abbreviation(
        id: id ?? this.id,
        origText: origText ?? this.origText,
        replaceText: replaceText ?? this.replaceText,
      );
  Abbreviation copyWithCompanion(AbbreviationsCompanion data) {
    return Abbreviation(
      id: data.id.present ? data.id.value : this.id,
      origText: data.origText.present ? data.origText.value : this.origText,
      replaceText:
          data.replaceText.present ? data.replaceText.value : this.replaceText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Abbreviation(')
          ..write('id: $id, ')
          ..write('origText: $origText, ')
          ..write('replaceText: $replaceText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, origText, replaceText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Abbreviation &&
          other.id == this.id &&
          other.origText == this.origText &&
          other.replaceText == this.replaceText);
}

class AbbreviationsCompanion extends UpdateCompanion<Abbreviation> {
  final Value<int> id;
  final Value<String> origText;
  final Value<String> replaceText;
  const AbbreviationsCompanion({
    this.id = const Value.absent(),
    this.origText = const Value.absent(),
    this.replaceText = const Value.absent(),
  });
  AbbreviationsCompanion.insert({
    this.id = const Value.absent(),
    required String origText,
    required String replaceText,
  })  : origText = Value(origText),
        replaceText = Value(replaceText);
  static Insertable<Abbreviation> custom({
    Expression<int>? id,
    Expression<String>? origText,
    Expression<String>? replaceText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origText != null) 'orig_text': origText,
      if (replaceText != null) 'replace_text': replaceText,
    });
  }

  AbbreviationsCompanion copyWith(
      {Value<int>? id, Value<String>? origText, Value<String>? replaceText}) {
    return AbbreviationsCompanion(
      id: id ?? this.id,
      origText: origText ?? this.origText,
      replaceText: replaceText ?? this.replaceText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (origText.present) {
      map['orig_text'] = Variable<String>(origText.value);
    }
    if (replaceText.present) {
      map['replace_text'] = Variable<String>(replaceText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbbreviationsCompanion(')
          ..write('id: $id, ')
          ..write('origText: $origText, ')
          ..write('replaceText: $replaceText')
          ..write(')'))
        .toString();
  }
}

abstract class _$ItemDatabase extends GeneratedDatabase {
  _$ItemDatabase(QueryExecutor e) : super(e);
  $ItemDatabaseManager get managers => $ItemDatabaseManager(this);
  late final $ItemCachesTable itemCaches = $ItemCachesTable(this);
  late final $InventoryCachesTable inventoryCaches =
      $InventoryCachesTable(this);
  late final $ManufacturersTable manufacturers = $ManufacturersTable(this);
  late final $AbbreviationsTable abbreviations = $AbbreviationsTable(this);
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

  Selectable<GetReplacementsResult> getReplacements() {
    return customSelect(
        'SELECT upper(orig_text) AS orig_text, upper(replace_text) AS replace_text FROM abbreviations UNION SELECT upper(full_name) AS orig_text, upper(short_name) AS replace_text FROM manufacturers',
        variables: [],
        readsFrom: {
          abbreviations,
          manufacturers,
        }).map((QueryRow row) => GetReplacementsResult(
          origText: row.read<String>('orig_text'),
          replaceText: row.read<String>('replace_text'),
        ));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [itemCaches, inventoryCaches, manufacturers, abbreviations];
}

typedef $$ItemCachesTableCreateCompanionBuilder = ItemCachesCompanion Function({
  required String itemnum,
  required String description,
  Value<String?> details,
  Value<String?> changedDate,
  Value<String?> searchText,
  Value<String?> glClass,
  Value<String?> uom,
  Value<String?> commodityGroup,
  Value<String?> extSearchText,
  Value<String?> extDescription,
  Value<int> rowid,
});
typedef $$ItemCachesTableUpdateCompanionBuilder = ItemCachesCompanion Function({
  Value<String> itemnum,
  Value<String> description,
  Value<String?> details,
  Value<String?> changedDate,
  Value<String?> searchText,
  Value<String?> glClass,
  Value<String?> uom,
  Value<String?> commodityGroup,
  Value<String?> extSearchText,
  Value<String?> extDescription,
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
            Value<String?> details = const Value.absent(),
            Value<String?> changedDate = const Value.absent(),
            Value<String?> searchText = const Value.absent(),
            Value<String?> glClass = const Value.absent(),
            Value<String?> uom = const Value.absent(),
            Value<String?> commodityGroup = const Value.absent(),
            Value<String?> extSearchText = const Value.absent(),
            Value<String?> extDescription = const Value.absent(),
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
            Value<String?> details = const Value.absent(),
            Value<String?> changedDate = const Value.absent(),
            Value<String?> searchText = const Value.absent(),
            Value<String?> glClass = const Value.absent(),
            Value<String?> uom = const Value.absent(),
            Value<String?> commodityGroup = const Value.absent(),
            Value<String?> extSearchText = const Value.absent(),
            Value<String?> extDescription = const Value.absent(),
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
typedef $$InventoryCachesTableCreateCompanionBuilder = InventoryCachesCompanion
    Function({
  required String itemnum,
  required String siteid,
  Value<String?> catalogcode,
  Value<String?> modelnum,
  Value<String?> vendor,
  Value<String?> manufacturer,
  Value<String?> companyname,
  Value<String?> rowstamp,
  required String location,
  Value<String?> binnum,
  Value<int> rowid,
});
typedef $$InventoryCachesTableUpdateCompanionBuilder = InventoryCachesCompanion
    Function({
  Value<String> itemnum,
  Value<String> siteid,
  Value<String?> catalogcode,
  Value<String?> modelnum,
  Value<String?> vendor,
  Value<String?> manufacturer,
  Value<String?> companyname,
  Value<String?> rowstamp,
  Value<String> location,
  Value<String?> binnum,
  Value<int> rowid,
});

class $$InventoryCachesTableFilterComposer
    extends Composer<_$ItemDatabase, $InventoryCachesTable> {
  $$InventoryCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemnum => $composableBuilder(
      column: $table.itemnum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get siteid => $composableBuilder(
      column: $table.siteid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogcode => $composableBuilder(
      column: $table.catalogcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelnum => $composableBuilder(
      column: $table.modelnum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendor => $composableBuilder(
      column: $table.vendor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyname => $composableBuilder(
      column: $table.companyname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rowstamp => $composableBuilder(
      column: $table.rowstamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get binnum => $composableBuilder(
      column: $table.binnum, builder: (column) => ColumnFilters(column));
}

class $$InventoryCachesTableOrderingComposer
    extends Composer<_$ItemDatabase, $InventoryCachesTable> {
  $$InventoryCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemnum => $composableBuilder(
      column: $table.itemnum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get siteid => $composableBuilder(
      column: $table.siteid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogcode => $composableBuilder(
      column: $table.catalogcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelnum => $composableBuilder(
      column: $table.modelnum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendor => $composableBuilder(
      column: $table.vendor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyname => $composableBuilder(
      column: $table.companyname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rowstamp => $composableBuilder(
      column: $table.rowstamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get binnum => $composableBuilder(
      column: $table.binnum, builder: (column) => ColumnOrderings(column));
}

class $$InventoryCachesTableAnnotationComposer
    extends Composer<_$ItemDatabase, $InventoryCachesTable> {
  $$InventoryCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemnum =>
      $composableBuilder(column: $table.itemnum, builder: (column) => column);

  GeneratedColumn<String> get siteid =>
      $composableBuilder(column: $table.siteid, builder: (column) => column);

  GeneratedColumn<String> get catalogcode => $composableBuilder(
      column: $table.catalogcode, builder: (column) => column);

  GeneratedColumn<String> get modelnum =>
      $composableBuilder(column: $table.modelnum, builder: (column) => column);

  GeneratedColumn<String> get vendor =>
      $composableBuilder(column: $table.vendor, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get companyname => $composableBuilder(
      column: $table.companyname, builder: (column) => column);

  GeneratedColumn<String> get rowstamp =>
      $composableBuilder(column: $table.rowstamp, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get binnum =>
      $composableBuilder(column: $table.binnum, builder: (column) => column);
}

class $$InventoryCachesTableTableManager extends RootTableManager<
    _$ItemDatabase,
    $InventoryCachesTable,
    InventoryCache,
    $$InventoryCachesTableFilterComposer,
    $$InventoryCachesTableOrderingComposer,
    $$InventoryCachesTableAnnotationComposer,
    $$InventoryCachesTableCreateCompanionBuilder,
    $$InventoryCachesTableUpdateCompanionBuilder,
    (
      InventoryCache,
      BaseReferences<_$ItemDatabase, $InventoryCachesTable, InventoryCache>
    ),
    InventoryCache,
    PrefetchHooks Function()> {
  $$InventoryCachesTableTableManager(
      _$ItemDatabase db, $InventoryCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemnum = const Value.absent(),
            Value<String> siteid = const Value.absent(),
            Value<String?> catalogcode = const Value.absent(),
            Value<String?> modelnum = const Value.absent(),
            Value<String?> vendor = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> companyname = const Value.absent(),
            Value<String?> rowstamp = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String?> binnum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCachesCompanion(
            itemnum: itemnum,
            siteid: siteid,
            catalogcode: catalogcode,
            modelnum: modelnum,
            vendor: vendor,
            manufacturer: manufacturer,
            companyname: companyname,
            rowstamp: rowstamp,
            location: location,
            binnum: binnum,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemnum,
            required String siteid,
            Value<String?> catalogcode = const Value.absent(),
            Value<String?> modelnum = const Value.absent(),
            Value<String?> vendor = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> companyname = const Value.absent(),
            Value<String?> rowstamp = const Value.absent(),
            required String location,
            Value<String?> binnum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCachesCompanion.insert(
            itemnum: itemnum,
            siteid: siteid,
            catalogcode: catalogcode,
            modelnum: modelnum,
            vendor: vendor,
            manufacturer: manufacturer,
            companyname: companyname,
            rowstamp: rowstamp,
            location: location,
            binnum: binnum,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventoryCachesTableProcessedTableManager = ProcessedTableManager<
    _$ItemDatabase,
    $InventoryCachesTable,
    InventoryCache,
    $$InventoryCachesTableFilterComposer,
    $$InventoryCachesTableOrderingComposer,
    $$InventoryCachesTableAnnotationComposer,
    $$InventoryCachesTableCreateCompanionBuilder,
    $$InventoryCachesTableUpdateCompanionBuilder,
    (
      InventoryCache,
      BaseReferences<_$ItemDatabase, $InventoryCachesTable, InventoryCache>
    ),
    InventoryCache,
    PrefetchHooks Function()>;
typedef $$ManufacturersTableCreateCompanionBuilder = ManufacturersCompanion
    Function({
  Value<int> id,
  required String fullName,
  required String shortName,
});
typedef $$ManufacturersTableUpdateCompanionBuilder = ManufacturersCompanion
    Function({
  Value<int> id,
  Value<String> fullName,
  Value<String> shortName,
});

class $$ManufacturersTableFilterComposer
    extends Composer<_$ItemDatabase, $ManufacturersTable> {
  $$ManufacturersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));
}

class $$ManufacturersTableOrderingComposer
    extends Composer<_$ItemDatabase, $ManufacturersTable> {
  $$ManufacturersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));
}

class $$ManufacturersTableAnnotationComposer
    extends Composer<_$ItemDatabase, $ManufacturersTable> {
  $$ManufacturersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);
}

class $$ManufacturersTableTableManager extends RootTableManager<
    _$ItemDatabase,
    $ManufacturersTable,
    Manufacturer,
    $$ManufacturersTableFilterComposer,
    $$ManufacturersTableOrderingComposer,
    $$ManufacturersTableAnnotationComposer,
    $$ManufacturersTableCreateCompanionBuilder,
    $$ManufacturersTableUpdateCompanionBuilder,
    (
      Manufacturer,
      BaseReferences<_$ItemDatabase, $ManufacturersTable, Manufacturer>
    ),
    Manufacturer,
    PrefetchHooks Function()> {
  $$ManufacturersTableTableManager(_$ItemDatabase db, $ManufacturersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManufacturersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManufacturersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManufacturersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> shortName = const Value.absent(),
          }) =>
              ManufacturersCompanion(
            id: id,
            fullName: fullName,
            shortName: shortName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String fullName,
            required String shortName,
          }) =>
              ManufacturersCompanion.insert(
            id: id,
            fullName: fullName,
            shortName: shortName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ManufacturersTableProcessedTableManager = ProcessedTableManager<
    _$ItemDatabase,
    $ManufacturersTable,
    Manufacturer,
    $$ManufacturersTableFilterComposer,
    $$ManufacturersTableOrderingComposer,
    $$ManufacturersTableAnnotationComposer,
    $$ManufacturersTableCreateCompanionBuilder,
    $$ManufacturersTableUpdateCompanionBuilder,
    (
      Manufacturer,
      BaseReferences<_$ItemDatabase, $ManufacturersTable, Manufacturer>
    ),
    Manufacturer,
    PrefetchHooks Function()>;
typedef $$AbbreviationsTableCreateCompanionBuilder = AbbreviationsCompanion
    Function({
  Value<int> id,
  required String origText,
  required String replaceText,
});
typedef $$AbbreviationsTableUpdateCompanionBuilder = AbbreviationsCompanion
    Function({
  Value<int> id,
  Value<String> origText,
  Value<String> replaceText,
});

class $$AbbreviationsTableFilterComposer
    extends Composer<_$ItemDatabase, $AbbreviationsTable> {
  $$AbbreviationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origText => $composableBuilder(
      column: $table.origText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replaceText => $composableBuilder(
      column: $table.replaceText, builder: (column) => ColumnFilters(column));
}

class $$AbbreviationsTableOrderingComposer
    extends Composer<_$ItemDatabase, $AbbreviationsTable> {
  $$AbbreviationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origText => $composableBuilder(
      column: $table.origText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replaceText => $composableBuilder(
      column: $table.replaceText, builder: (column) => ColumnOrderings(column));
}

class $$AbbreviationsTableAnnotationComposer
    extends Composer<_$ItemDatabase, $AbbreviationsTable> {
  $$AbbreviationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get origText =>
      $composableBuilder(column: $table.origText, builder: (column) => column);

  GeneratedColumn<String> get replaceText => $composableBuilder(
      column: $table.replaceText, builder: (column) => column);
}

class $$AbbreviationsTableTableManager extends RootTableManager<
    _$ItemDatabase,
    $AbbreviationsTable,
    Abbreviation,
    $$AbbreviationsTableFilterComposer,
    $$AbbreviationsTableOrderingComposer,
    $$AbbreviationsTableAnnotationComposer,
    $$AbbreviationsTableCreateCompanionBuilder,
    $$AbbreviationsTableUpdateCompanionBuilder,
    (
      Abbreviation,
      BaseReferences<_$ItemDatabase, $AbbreviationsTable, Abbreviation>
    ),
    Abbreviation,
    PrefetchHooks Function()> {
  $$AbbreviationsTableTableManager(_$ItemDatabase db, $AbbreviationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbbreviationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbbreviationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbbreviationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> origText = const Value.absent(),
            Value<String> replaceText = const Value.absent(),
          }) =>
              AbbreviationsCompanion(
            id: id,
            origText: origText,
            replaceText: replaceText,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String origText,
            required String replaceText,
          }) =>
              AbbreviationsCompanion.insert(
            id: id,
            origText: origText,
            replaceText: replaceText,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AbbreviationsTableProcessedTableManager = ProcessedTableManager<
    _$ItemDatabase,
    $AbbreviationsTable,
    Abbreviation,
    $$AbbreviationsTableFilterComposer,
    $$AbbreviationsTableOrderingComposer,
    $$AbbreviationsTableAnnotationComposer,
    $$AbbreviationsTableCreateCompanionBuilder,
    $$AbbreviationsTableUpdateCompanionBuilder,
    (
      Abbreviation,
      BaseReferences<_$ItemDatabase, $AbbreviationsTable, Abbreviation>
    ),
    Abbreviation,
    PrefetchHooks Function()>;

class $ItemDatabaseManager {
  final _$ItemDatabase _db;
  $ItemDatabaseManager(this._db);
  $$ItemCachesTableTableManager get itemCaches =>
      $$ItemCachesTableTableManager(_db, _db.itemCaches);
  $$InventoryCachesTableTableManager get inventoryCaches =>
      $$InventoryCachesTableTableManager(_db, _db.inventoryCaches);
  $$ManufacturersTableTableManager get manufacturers =>
      $$ManufacturersTableTableManager(_db, _db.manufacturers);
  $$AbbreviationsTableTableManager get abbreviations =>
      $$AbbreviationsTableTableManager(_db, _db.abbreviations);
}

class GetReplacementsResult {
  final String origText;
  final String replaceText;
  GetReplacementsResult({
    required this.origText,
    required this.replaceText,
  });
}
