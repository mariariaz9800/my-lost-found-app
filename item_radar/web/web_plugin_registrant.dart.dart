// web/web_plugin_registrant.dart
@JS('registerPlugins')
library web_plugin_registrant;

import 'dart:js_util';
import 'package:js/js.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins() {
  setProperty(
    window,
    'firebase',
    allowInterop((_) {}),
  );
}