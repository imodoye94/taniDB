// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:hive_flutter/hive_flutter.dart';

// Define the TaniSchemaAdapter
class TaniSchemaAdapter extends TypeAdapter<Map> {
  @override
  final int typeId = 0;

  @override
  Map read(BinaryReader reader) {
    var numOfKeys = reader.readByte();
    var mapOfData = <String, dynamic>{};
    for (var i = 0; i < numOfKeys; i++) {
      var key = reader.readString();
      var value = reader.read();
      mapOfData[key] = value;
    }
    return mapOfData;
  }

  @override
  void write(BinaryWriter writer, Map obj) {
    writer.writeByte(obj.length);
    for (var key in obj.keys) {
      writer.writeString(key);
      writer.write(obj[key]);
    }
  }
}

// initialize Hive and register the TaniSchemaAdapter
Future<void> initHiveTani() async {
  List<int> appKey = FFAppState().taniEncryptionKey;
  if (appKey.length < 1) {
    FFAppState().taniEncryptionKey = Hive.generateSecureKey();
  }
  try {
    Hive.registerAdapter(TaniSchemaAdapter());
    Hive.initFlutter();
  } catch (e) {
    print('error initializing Hive: $e');
    print('Error! your database did not start successfully : $e');
  }
}
