import 'package:event_reminder_app/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:event_reminder_app/screens/calender_screen.dart';
import 'package:event_reminder_app/screens/upcoming_events_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void onItemTapped(int index, BuildContext context) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UpcomingEventScreenWidget()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Calenderscreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabledColor = Theme.of(context).primaryColor;
    final disabledColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color.fromARGB(26, 0, 0, 0),
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Events Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onItemTapped(0, context),
                  icon: Icon(
                    Icons.event_note_rounded,
                    color: currentIndex == 0 ? enabledColor : disabledColor,
                    size: 28,
                  ),
                ),
                Text(
                  'Events',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: currentIndex == 0 ? enabledColor : disabledColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Calendar Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onItemTapped(1, context),
                  icon: Icon(
                    Icons.calendar_today_rounded,
                    color: currentIndex == 1 ? enabledColor : disabledColor,
                    size: 28,
                  ),
                ),
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: currentIndex == 1 ? enabledColor : disabledColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Settings Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onItemTapped(2, context),
                  icon: Icon(
                    Icons.settings_outlined,
                    color: currentIndex == 2 ? enabledColor : disabledColor,
                    size: 28,
                  ),
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: currentIndex == 2 ? enabledColor : disabledColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
