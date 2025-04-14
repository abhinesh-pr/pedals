// import 'package:flutter/material.dart';
// import '../services/cycle_services.dart';
// import '../viewmodels/cycle_slot_model.dart';
//
// class StandController with ChangeNotifier {
//   final StandService _standService = StandService();
//
//   Stand? _stand;
//   bool _isLoading = false;
//   String? _error;
//
//   Stand? get stand => _stand;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   Future<void> loadStand(String standKey) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final fetchedStand = await _standService.fetchStand(standKey);
//
//       if (fetchedStand != null) {
//         _stand = fetchedStand;
//       } else {
//         _error = "Stand not found.";
//       }
//     } catch (e) {
//       _error = e.toString();
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   void clear() {
//     _stand = null;
//     _error = null;
//     _isLoading = false;
//     notifyListeners();
//   }
// }
