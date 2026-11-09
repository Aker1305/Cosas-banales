import 'package:flutter/material.dart';
import 'package:openhiit/shared/globals.dart';

Future<void> showImportDialog(
    String timerName, Future<void> Function() onConfirm) async {
  final navigator = navigatorKey.currentState;
  if (navigator == null || !navigator.mounted) {
    // Context is not available — the app may be rebuilding
    return;
  }

  return showDialog<void>(
      context: navigator.context,
      builder: (context) => AlertDialog(
            title: Text(timerName),
            content: Text(
                'Ya existe un temporizador con el mismo ID. ¿Quieres importar una copia de $timerName?'),
            actions: <Widget>[
              TextButton(
                child: Text('Omitir'),
                onPressed: () {
                  Navigator.of(context).pop(); // dismiss dialog
                },
              ),
              TextButton(
                child: Text('Importar copia'),
                onPressed: () async {
                  await onConfirm(); // execute callback
                  if (navigator.mounted) {
                    navigator.pop(); // dismiss dialog
                  }
                },
              ),
            ],
          ));
}
