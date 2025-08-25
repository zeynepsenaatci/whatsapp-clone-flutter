import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:flutter/material.dart';

import 'package:whatsappnew/main.dart' as entrypoint;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void main() {
  // This is required for Flutter web to work properly.
  setUrlStrategy(PathUrlStrategy());
  entrypoint.main();
} 