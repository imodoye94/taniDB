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

Future<dynamic?> readSingleRow(
  String tableName,
  String rowId,
  Future<dynamic> Function()? onSuccess,
  Future<dynamic> Function()? onError,
) async {
  try {
    var box = await _openTable(tableName, _encryptionKey);
    var hiveKeyRaw = taniPkStore.read(rowId);
    int hiveKey = int.parse(hiveKeyRaw);
    Map? item = box.get(hiveKey);
    if (item != null) {
      if (onSuccess != null) await onSuccess();
      return item;
    } else {
      return {};
    }
  } catch (e) {
    print('Error : $e');
    if (onError != null) await onError();
  }
}
