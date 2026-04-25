import 'package:flutter/material.dart';

AppBar buildAppBar(String title, BuildContext context) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).appBarTheme.foregroundColor,
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
    elevation: Theme.of(context).appBarTheme.elevation,
  );
}
