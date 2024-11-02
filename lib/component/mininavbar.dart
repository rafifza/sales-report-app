import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class MiniNavbar extends StatefulWidget {
  const MiniNavbar({
    super.key,
    required this.onActivitySelected,
  });

  final void Function(String activity) onActivitySelected;

  @override
  MiniNavbarState createState() => MiniNavbarState();
}

class MiniNavbarState extends State<MiniNavbar> {
  String? _activeActivity; // Variable to keep track of the active activity

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double itemWidth = (constraints.maxWidth - 32) / 4;
          double itemHeight = itemWidth; // Ensures buttons are square-shaped.
          return SizedBox(
            height: itemHeight * 2 + 36,
            child: Align(
              alignment: Alignment.topCenter,
              child: GridView.count(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                shrinkWrap: false,
                crossAxisCount: 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildButtonTile(Icons.login, 'Check In'),
                  _buildButtonTile(Icons.logout, 'Check Out'),

                  _buildButtonTile(Icons.event, 'Aktivitas Hari Ini'),
                  _buildButtonTile(Icons.schedule, 'Aktivitas Kedepan'),
                  _buildButtonTile(Icons.list, 'Daftar Prospek'),
                  _buildButtonTile(Icons.history, 'History Absen'),
                  _buildButtonTile(
                      Icons.history_toggle_off, 'History Aktivitas'),
                  _buildStaticButtonTile(Icons.person_outline,
                      'History Nasabah'), // Static button without active state
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonTile(IconData iconData, String label) {
    bool isActive = _activeActivity == label; // Check if this button is active

    return ElevatedButton(
      onPressed: () {
        setState(() {
          // Toggle the active activity state, ensuring "History Nasabah" doesn't become active
          _activeActivity =
              _activeActivity == label ? null : label; // Toggle active state
        });
        widget.onActivitySelected(label);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isActive
            ? Colors.blue
            : Colors.lightBlue[100], // Change color if active
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 32,
            color: isActive
                ? Colors.white
                : Colors.black, // Change icon color if active
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 20,
            child: TextScroll(
              label,
              mode: TextScrollMode.endless,
              velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? Colors.white
                    : Colors.black87, // Use variable for active state
              ),
              textAlign: TextAlign.center,
              pauseBetween: const Duration(seconds: 2),
            ),
          ),
        ],
      ),
    );
  }

  // This method ensures History Nasabah button remains static and cannot become active
  Widget _buildStaticButtonTile(IconData iconData, String label) {
    return ElevatedButton(
      onPressed: () {
        widget.onActivitySelected(label);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.lightBlue[100], // Static color
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 32,
            color: Colors.black, // Static icon color
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 20,
            child: TextScroll(
              label,
              mode: TextScrollMode.endless,
              velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87, // Static color
              ),
              textAlign: TextAlign.center,
              pauseBetween: const Duration(seconds: 2),
            ),
          ),
        ],
      ),
    );
  }
}
