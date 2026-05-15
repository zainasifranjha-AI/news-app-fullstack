import 'package:flutter/material.dart';

/// Shared theme toggle for the whole app (user + admin).
final ValueNotifier<ThemeMode> globalThemeMode = ValueNotifier(ThemeMode.dark);
