import 'package:firebase_database/firebase_database.dart';
import '../viewmodels/cycle_slot_model.dart';

class CycleService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();


  Future<void> unlockCycle({required String standId, required int slotId}) async {
    final ref = FirebaseDatabase.instance.ref('CYCLES/STAND_$standId/SLOT_$slotId');

    // Unlock the cycle first
    await ref.update({
      "CYCLE_STATUS": "UNLOCKED",
    });

    // Add a delay of 5 seconds before nullifying the CYCLE_ID
    await Future.delayed(const Duration(seconds: 5));

    // Now set CYCLE_ID to empty string after 5 seconds
    await ref.update({
      "CYCLE_ID": "",
    });
  }



  Stream<List<CycleSlot>> getRealtimeSlots(String standId) {
    return _dbRef.child("CYCLES").child(standId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries.map((e) {
        return CycleSlot.fromJson(e.key.toString(), Map<String, dynamic>.from(e.value));
      }).toList();
    });
  }
}
