// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/init_hive_tani.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/custom_code/actions/init_tani_pk_store.dart';

final _encryptionKey = FFAppState().taniEncryptionKey;

Future<Box<Map>> _openTable(String tableName, List<int> encryptionKey) async {
  bool isEncrypted = tableName.startsWith('encrypted_');
  return await Hive.openBox<Map>(tableName,
      encryptionCipher: isEncrypted ? HiveAesCipher(encryptionKey) : null);
}

Future<String> createRow(
  String tableName,
  dynamic jsonInput,
  Future<dynamic> Function()? onSuccess,
  Future<dynamic> Function()? onError,
  String rowId,
) async {
  try {
    var box = await _openTable(tableName, _encryptionKey);
    var newRowData = jsonDecode(jsonInput);
    Map<dynamic, dynamic> dynamicNewRow = newRowData;
    var dummyRowData = box.get('dummy');

    // Check if each value in newRowData matches the type in dummyRowData
    dummyRowData?.forEach((key, value) {
      if (dynamicNewRow[key].runtimeType != value.runtimeType) {
        throw Exception(
            'Type mismatch for key $key. Expected ${value.runtimeType}, found ${dynamicNewRow[key].runtimeType}');
      }
    });

    int key = await box.add(newRowData);
    taniPkStore.write(rowId, key);
    print(taniPkStore.read(rowId));
    if (onSuccess != null) await onSuccess();
  } catch (e) {
    print('Error: $e');
    if (onError != null) await onError();
    rethrow; // Rethrow the exception to handle it outside of this function as well
  }
  return rowId;
}