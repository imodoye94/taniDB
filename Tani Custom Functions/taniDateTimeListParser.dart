import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/flutter_flow/custom_functions.dart';
import '/backend/schema/structs/index.dart';

String? taniDateTimeListParser(List<DateTime>? listOfDateTime) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  // a function that converts an input list of strings to a string, and returns the string
  if (listOfDateTime == null || listOfDateTime.isEmpty) {
    return null;
  }
  final prereturn = listOfDateTime.join(' |*| ');
  return '|*[' + prereturn + ']*|';

  /// MODIFY CODE ONLY ABOVE THIS LINE
}