import 'package:flutter_test/flutter_test.dart';
import 'package:openhiit/core/models/timer_sound_settings.dart';
import 'package:openhiit/core/models/timer_time_settings.dart';
import 'package:openhiit/core/models/timer_type.dart';
import 'package:openhiit/core/utils/interval_calculation.dart';
import 'package:openhiit/features/run_timer/voice/voice_announcements.dart';

TimerType _timer({
  required int activeIntervals,
  required int restarts,
  int breakTime = 0,
  int warmupTime = 0,
  int cooldownTime = 0,
  int getReadyTime = 10,
}) {
  final time = TimerTimeSettings.empty()
    ..workTime = 20
    ..restTime = 10
    ..breakTime = breakTime
    ..warmupTime = warmupTime
    ..cooldownTime = cooldownTime
    ..getReadyTime = getReadyTime
    ..restarts = restarts;
  return TimerType(
    id: 't',
    name: 'test',
    timerIndex: 0,
    timeSettings: time,
    soundSettings: TimerSoundSettings.empty(),
    activeIntervals: activeIntervals,
  );
}

Map<int, String> _build(TimerType t) => buildVoiceAnnouncements(
      intervals: generateIntervalsFromTimer(t),
      activeIntervalsPerSet: t.activeIntervals,
      totalSets: t.timeSettings.restarts + 1,
    );

void main() {
  test('announces serie and tanda on each work interval', () {
    final t = _timer(activeIntervals: 3, restarts: 1, breakTime: 30);
    final intervals = generateIntervalsFromTimer(t);
    final a = _build(t);

    final spoken = [
      for (int i = 0; i < intervals.length; i++)
        if (a.containsKey(i)) '${intervals[i].name}: ${a[i]}'
    ];

    expect(spoken, [
      'Work: Serie 1 de 2. Tanda 1 de 3.',
      'Work: Serie 1 de 2. Tanda 2 de 3.',
      'Work: Serie 1 de 2. Tanda 3 de 3.',
      'Break: Descanso. Siguiente: serie 2 de 2.',
      'Work: Serie 2 de 2. Tanda 1 de 3.',
      'Work: Serie 2 de 2. Tanda 2 de 3.',
      'Work: Serie 2 de 2. Tanda 3 de 3.',
    ]);
  });

  test('warmup, rest, cooldown and get ready are not announced', () {
    final t = _timer(
        activeIntervals: 2, restarts: 0, warmupTime: 30, cooldownTime: 30);
    final intervals = generateIntervalsFromTimer(t);
    final a = _build(t);

    for (final entry in a.entries) {
      expect(nonWorkIntervalNames.contains(intervals[entry.key].name), false);
    }
    expect(a.values.toList(), ['Tanda 1 de 2.', 'Tanda 2 de 2.']);
  });

  test('custom activity names are announced as work', () {
    final t = _timer(activeIntervals: 2, restarts: 1)
      ..activities = ['Burpees', 'Sentadillas'];
    final a = _build(t);
    expect(a.values.toList(), [
      'Serie 1 de 2. Tanda 1 de 2.',
      'Serie 1 de 2. Tanda 2 de 2.',
      'Serie 2 de 2. Tanda 1 de 2.',
      'Serie 2 de 2. Tanda 2 de 2.',
    ]);
  });

  test('workAnnouncement short forms', () {
    expect(
        workAnnouncement(serie: 2, totalSets: 4, tanda: 1, totalTandas: 1),
        'Serie 2 de 4.');
    expect(
        workAnnouncement(serie: 1, totalSets: 1, tanda: 1, totalTandas: 1),
        'Adelante.');
  });
}
