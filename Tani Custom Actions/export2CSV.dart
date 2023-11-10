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
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;
import 'package:hive_flutter/hive_flutter.dart';

import '/custom_code/actions/init_hive_tani.dart';

Future<Box<Map>> _openTable(String tableName, List<int> encryptionKey) async {
  bool isEncrypted = tableName.startsWith('encrypted_');
  return await Hive.openBox<Map>(tableName,
      encryptionCipher: isEncrypted ? HiveAesCipher(encryptionKey) : null);
}

Future<void> export2CSV(String tableName) async {
  var box = await _openTable(tableName, FFAppState().taniEncryptionKey);
  List<List<dynamic>> rows = [];

  if (box.isNotEmpty) {
    // Add the header row
    rows.add(box.values.first.keys.toList());

    // Add the data rows
    for (var item in box.values) {
      rows.add(item.values.toList());
    }
  }

  // Convert rows to a CSV string
  String csvString = const ListToCsvConverter().convert(rows);

  // Handle different environments
  if (kIsWeb) {
    // Create a Blob from the CSV string
    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", "$tableName.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    String path;
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms logic (use share_plus for sharing the file)
      final tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/$tableName.csv';
      final file = File(path);
      await file.writeAsString(csvString);

      // Use Share plugin to share/saving the file
      await Share.shareXFiles([XFile(path)],
          text: 'Exported CSV for $tableName');
    } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      // Desktop platforms logic (save directly to the Downloads folder if possible)
      final downloadsDir = await getDownloadsDirectory();
      path =
          '${downloadsDir?.path ?? (await getTemporaryDirectory()).path}/$tableName.csv';
      final file = File(path);
      await file.writeAsString(csvString);
      print('File generation complete');
    } else {
      // Unsupported platform
      throw UnimplementedError('Platform not supported for CSV export.');
    }
  }
}
