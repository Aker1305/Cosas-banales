/// Spanish labels for the built-in interval names.
///
/// The English names ("Work", "Rest", ...) are internal keys: they are stored
/// in the database, compared in the timer logic and used by the timer
/// package. Only convert them for display; never store the result.
const Map<String, String> _intervalDisplayNames = {
  "work": "Trabajo",
  "rest": "Descanso",
  "get ready": "Preparación",
  "warmup": "Calentamiento",
  "cooldown": "Enfriamiento",
  "break": "Descanso largo",
};

/// Returns the Spanish label for a built-in interval name, or [name]
/// unchanged when it is a custom exercise name typed by the user.
String displayIntervalName(String name) =>
    _intervalDisplayNames[name.toLowerCase()] ?? name;
