// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/init_tani_pk_store.dart';
import '/custom_code/actions/init_hive_tani.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<Box<Map>> _openTable(String tableName, List<int> encryptionKey) async {
  bool isEncrypted = tableName.startsWith('encrypted_');
  return await Hive.openBox<Map>(tableName,
      encryptionCipher: isEncrypted ? HiveAesCipher(encryptionKey) : null);
}

bool _isIndexedField(String tableName, String field) {
  return Hive.isBoxOpen('${tableName}${field}Index');
}

bool _anyFieldIndexed(
    List<Map<String, Map<String, dynamic>>> criteria, String tableName) {
  return criteria.any((criterion) {
    var field = criterion.keys.first;
    return _isIndexedField(tableName, field);
  });
}

bool _evaluateContains(dynamic itemValue, dynamic criteriaValue) {
  // Convert single int values to double
  if (criteriaValue is int) {
    criteriaValue = criteriaValue.toDouble();
  }

  // Ensure all items in a list are doubles if criteriaValue is a double
  if (criteriaValue is double && itemValue is List) {
    itemValue = itemValue.map((e) => e is int ? e.toDouble() : e).toList();
  }

  if (itemValue is List && criteriaValue is List) {
    // Ensure all list items are doubles for comparison
    var doubleItemList =
        itemValue.map((e) => e is int ? e.toDouble() : e).toList();
    var doubleCriteriaList =
        criteriaValue.map((e) => e is int ? e.toDouble() : e).toList();
    return Set.from(doubleItemList)
        .intersection(Set.from(doubleCriteriaList))
        .isNotEmpty;
  } else if (itemValue is String && criteriaValue is String) {
    return itemValue.contains(criteriaValue);
  } else if (itemValue is List) {
    return itemValue.contains(criteriaValue);
  }
  return false;
}

bool _evaluateCriteria(Map<dynamic, dynamic> item, String field,
    dynamic criteriaValue, String operation) {
  dynamic itemValue = item[field];

  // Cast integers to double for comparison
  if (itemValue is int) itemValue = itemValue.toDouble();
  if (criteriaValue is int) criteriaValue = criteriaValue.toDouble();

  switch (operation) {
    case '==':
      if (itemValue is DateTime && criteriaValue is DateTime) {
        return itemValue.isAtSameMomentAs(criteriaValue);
      }
      return itemValue == criteriaValue;
    case '!=':
      if (itemValue is DateTime && criteriaValue is DateTime) {
        return !itemValue.isAtSameMomentAs(criteriaValue);
      }
      return itemValue != criteriaValue;
    case '>':
      if (itemValue is DateTime && criteriaValue is DateTime) {
        return itemValue.isAfter(criteriaValue);
      }
      if (itemValue is num && criteriaValue is num) {
        return itemValue > criteriaValue;
      }
      break;
    case '<':
      if (itemValue is DateTime && criteriaValue is DateTime) {
        return itemValue.isBefore(criteriaValue);
      }
      if (itemValue is num && criteriaValue is num) {
        return itemValue < criteriaValue;
      }
      break;
    case '>=':
      if (itemValue is DateTime && criteriaValue is DateTime) {
        return itemValue.isAfter(criteriaValue) ||
            itemValue.isAtSameMomentAs(criteriaValue);
      }
      if (itemValue is num && criteriaValue is num) {
        return itemValue >= criteriaValue;
      }
      break;
    case '<=':
      if (itemValue is DateTime && criteriaValue is DateTime) {
        return itemValue.isBefore(criteriaValue) ||
            itemValue.isAtSameMomentAs(criteriaValue);
      }
      if (itemValue is num && criteriaValue is num) {
        return itemValue <= criteriaValue;
      }
      break;
    case 'contains':
      return _evaluateContains(itemValue, criteriaValue);
    case '!contains':
      return !_evaluateContains(itemValue, criteriaValue);
    case 'starts with':
      return itemValue is String &&
          criteriaValue is String &&
          itemValue.startsWith(criteriaValue);
    case 'ends with':
      return itemValue is String &&
          criteriaValue is String &&
          itemValue.endsWith(criteriaValue);
    case 'is in':
      return criteriaValue is List && criteriaValue.contains(itemValue);
    case 'is not in':
      return criteriaValue is List && !criteriaValue.contains(itemValue);
    case 'is null':
      return itemValue == null;
    case 'is not null':
      return itemValue != null;
    default:
      throw UnsupportedError('Unsupported operation: $operation');
  }
  // If we reach here, then the operation did not match any case
  return false;
}

Future<List<dynamic>?> queryRows(String jsonQuery, String tableName) async {
  var queryInfo = jsonDecode(jsonQuery);
  var criteria = queryInfo['criteria'];
  var matchAll = queryInfo['matchAll'];
  int? limit = queryInfo['limit'];
  var dKey = queryInfo['dKey'];
  var sortInfo = queryInfo['sort'];
  final _encryptionKey = FFAppState().taniEncryptionKey;
  List<Map> results = [];

//  final primaryKeyBox = await _openTable('pk_${tableName}', _encryptionKey);
//  final primaryKeyField = primaryKeyBox.values.first;

  // Open main box (main table)
  var box = await _openTable(tableName, _encryptionKey);

  for (var itemKey in box.keys) {
    var item = box.get(itemKey);
    bool shouldInclude = matchAll;
    for (var criterion in criteria) {
      var field = criterion.keys.first;
      var value = criterion[field]['value'];
      var operation = criterion[field]['operation'];

/*      if (_isIndexedField(tableName, field)) {
        // If the field is indexed, open the index box and check there first
        var indexBox =
            await _openTable('${tableName}${field}Index', _encryptionKey);
        var indexResults = indexBox.values.where((indexItem) {
          return _evaluateCriteria(indexItem, field, value, operation);
        }).toList();

        // Use the IDs from the indexResults to fetch the actual items from the main box
        for (var indexResult in indexResults) {
          var id = indexResult[primaryKeyField];
          var hiveKeyRaw = taniPkStore.read(id);
          results.add(box.get(hiveKeyRaw) ?? {});
        } */
//        continue; // Skip the rest of the loop as we've already added the matching items
//      }

      // If the field is indexed or not, perform the check on the item directly
      if (!_isIndexedField(tableName, field) ||
          _isIndexedField(tableName, field)) {
        var matches = _evaluateCriteria(item ?? {}, field, value, operation);
        if (matchAll) {
          shouldInclude = shouldInclude && matches;
        } else {
          shouldInclude = shouldInclude || matches;
        }
      }
    }

    // If the item should be included and no fields are indexed, add to results
    if (shouldInclude /*&& !_anyFieldIndexed(criteria, tableName)*/) {
      results.add(item ?? {});
    }
  }

  // Sorting
  if (sortInfo != null) {
    var field = sortInfo['field'];
    var direction = sortInfo['order'];
    results.sort((a, b) {
      var valueA = a[field];
      var valueB = b[field];
      if (valueA == null || valueB == null) return valueA == null ? 1 : -1;
      return direction == 'ascending'
          ? Comparable.compare(valueA, valueB)
          : Comparable.compare(valueB, valueA);
    });
  }

  // Pagination
  if (limit != null && limit > 0) {
    int startIdx = dKey ?? 0;
    int endIdx = startIdx + limit;
    endIdx = endIdx > results.length ? results.length : endIdx;
    return results.sublist(startIdx, endIdx);
  }

  return results;
}

/* Nested Logic query to be thoroughly investigated or deferred till v 0.0.5
until Hive has a consistent way of returning data or FF supports build runner
then Tani will be re-written completely in Isar.

Future<List<dynamic>?> nestedQueryRows(
    String? queryBuilderOutput, String tableName) async {
  // Determine the operation type and split the input
  List<String> jsonQueries;
  String operationType;
  if (queryBuilderOutput!.contains('<MERGE>')) {
    jsonQueries = queryBuilderOutput.split('<MERGE>');
    operationType = '<MERGE>';
  } else if (queryBuilderOutput.contains('<UNION>')) {
    jsonQueries = queryBuilderOutput.split('<UNION>');
    operationType = '<UNION>';
  } else {
    // If there's no <MERGE> or <UNION>, it's a single JSON query
    jsonQueries = [queryBuilderOutput];
    operationType = 'SINGLE'; // This is just for internal reference
  }

  // Fetch the primary key field for the table
  var primaryKeyField = taniPkStore.read(tableName);

  List<Map> finalResults = [];

  // To keep track of the primary keys found in all queries for UNION operation
  Set<dynamic> unionPrimaryKeys = Set();

  for (String jsonQuery in jsonQueries) {
    Map jsonObject = jsonDecode(jsonQuery);

    // Pass the jsonObject to _queryRowsHelper
    var results = await _queryRowsHelper(jsonObject, tableName);

    if (operationType == '<MERGE>') {
      // Deduplicate results by adding them to a set
      final Set<Map> deduplicatedSet = Set.from(finalResults);
      deduplicatedSet.addAll(results!.cast<Map>());
      finalResults = deduplicatedSet.toList();
    } else if (operationType == '<UNION>' && unionPrimaryKeys.isEmpty) {
      // For the first query, add all primary keys
      unionPrimaryKeys.addAll(
          results!.cast<Map>().map((result) => result[primaryKeyField]));
    } else if (operationType == '<UNION>') {
      // For subsequent queries, retain only common primary keys
      unionPrimaryKeys.retainAll(
          results!.cast<Map>().map((result) => result[primaryKeyField]));
    } else {
      // If operationType is 'SINGLE', just use the results directly
      finalResults = results!.cast<Map>();
      break; // No need to continue the loop
    }
  }

  // If it's a UNION operation, filter the finalResults to only include items with primary keys in unionPrimaryKeys
  if (operationType == '<UNION>') {
    finalResults = finalResults
        .where((result) => unionPrimaryKeys.contains(result[primaryKeyField]))
        .toList();
  }

  return finalResults;
}
*/
