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
import '/custom_code/actions/init_tani_pk_store.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

final _encryptionKey = FFAppState().taniEncryptionKey;

Future<Box<Map>> _openTable(String tableName, List<int> encryptionKey) async {
  bool isEncrypted = tableName.startsWith('encrypted_');
  return await Hive.openBox<Map>(tableName,
      encryptionCipher: isEncrypted ? HiveAesCipher(encryptionKey) : null);
}

Future updateRow(
  String tableName,
  dynamic jsonInput,
  String rowId,
  Future<dynamic> Function()? onSuccess,
  Future<dynamic> Function()? onError,
) async {
  Box<Map>? box;
  try {
    box = await _openTable(tableName, _encryptionKey);
    Map newRowData = jsonDecode(jsonInput);
    var hiveKeyRaw = taniPkStore.read(rowId);
//    var hiveKey = int.parse(hiveKeyRaw);
//    Map? existingRow = box.get(hiveKey);

    // Update each field in the existing row with the new data
    await box.put(hiveKeyRaw, newRowData);
    if (onSuccess != null) await onSuccess();
  } catch (e) {
    print('Error updating row: $e');
    if (onError != null) await onError();
  } finally {
    box?.close();
  }
}
