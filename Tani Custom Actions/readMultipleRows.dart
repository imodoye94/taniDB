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

final _encryptionKey = FFAppState().taniEncryptionKey;

Future<Box<Map>> _openTable(String tableName, List<int> encryptionKey) async {
  bool isEncrypted = tableName.startsWith('encrypted_');
  return await Hive.openBox<Map>(tableName,
      encryptionCipher: isEncrypted ? HiveAesCipher(encryptionKey) : null);
}

Future<List<dynamic>?> readMultipleRows(
  String tableName,
  List<String> listOfRowIds,
  Future<dynamic> Function()? onSuccess,
  Future<dynamic> Function()? onError,
) async {
  var box;
  try {
    box = await _openTable(tableName, _encryptionKey);
  } catch (e) {
    print('Error : $e');
    if (onError != null) await onError();
  }
  List<dynamic> items = [];
  int rowCount = 0;
  for (String rowId in listOfRowIds) {
    rowCount = rowCount + 1;
    var hiveKeyRaw = taniPkStore.read(rowId);
    int hiveKey = int.parse(hiveKeyRaw);
    Map? item = box.get(hiveKey);
    if (item != null) {
      items.add(item);
    } else {
      items.add({}); // this will return an array of empty JSON objects
    }
    if (rowCount == 100) {
      return items;
    }
  }
  if (onSuccess != null) await onSuccess();
  return items;
}
