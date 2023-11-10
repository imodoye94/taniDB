// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/* Get secure storage is a synchronous persistent key-value store in-memory
it's secured with dart cryptography and thus can be used to store sensitive info
taniDB uses it for the purpose of storing Hive keys NOT ACTUAL DATA.
The password used is a user-provided string that's stored in an FFAppState
persisted, itself another secure storage facility.
The chief reason we are using G.S.T is because it basically gives 
use an 'FFAppState' that we can programmatically write to and read from.
We cannot programmatically create an appstate variable inside the workflow
and this creates the issue that you must pre-know all variables and cannot
dynamically name one, which we need to do for rowIds, G.S.T overcomes that for us
*/

import 'package:get_secure_storage/get_secure_storage.dart';

final String? _strongPassword = FFAppState().taniPKStorePassword;

late GetSecureStorage taniPkStore;

// initialize and instantiate a global instance of GetSecureStorage
Future<void> initTaniPkStore() async {
  if (_strongPassword != null) {
    try {
      await GetSecureStorage.init(
          container: 'TaniDB', password: _strongPassword);
      taniPkStore =
          GetSecureStorage(container: 'TaniDB', password: _strongPassword);
      return;
    } catch (e) {
      print('Error in initSecureStorage, do not store sensitive data: $e');
      return;
    }
  } else {
    print(
        'Error in initSecureStorage, do not store sensitive data: system encryption password not found');
    return;
  }
}
