import 'package:flutter/material.dart';
// Import the TimerType model — adjust the path to match your project.
import 'package:openhiit/core/models/timer_type.dart';
import 'package:openhiit/features/import_export_timers/ui/snackbars.dart';
import 'package:openhiit/features/import_export_timers/utils/import_export_util.dart';

class ExportBottomSheet extends StatefulWidget {
  final List<TimerType> timers;

  const ExportBottomSheet({super.key, required this.timers});

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  bool exporting = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: exporting
                  ? null
                  : () async {
                      setState(() {
                        exporting = true;
                      });
                      try {
                        bool result = await ImportExportUtil.exportToDevice(
                          widget.timers,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            result
                                ? successSnackbar(
                                    'Temporizador(es) exportado(s) correctamente.')
                                : infoSnackbar('No se ha exportado nada.'),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            exporting = false;
                          });
                        }
                      }
                    },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text(
                        "Guardar en el dispositivo",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: exporting
                  ? null
                  : () async {
                      setState(() => exporting = true);
                      try {
                        final result =
                            await ImportExportUtil.share(widget.timers);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            result
                                ? successSnackbar('Temporizadores compartidos correctamente.')
                                : infoSnackbar('Compartir cancelado.'),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            errorSnackbar(
                                'Se ha producido un error al compartir los temporizadores.'),
                          );
                        }
                      } finally {
                        if (context.mounted) setState(() => exporting = false);
                      }
                    },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                child: Row(
                  children: [
                    Icon(Icons.share),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text(
                        "Compartir con otra app",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
