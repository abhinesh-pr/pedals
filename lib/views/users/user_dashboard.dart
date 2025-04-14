import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import '../../services/cycle_services.dart';
import '../../viewmodels/cycle_slot_model.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  int? selectedPinIndex;
  final CycleService _cycleService = CycleService();
  Stream<List<CycleSlot>>? _cycleStream;
  List<CycleSlot> fetchedCycles = [];
  final Map<int, List<CycleSlot>> pinCycles = {};
  final Map<int, Stream<List<CycleSlot>>> pinStreams = {};
  ui.Image? _image;
  final TransformationController _transformationController = TransformationController();

  final Map<int, String> pinStandMap = {
    0: "STAND_A",
    1: "STAND_B",
    2: "STAND_C",
    3: "STAND_D",
    4: "STAND_E",
    5: "STAND_F",
  };


  // Pins in normalized image coordinates (0.0 to 1.0)
  final List<Map<String, double>> pins = [
    {"x": 0.08, "y": 0.45},
    {"x": 0.43, "y": 0.98},
    {"x": 0.53, "y": 0.67},
    {"x": 0.65, "y": 0.3},
    {"x": 0.58, "y": 0.55},
    {"x": 0.30, "y": 0.80},
  ];

  // Map to track which pins have their message shown
  final Map<int, bool> pinMessageVisibility = {};

  @override
  void initState() {
    super.initState();
    _loadImage('assets/images/map.jpg');

    // Listen STAND_A-F cycles (Pin 1-6)
    pinStandMap.forEach((pinIndex, standId) {
      final stream = _cycleService.getRealtimeSlots(standId);
      pinStreams[pinIndex] = stream;
      stream.listen((cycles) {
        if (!mounted) return;
        setState(() {
          pinCycles[pinIndex] = cycles;
          if (pinMessageVisibility[pinIndex] == true) {
            selectedMessage = _formatCycleMessage(cycles, standId);
          }
        });
      });
    });
  }

  String _formatCycleMessage(List<CycleSlot> cycles, String standId) {
    if (cycles.isEmpty) {
      return "No cycles available at $standId.";
    }
    return cycles.map((cycle) =>
    "Slot ${cycle.slotId}: ${cycle.cycleId} - ${cycle.cycleStatus}").join("\n");
  }


  Future<void> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final image = await decodeImageFromList(data.buffer.asUint8List());
    if (!mounted) return;
    setState(() => _image = image);
  }

  String? selectedMessage;
  bool showMessage = false;

  final List<String> pinMessages = [
    "This is a detailed paragraph for Pin 1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "Information about Pin 2: This location is significant for historical reasons.",
    "Pin 3 represents a key location in our tour plan. It is a central hub.",
    "This is Pin 4. Known for its scenic beauty and cultural importance.",
    "Pin 5 is an important checkpoint. Don’t miss the nearby attractions.",
    "Final Pin 6. Often visited for its peaceful environment and accessibility.",
  ];

  final List<String> pinLabels = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
  ];

  List<Widget> _buildCycleCards(List<CycleSlot> cycles) {
    final filteredCycles = cycles.where((cycle) => cycle.cycleId.isNotEmpty).toList();
    filteredCycles.sort((a, b) => a.slotId.compareTo(b.slotId));

    return filteredCycles.map((cycle) {
      final isLocked = cycle.cycleStatus.toLowerCase() == "locked";

      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.pedal_bike),
          title: Text(cycle.cycleId.replaceAll('_', ' ')),
          subtitle: Text("Slot : ${cycle.slotId}"),
          trailing: ElevatedButton.icon(
            icon: Icon(isLocked ? Icons.lock : Icons.lock_open),
            label: Text(isLocked ? "Locked" : "Unlocked"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked ? Colors.redAccent : Colors.green,
            ),
            onPressed: () {
              if (!isLocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You cannot lock the cycle through app for now"),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                _cycleService.unlockCycle(
                  standId: cycle.standId,
                  slotId: cycle.slotId,
                );
              }
            },
          ),
        ),
      );
    }).toList();
  }





  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final aspectRatio = _image!.width / _image!.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Zoomable Image'),
        backgroundColor: Colors.blueAccent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final containerHeight = constraints.maxHeight;

          const double horizontalPadding = 20.0;
          final availableWidth = containerWidth - (2 * horizontalPadding);

          double displayWidth = availableWidth;
          double displayHeight = availableWidth / aspectRatio;

          if (displayHeight > containerHeight * 0.6) {
            displayHeight = containerHeight * 0.6;
            displayWidth = displayHeight * aspectRatio;
          }

          final double centerY = (containerHeight - displayHeight) / 2;
          final double targetTop = 40.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        top: showMessage ? targetTop : centerY,
                        left: (containerWidth - displayWidth) / 2 - horizontalPadding,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: InteractiveViewer(
                                transformationController: _transformationController,
                                minScale: 1.0,
                                maxScale: 5.0,
                                clipBehavior: Clip.hardEdge,
                                panEnabled: true,
                                constrained: true,
                                boundaryMargin: const EdgeInsets.all(0),
                                child: SizedBox(
                                  width: displayWidth,
                                  height: displayHeight,
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/images/map.jpg',
                                        width: displayWidth,
                                        height: displayHeight,
                                        fit: BoxFit.fill,
                                      ),
                                      ...pins.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        Map<String, double> pin = entry.value;
                                        final left = pin["x"]! * displayWidth;
                                        final top = pin["y"]! * displayHeight;
                                        return Positioned(
                                          left: left - 18,
                                          top: top - 36,
                                          child: GestureDetector(
                                              onTap: () {
                                                if (!mounted) return;
                                                setState(() {
                                                  final isVisible = pinMessageVisibility[index] ?? false;
                                                  pinMessageVisibility[index] = !isVisible;
                                                  showMessage = !isVisible;

                                                  if (showMessage) {
                                                    selectedPinIndex = index;
                                                    final standId = pinStandMap[index]!;
                                                    final cycles = pinCycles[index] ?? [];
                                                    selectedMessage = _formatCycleMessage(cycles, standId);
                                                  } else {
                                                    selectedMessage = null;
                                                    selectedPinIndex = null;
                                                  }
                                                });
                                              },

                                              child: Column(
                                              children: [
                                                Icon(Icons.location_on, color: Colors.red, size: 36),
                                                const SizedBox(height: 1),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.5), // Semi-transparent background
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    pinLabels[index], // Add label
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: showMessage ? 1.0 : 0.0,
                              child: selectedPinIndex != null
                                  ? Container(
                                width: displayWidth,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Available Cycles:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ..._buildCycleCards(pinCycles[selectedPinIndex] ?? []),
                                  ],
                                ),
                              )
                                  : const SizedBox(),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
