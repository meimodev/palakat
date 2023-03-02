// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'helper_song_db_version.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetHelperSongDbVersionCollection on Isar {
  IsarCollection<HelperSongDbVersion> get helperSongDbVersions =>
      this.collection();
}

const HelperSongDbVersionSchema = CollectionSchema(
  name: r'HelperSongDbVersion',
  id: 5769880040773857905,
  properties: {
    r'dateRaw': PropertySchema(
      id: 0,
      name: r'dateRaw',
      type: IsarType.string,
    )
  },
  estimateSize: _helperSongDbVersionEstimateSize,
  serialize: _helperSongDbVersionSerialize,
  deserialize: _helperSongDbVersionDeserialize,
  deserializeProp: _helperSongDbVersionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _helperSongDbVersionGetId,
  getLinks: _helperSongDbVersionGetLinks,
  attach: _helperSongDbVersionAttach,
  version: '3.0.5',
);

int _helperSongDbVersionEstimateSize(
  HelperSongDbVersion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dateRaw.length * 3;
  return bytesCount;
}

void _helperSongDbVersionSerialize(
  HelperSongDbVersion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dateRaw);
}

HelperSongDbVersion _helperSongDbVersionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HelperSongDbVersion(
    dateRaw: reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _helperSongDbVersionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _helperSongDbVersionGetId(HelperSongDbVersion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _helperSongDbVersionGetLinks(
    HelperSongDbVersion object) {
  return [];
}

void _helperSongDbVersionAttach(
    IsarCollection<dynamic> col, Id id, HelperSongDbVersion object) {
  object.id = id;
}

extension HelperSongDbVersionQueryWhereSort
    on QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QWhere> {
  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HelperSongDbVersionQueryWhere
    on QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QWhereClause> {
  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HelperSongDbVersionQueryFilter on QueryBuilder<HelperSongDbVersion,
    HelperSongDbVersion, QFilterCondition> {
  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateRaw',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dateRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dateRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dateRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dateRaw',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateRaw',
        value: '',
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      dateRawIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dateRaw',
        value: '',
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HelperSongDbVersionQueryObject on QueryBuilder<HelperSongDbVersion,
    HelperSongDbVersion, QFilterCondition> {}

extension HelperSongDbVersionQueryLinks on QueryBuilder<HelperSongDbVersion,
    HelperSongDbVersion, QFilterCondition> {}

extension HelperSongDbVersionQuerySortBy
    on QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QSortBy> {
  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterSortBy>
      sortByDateRaw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateRaw', Sort.asc);
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterSortBy>
      sortByDateRawDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateRaw', Sort.desc);
    });
  }
}

extension HelperSongDbVersionQuerySortThenBy
    on QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QSortThenBy> {
  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterSortBy>
      thenByDateRaw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateRaw', Sort.asc);
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterSortBy>
      thenByDateRawDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateRaw', Sort.desc);
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension HelperSongDbVersionQueryWhereDistinct
    on QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QDistinct> {
  QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QDistinct>
      distinctByDateRaw({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateRaw', caseSensitive: caseSensitive);
    });
  }
}

extension HelperSongDbVersionQueryProperty
    on QueryBuilder<HelperSongDbVersion, HelperSongDbVersion, QQueryProperty> {
  QueryBuilder<HelperSongDbVersion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HelperSongDbVersion, String, QQueryOperations>
      dateRawProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateRaw');
    });
  }
}
