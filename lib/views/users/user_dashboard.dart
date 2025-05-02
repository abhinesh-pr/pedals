import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:pedals/views/users/user_profile.dart';
import 'dart:ui' as ui;
import '../../core/utils/constants.dart' as AppTheme;
import '../../services/cycle_services.dart';
import '../../viewmodels/cycle_slot_model.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDashboard extends StatefulWidget {
  final String? uemail;

  const UserDashboard({Key? key, required this.uemail}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboard();
}

class _UserDashboard extends State<UserDashboard>
    with TickerProviderStateMixin {
  String username = '';
  String userId = '';
  bool isLoading = true;
  bool isMapExpanded = false;

  // Selected pin state
  int? selectedPinIndex;

  // Service and streams
  final CycleService _cycleService = CycleService();
  final Map<int, Stream<List<CycleSlot>>> pinStreams = {};
  final Map<int, List<CycleSlot>> pinCycles = {};

  // UI Controllers
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _pulseController;
  late AnimationController _slideController;

  // Image handling
  ui.Image? _image;

  // Stand information mapping
  final Map<int, String> pinStandMap = {
    0: "STAND_A",
    1: "STAND_B",
    2: "STAND_C",
    3: "STAND_D",
    4: "STAND_E",
  };

  // Stand names for better UI display
  final Map<int, String> standNames = {
    0: "Main Gate",
    1: "Admission Block",
    2: "KG CAS/ KG IIM",
    3: "IT Tower",
    4: "KiTE",
  };

  // Pin coordinates on the map
  final List<Map<String, double>> pins = [
    {"x": 0.46, "y": 0.80},
    {"x": 0.53, "y": 0.67},
    {"x": 0.18, "y": 0.5},
    {"x": 0.2, "y": 0.4},
    {"x": 0.43, "y": 0.33},
  ];

  // Available cycles count for each stand
  final Map<int, int> availableCyclesCount = {};

  // UI visibility state
  bool showBottomSheet = false;

  @override
  void initState() {
    super.initState();
    _loadImage('assets/images/map.jpg');
    fetchUserData(widget.uemail ?? '');
    _initAnimationControllers();
    _initCycleStandData();

    // Start with animation to grab user attention
    Future.delayed(Duration(milliseconds: 300), () {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initAnimationControllers() {
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  void _initCycleStandData() {
    // Initialize data for all cycle stands
    pinStandMap.forEach((pinIndex, standId) {
      // Get real-time data streams for each stand
      final stream = _cycleService.getRealtimeSlots(standId);
      pinStreams[pinIndex] = stream;

      // Listen to updates for each stand
      stream.listen((cycles) {
        if (!mounted) return;
        setState(() {
          pinCycles[pinIndex] = cycles;

          // Count available cycles
          int availableCount =
              cycles
                  .where(
                    (cycle) =>
                        cycle.cycleIdApp.isNotEmpty &&
                        cycle.cycleStatus.toLowerCase() == "locked",
                  )
                  .length;

          availableCyclesCount[pinIndex] = availableCount;

          // Update bottom sheet if this stand is selected
          if (selectedPinIndex == pinIndex && showBottomSheet) {
            _updateBottomSheetData();
          }
        });
      });
    });
  }

  Future<void> fetchUserData(String email) async {
    try {
      final userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userDocId = userSnapshot.docs.first.id;
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userDocId)
                .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          if (mounted) {
            setState(() {
              username = data['fullName'] ?? '';
              userId = userDocId;
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      final image = await decodeImageFromList(data.buffer.asUint8List());
      if (!mounted) return;
      setState(() => _image = image);
    } catch (e) {
      print('Error loading map image: $e');
    }
  }

  void _handlePinTap(int index) {
    if (!mounted) return;
    setState(() {
      // Toggle selection if tapping the same pin
      if (selectedPinIndex == index && showBottomSheet) {
        _slideController.reverse().then((_) {
          setState(() {
            showBottomSheet = false;
            selectedPinIndex = null;
          });
        });
      } else {
        selectedPinIndex = index;
        showBottomSheet = true;
        _slideController.forward(); // Animate the bottom sheet in
      }
    });
  }

  void _updateBottomSheetData() {
    // This method can be used to refresh bottom sheet data when needed
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleMapExpansion() {
    setState(() {
      isMapExpanded = !isMapExpanded;
    });
  }

  void _handleUnlockCycle(CycleSlot cycle) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text("Unlock Cycle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Do you want to unlock cycle ${cycle.cycleIdApp}?"),
                SizedBox(height: 20),
                Text(
                  "You will be responsible for this cycle until you return it.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Unlock"),
                onPressed: () {
                  Navigator.pop(context);
                  _processUnlocking(cycle);
                },
              ),
            ],
          ),
    );
  }

  void _processUnlocking(CycleSlot cycle) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 20),
                  Text("Unlocking cycle..."),
                ],
              ),
            ),
          ),
    );

    // Call the actual service
    Future.delayed(Duration(seconds: 2), () {
      _cycleService.unlockCycle(standId: cycle.standId, slotId: cycle.slotId);

      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Cycle unlocked successfully!"),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  Widget _buildPinMarker(int index, double displayWidth, double displayHeight) {
    final pin = pins[index];
    final left = pin["x"]! * displayWidth;
    final top = pin["y"]! * displayHeight;
    final cycleCount = availableCyclesCount[index] ?? 0;
    final isSelected = selectedPinIndex == index;

    return Positioned(
      left: left - 20,
      top: top - 45,
      child: GestureDetector(
        onTap: () => _handlePinTap(index),
        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isSelected ? 60 : 30,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Pin icon
                  Icon(
                    Icons.location_on,
                    color: isSelected ? AppTheme.primaryColor : Colors.red[400],
                    size: isSelected ? 40 : 30,
                  ),

                  // Available cycle count badge
                  Positioned(
                    top: 2,
                    right: isSelected ? 2 : 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cycleCount > 0 ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        "$cycleCount",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stand name label
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 10),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                standNames[index] ?? "Stand ${index + 1}",
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleCard(CycleSlot cycle) {
    final isLocked = cycle.cycleStatus.toLowerCase() == "locked";
    final bikeName = cycle.cycleIdApp
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.length > 0
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Bike icon with animation if available
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isLocked ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                    isLocked
                        ? AnimatedBikeIcon(
                          size: 40,
                          color: AppTheme.primaryColor,
                        )
                        : Icon(Icons.pedal_bike, size: 32, color: Colors.grey),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bikeName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Slot #${cycle.slotId}",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          isLocked
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLocked ? Icons.lock : Icons.lock_open,
                          size: 12,
                          color: isLocked ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          isLocked ? "Available" : "In Use",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isLocked ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              ElevatedButton(
                onPressed: () => _handleUnlockCycle(cycle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: Text("Unlock"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (selectedPinIndex == null) return SizedBox.shrink();

    final cycles = pinCycles[selectedPinIndex] ?? [];
    final standName =
        standNames[selectedPinIndex] ?? "Stand ${selectedPinIndex! + 1}";

    // Filter cycles that have IDs (real cycles) and sort by slot ID
    final availableCycles =
        cycles
            .where(
              (cycle) =>
                  cycle.cycleIdApp.isNotEmpty &&
                  cycle.cycleStatus.toLowerCase() == "locked",
            )
            .toList()
          ..sort((a, b) => a.slotId.compareTo(b.slotId));

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1.0 - _slideController.value) * 200),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bottom sheet handle bar
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Stand information header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              standName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "Available: ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "${availableCycles.length} cycles",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        availableCycles.isEmpty
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _slideController.reverse().then((_) {
                              setState(() {
                                showBottomSheet = false;
                                selectedPinIndex = null;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),

                  Divider(height: 1),

                  // Available cycles list
                  if (availableCycles.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pedal_bike,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 15),
                          Text(
                            "No cycles available at this stand",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Please check other stands or try again later",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        shrinkWrap: true,
                        children:
                            availableCycles
                                .map((cycle) => _buildCycleCard(cycle))
                                .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 20),
              Text(
                "Loading campus map...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final aspectRatio = _image!.width / _image!.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.pedal_bike, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              "Pedals",
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              // Simulate refresh
              setState(() {
                isLoading = true;
              });

              Future.delayed(Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Data refreshed"),
                      backgroundColor: AppTheme.primaryColor,
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.account_circle_outlined, color: Colors.black87),
                if (username.isNotEmpty)
                  Positioned(
                    right: 30,
                    bottom: 5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Get.to(ProfilePage()),
          ),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomReset',
            mini: true,
            backgroundColor: Colors.white,
            onPressed:
                () => _transformationController.value = Matrix4.identity(),
            child: Icon(Icons.zoom_out_map, color: Colors.black87),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : Stack(
                children: [
                  // Header summary
                  if (!isMapExpanded)
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // Align text to the center
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Hello, ${username.split(' ').first}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Find and unlock available cycles around campus",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Main content
                  Container(
                    child: Column(
                      children: [
                        // Map container
                        Expanded(
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    // Map with interactive zooming
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 300),

                                      child: Center(
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            child: Stack(
                                              children: [
                                                InteractiveViewer(
                                                  transformationController:
                                                      _transformationController,
                                                  minScale: 1.0,
                                                  maxScale: 4.0,
                                                  child: Stack(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/map.jpg',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                      ),
                                                      LayoutBuilder(
                                                        builder: (
                                                          context,
                                                          constraints,
                                                        ) {
                                                          final displayWidth =
                                                              constraints
                                                                  .maxWidth;
                                                          final displayHeight =
                                                              displayWidth /
                                                              aspectRatio;

                                                          return SizedBox(
                                                            width: displayWidth,
                                                            height:
                                                                displayHeight,
                                                            child: Stack(
                                                              children:
                                                                  pins
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                        (
                                                                          entry,
                                                                        ) => _buildPinMarker(
                                                                          entry
                                                                              .key,
                                                                          displayWidth,
                                                                          displayHeight,
                                                                        ),
                                                                      )
                                                                      .toList(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Help instruction overlay
                                    if (selectedPinIndex == null)
                                      Positioned(
                                        bottom: 140,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: AnimatedBuilder(
                                            animation: _pulseController,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale:
                                                    1.0 +
                                                    (_pulseController.value *
                                                        0.05),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),

                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.touch_app,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Tap on a pin to see available cycles",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                    // Map controls overlay
                                    Positioned(
                                      bottom: 70,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.black87,
                                              ),
                                              onPressed: () {
                                                final current =
                                                    _transformationController
                                                        .value;
                                                final scale =
                                                    current.getMaxScaleOnAxis();
                                                if (scale < 4.0) {
                                                  _transformationController
                                                          .value =
                                                      Matrix4.diagonal3Values(
                                                        scale + 0.5,
                                                        scale + 0.5,
                                                        1,
                                                      );
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove,
                                                color: Colors.black87,
                                              ),
                                              onPressed: () {
                                                final current =
                                                    _transformationController
                                                        .value;
                                                final scale =
                                                    current.getMaxScaleOnAxis();
                                                if (scale > 1.0) {
                                                  _transformationController
                                                          .value =
                                                      Matrix4.diagonal3Values(
                                                        scale - 0.5,
                                                        scale - 0.5,
                                                        1,
                                                      );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 500,
                    child: AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0, (1.0 - _slideController.value) * 200,
                          ),
                          child: Opacity(
                            opacity: _slideController.value,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 12, bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Everything else you already had here
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  // Don't forget this closing brace for the State class
}

class _buildStandDetailsWidget {} // End of _UserDashboard class

class AnimatedBikeIcon extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedBikeIcon({Key? key, this.size = 40.0, this.color = Colors.blue})
    : super(key: key);

  @override
  _AnimatedBikeIconState createState() => _AnimatedBikeIconState();
}

class _AnimatedBikeIconState extends State<AnimatedBikeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(Icons.pedal_bike, size: widget.size, color: widget.color),
    );
  }
}
