// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<String> queryBuilder(String input) async {
  // Remove extraneous whitespaces except within quotes
  input = input.replaceAllMapped(RegExp(r'\*\*([^\*]+)\*\*'), (match) {
    return '**' + match.group(1)!.trim() + '**';
  });

  // Define the pattern to match the criteria sections
  var pattern = RegExp(r"\*\[(\*\*[^*]+\*\*[^*]+\*\*[^*]+\*\*[^*]+\*\*)\]\*");
  var matches = pattern.allMatches(input);

  List<Map<String, dynamic>> criteria = [];
  bool matchAll = input.contains('&&');

  for (var match in matches) {
    var parts = match
        .group(1)
        ?.split("**")
        .where((element) => element.isNotEmpty)
        .toList();
    if (parts != null && parts.length >= 4) {
      var field = parts[0];
      var operation = parts[1].toLowerCase(); // Convert operation to lowercase
      var dataType = parts[2];
      var value = parts[3];

      // Handle the value according to its data type
      dynamic typedValue;
      switch (dataType.toLowerCase()) {
        case 'string':
          typedValue = value;
          break;
        case 'int':
          typedValue = int.tryParse(value) ?? value;
          break;
        case 'integer':
          typedValue = int.tryParse(value) ?? value;
          break;
        case 'double':
          typedValue = double.tryParse(value) ?? value;
          break;
        case 'boolean':
          typedValue = value == 'true';
          break;
        case 'bool':
          typedValue = value == 'true';
          break;
        case 'datetime':
          typedValue = DateTime.tryParse(value) ?? value;
          break;
        case 'date':
          typedValue = DateTime.tryParse(value) ?? value;
          break;
        default:
          typedValue = value;
      }

      criteria.add({
        field: {'value': typedValue, 'operation': operation}
      });
    }
  }

  // Extract special parameters LIMIT, INDEX, SORT, DIRECTION
  var limitMatch = RegExp(r"<LIMIT>(\d*)").firstMatch(input);
  var indexMatch = RegExp(r"<INDEX>(\d*)").firstMatch(input);
  var sortFieldMatch = RegExp(r"<SORT>(\w*)").firstMatch(input);
  var directionMatch = RegExp(r"<DIRECTION>(\w*)").firstMatch(input);

  // Initialize with default values
  int? limit;
  int index = 0; // Default to 0
  String? sortField;
  String? direction;

  // Assign values based on regex matches, applying default values where necessary
  if (limitMatch != null) {
    limit =
        limitMatch.group(1)!.isEmpty ? null : int.parse(limitMatch.group(1)!);
  }
  if (indexMatch != null && indexMatch.group(1)!.isNotEmpty) {
    index = int.parse(indexMatch.group(1)!);
  }
  sortField = sortFieldMatch != null && sortFieldMatch.group(1)!.isNotEmpty
      ? sortFieldMatch.group(1)
      : null;
  direction = sortField != null
      ? (directionMatch != null && directionMatch.group(1)!.isNotEmpty
          ? directionMatch.group(1)!.toLowerCase()
          : "descending")
      : null; // Default to "descending" if sort field is present and non-empty

  var queryInfo = {
    'criteria': criteria,
    'matchAll': matchAll,
    'limit': limit,
    'dKey': index,
    'sort': {'field': sortField, 'order': direction}
  };

  return jsonEncode(queryInfo);
}

/* Nested AND/OR logic not supported and all queries must be flat until
Tani version 0.0.5 or until FF supports build runner when Tani will be
re-written in Isar.

Future<String?> queryBuilder(String input) async {
  // Check for both <MERGE> and <UNION>
  if (input.contains('<MERGE>') && input.contains('<UNION>')) {
    throw FormatException(
        "Cannot use both <MERGE> and <UNION> in the same query.");
  } else if (!input.contains('<MERGE>') && !input.contains('<UNION>')) {
    var result = await _queryBuilderHelper(input);
    return result;
  }

  // Check for more than two <MERGE> or <UNION> tags
  if ("<MERGE>".allMatches(input).length > 2 ||
      "<UNION>".allMatches(input).length > 2) {
    throw FormatException(
        "Cannot use more than two of the same operation tags in the query.");
  }

  // Determine the operation type and split segments
  String operationType = input.contains('<MERGE>') ? '<MERGE>' : '<UNION>';
  List<String> segments = input.split(operationType);

  List<String> queryJsonStrings = [];

  for (String segment in segments) {
    // Remove the brackets around the segment
    String trimmedSegment = segment.replaceAll(RegExp(r'[()]'), '').trim();

    // Process each segment using the helper function and obtain a JSON object
    var processedQueryJson = await _queryBuilderHelper(trimmedSegment);

    // Check if the processed query is not null, then convert to string
    if (processedQueryJson != null) {
      String jsonString = jsonEncode(processedQueryJson);
      queryJsonStrings.add(jsonString);
    }
  }

  // Join the JSON strings with the operation type for output
  return queryJsonStrings.join(operationType);
}
*/
