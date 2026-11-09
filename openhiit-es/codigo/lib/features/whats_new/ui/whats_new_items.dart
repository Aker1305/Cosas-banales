import 'package:flutter/material.dart';
import 'package:openhiit/features/whats_new/models/whats_new_item.dart';

class WhatsNewData {
  static const version = "1.7.0";

  static final List<WhatsNewItem> items = [
    WhatsNewItem(
      title: "Deslizar para eliminar",
      description: "Elimina temporizadores deslizando hacia la izquierda.",
      icon: Icons.swipe_left,
    ),
    WhatsNewItem(
      title: "Sonido de descanso largo",
      description: "Elige un sonido propio para el descanso largo.",
      icon: Icons.music_note,
    ),
    WhatsNewItem(
      title: "Página de ajustes",
      description: "Ajusta las preferencias y el aspecto de la app.",
      icon: Icons.settings,
    ),
  ];
}
