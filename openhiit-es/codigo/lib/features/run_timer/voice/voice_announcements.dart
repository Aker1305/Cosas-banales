import 'package:background_hiit_timer/models/interval_type.dart';

/// Interval names that are not work intervals. Same list used by
/// generateIntervalDisplaysForTimer to decide what counts as "active".
const List<String> nonWorkIntervalNames = [
  "Rest",
  "Get Ready",
  "Warmup",
  "Cooldown",
  "Break",
];

/// Builds the Spanish text spoken at the start of each interval.
///
/// Terminology:
/// - "serie": one full pass of the block (timer restarts + 1).
/// - "tanda": one work interval inside a serie (timer activeIntervals).
///
/// Returns a map from interval index (position in [intervals]) to the text
/// to speak. Intervals without an entry are not announced.
Map<int, String> buildVoiceAnnouncements({
  required List<IntervalType> intervals,
  required int activeIntervalsPerSet,
  required int totalSets,
}) {
  final Map<int, String> announcements = {};
  if (activeIntervalsPerSet <= 0) return announcements;

  int workCount = 0;
  for (int i = 0; i < intervals.length; i++) {
    final String name = intervals[i].name;

    if (!nonWorkIntervalNames.contains(name)) {
      final int serie = workCount ~/ activeIntervalsPerSet + 1;
      final int tanda = workCount % activeIntervalsPerSet + 1;
      workCount++;
      announcements[i] = workAnnouncement(
        serie: serie,
        totalSets: totalSets,
        tanda: tanda,
        totalTandas: activeIntervalsPerSet,
      );
    } else if (name == "Break" && workCount > 0) {
      final int nextSerie = workCount ~/ activeIntervalsPerSet + 1;
      if (nextSerie <= totalSets) {
        announcements[i] =
            "Descanso. Siguiente: serie $nextSerie de $totalSets.";
      }
    }
  }

  return announcements;
}

String workAnnouncement({
  required int serie,
  required int totalSets,
  required int tanda,
  required int totalTandas,
}) {
  final String seriePart = "Serie $serie de $totalSets.";
  final String tandaPart = "Tanda $tanda de $totalTandas.";

  if (totalSets <= 1 && totalTandas <= 1) return "Adelante.";
  if (totalSets <= 1) return tandaPart;
  if (totalTandas <= 1) return seriePart;
  return "$seriePart $tandaPart";
}
