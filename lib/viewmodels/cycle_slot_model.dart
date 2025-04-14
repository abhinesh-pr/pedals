class CycleSlot {
  final String cycleId;
  final String cycleStatus;
  final int slotId;
  final String standId;
  final String standStatus;
  final String workId;

  CycleSlot({
    required this.cycleId,
    required this.cycleStatus,
    required this.slotId,
    required this.standId,
    required this.standStatus,
    required this.workId,
  });

  factory CycleSlot.fromJson(String slotId, Map<dynamic, dynamic> json) {
    return CycleSlot(
      cycleId: json['CYCLE_ID'] ?? '',
      cycleStatus: json['CYCLE_STATUS'] ?? '',
      slotId: json['SLOT_ID'] ?? 0,
      standId: json['STAND_ID'] ?? '',
      standStatus: json['STAND_STATUS'] ?? '',
      workId: json['WORK_ID'] ?? '',
    );
  }
}


