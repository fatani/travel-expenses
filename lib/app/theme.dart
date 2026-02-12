import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
	useMaterial3: true,
	colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
	textTheme: const TextTheme(
		titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
		bodyLarge: TextStyle(fontSize: 16, height: 1.4),
		bodyMedium: TextStyle(fontSize: 14, height: 1.4),
	),
);
