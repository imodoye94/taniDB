// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

List _typeCheckedList(String firstItem, [List<String>? listItems]) {
  if (int.tryParse(firstItem) != null) {
    return listItems?.map<int>((item) => int.parse(item)).toList() ??
        [int.parse(firstItem)];
  } else if (double.tryParse(firstItem) != null) {
    return listItems?.map<double>((item) => double.parse(item)).toList() ??
        [double.parse(firstItem)];
  } else if (firstItem.toLowerCase() == 'true' ||
      firstItem.toLowerCase() == 'false') {
    return listItems
            ?.map<bool>((item) => item.toLowerCase() == 'true')
            .toList() ??
        [firstItem.toLowerCase() == 'true'];
  } else {
    return listItems ?? [firstItem];
  }
}

dynamic _typeCheckedValue(String rawValue) {
  if (int.tryParse(rawValue) != null) {
    return int.parse(rawValue);
  } else if (double.tryParse(rawValue) != null) {
    return double.parse(rawValue);
  } else if (rawValue.toLowerCase() == 'true' ||
      rawValue.toLowerCase() == 'false') {
    return rawValue.toLowerCase() == 'true';
  } else {
    return rawValue;
  }
}

Future<dynamic> newRowBuilder(String input) async {
  List<String> pairs = input.split('<*DELIMITER*>');
  Map<String, dynamic> formattedData = {};

  for (String pair in pairs) {
    int index = pair.indexOf(':');
    String key = pair.substring(0, index);
    String rawValue = pair.substring(index + 1);

    if (rawValue.startsWith('|*[') && rawValue.endsWith(']*|')) {
      // Handling list data type
      String listContent =
          rawValue.substring(3, rawValue.length - 3); // Remove '|*[' and ']*|'
      List<String> listItems = listContent.split(' |*| ');

      if (listItems.length == 1) {
        // Handle the case where the list has a single item
        var firstItem = listItems[0];
        formattedData[key] = _typeCheckedList(firstItem);
      } else {
        var firstItem = listItems[0];
        formattedData[key] = _typeCheckedList(firstItem, listItems);
      }
    } else {
      // Handling primitive data type
      formattedData[key] = _typeCheckedValue(rawValue);
    }
  }

  return jsonEncode(formattedData);
}
