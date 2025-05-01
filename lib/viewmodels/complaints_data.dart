// lib/models/complaint_data.dart
class ComplaintData {
  static const List<String> categories = [
    "Cycle Related",
    "Stand/Slot",
    "Locking/Unlocking",
    "Application Related",
    "Others"
  ];

  static const Map<String, List<String>> servicesByCategory = {
    "Cycle Related": [
      "Cycle Not Available",
      "Flat Tyre",
      "Chain Problem",
      "Brake Issue",
    ],
    "Stand/Slot": [
      "Slot Not Working",
      "Stand Power Issue",
      "Stand Network Issue",
    ],
    "Locking/Unlocking": [
      "Cycle Not Locking",
      "Cycle Not Unlocking",
      "Lock Mechanism Jammed",
    ],
    "Application Related": [
      "App Crash",
      "Login Issue",
    ],
    "Others": [
      "Other Issues",
    ],
  };
}
