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
import 'dart:math';

Future<void> _createPKTable(String pKeyField, String tableName) async {
  final pkBoxName = 'pk_$tableName';
  var pkBox = await Hive.openBox(pkBoxName);
  await pkBox.put('primaryKeyField', pKeyField);
  await pkBox.close();
}

Future initializeTable(
    String tableName,
    List<String> tableColumnNames,
    List<String> tableColumnDefinitions,
    bool? encryptTable,
    String pKeyField,
    Future<dynamic> Function()? onSuccess,
    Future<dynamic> Function()? onError) async {
  var box;
  taniPkStore.write(tableName, pKeyField);
  if (encryptTable == null) {
    encryptTable = false;
  } else {}
  try {
    final boxName = encryptTable ? 'encrypted_$tableName' : tableName;
    box = await Hive.openBox<Map>(boxName,
        encryptionCipher: encryptTable
            ? HiveAesCipher(FFAppState().taniEncryptionKey)
            : null);
    if (box.isEmpty) {
      var dummyRow = <String, dynamic>{};
      for (var i = 0; i < tableColumnNames.length; i++) {
        var columnName = tableColumnNames[i];
        var columnType = tableColumnDefinitions[i].toLowerCase();
        switch (columnType) {
          case 'string':
            dummyRow[columnName] = 'dummy';
            break;
          case 'datetime':
            dummyRow[columnName] = DateTime.now();
            break;
          case 'integer':
            dummyRow[columnName] = Random().nextInt(100);
            break;
          case 'int':
            dummyRow[columnName] = Random().nextInt(100);
            break;
          case 'double':
            dummyRow[columnName] = Random().nextDouble();
            break;
          case 'bool':
            dummyRow[columnName] = true;
            break;
          case 'boolean':
            dummyRow[columnName] = true;
            break;
          case 'list<string>':
            dummyRow[columnName] = ['dummy', 'list', 'content'];
            break;
          case 'list<int>':
            dummyRow[columnName] = [1, 2, 3];
            break;
          case 'list<integer>':
            dummyRow[columnName] = [1, 2, 3];
            break;
          case 'list<integers>':
            dummyRow[columnName] = [1, 2, 3];
            break;
          case 'list<double>':
            dummyRow[columnName] = [1.0, 2.0, 3.0];
            break;
          case 'list<bool>':
            dummyRow[columnName] = [true, false, true];
            break;
          case 'list<boolean>':
            dummyRow[columnName] = [true, false, true];
            break;
          case 'list<datetime>':
            dummyRow[columnName] = [DateTime.now()];
            break;
          default:
            throw UnsupportedError('Unsupported column type: $columnType');
        }
      }
      await box.put(dummyRow[pKeyField], dummyRow);
      await _createPKTable(pKeyField, tableName);
      if (onSuccess != null) await onSuccess;
    }
  } catch (e) {
    print('Error initializing table $tableName : $e');
    print('Error: Table $tableName creation failed with $e');
    if (onError != null) await onError;
  } finally {
    await box.close();
  }
}
