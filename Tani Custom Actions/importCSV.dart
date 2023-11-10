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
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/custom_code/actions/init_hive_tani.dart';

Future<void> importCSV() async {
  // Use file_picker to pick the CSV file
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  // If a file is picked, process it
  if (result != null && result.files.single.bytes != null) {
    // Get the file bytes and convert them to a string
    final fileBytes = result.files.single.bytes!;
    final fileName = result.files.single.name;
    final csvString = utf8.decode(fileBytes);

    // Convert the CSV string into a List of Lists
    final List<List<dynamic>> rows =
        const CsvToListConverter().convert(csvString);

    // Assuming the first row contains headers
    final headers = rows.first;
    List<Map<String, dynamic>> maps = [];

    // Convert each subsequent row into a Map based on the headers
    for (final row in rows.skip(1)) {
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i].toString()] = row[i];
      }
      maps.add(map);
    }

    // Open a new Hive box with the file name
    final boxName = fileName.replaceAll('.csv', '');
    final Box<Map<String, dynamic>> box =
        await Hive.openBox<Map<String, dynamic>>(boxName);

    // Open a PK_ box to store primary keys
    final pkBoxName = 'PK_$boxName';
    final Box<dynamic> pkBox = await Hive.openBox<dynamic>(pkBoxName);

    // Write the data to the Hive box with 'id' as the key
    for (var map in maps) {
      final id = map['id'];
      if (id != null) {
        await box.put(id, map);
        await pkBox.add('id');
      } else {
        // Handle the case where 'id' is not present in the map
        print('Row does not contain an "id" field and was skipped.');
      }
    }

    print('Imported CSV data to Hive box: $boxName');
  } else {
    print('No file selected or operation failed.');
  }
}
