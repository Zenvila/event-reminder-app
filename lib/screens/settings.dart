import 'package:eventora_planner/providers/theme_provider.dart';
import 'package:eventora_planner/providers/user_provider.dart';
import 'package:eventora_planner/services/auth_service.dart';
import 'package:eventora_planner/services/event_storage_service.dart';
import 'package:eventora_planner/services/notification_services.dart';
import 'package:eventora_planner/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  Future<void> _toggleNotifications(bool value) async {
    setState(() => notificationsEnabled = value);
    if (!value) {
      await flutterLocalNotificationsPlugin.cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications disabled.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications enabled.')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      if (!mounted) return;
      try {
        await AuthService.signOut();
      } catch (_) {
        // Ignore sign-out backend errors to avoid blocking local sign-out.
      }
      if (!mounted) return;
      context.read<UserProvider>().clearUser();
      await flutterLocalNotificationsPlugin.cancelAll();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/auth', (route) => false);
      }
    }
  }

  Future<void> _clearAllEvents() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Events'),
        content: const Text(
            'This will delete all your events. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final events = await EventStorageService.getEvents();
      for (final e in events) {
        if (e.notificationId != null) {
          await cancelNotification(e.notificationId!);
        }
      }
      await EventStorageService.saveEvents([]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All events cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      user?.name?.isNotEmpty == true
                          ? user!.name![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'User',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      if (user?.email?.isNotEmpty == true)
                        Text(user!.email!,
                            style: TextStyle(
                                color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme toggle
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              secondary: const Icon(Icons.dark_mode),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (v) => themeProvider.toggleTheme(v),
            ),
          ),
          const SizedBox(height: 12),

          // Notifications toggle
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable or disable all notifications'),
              secondary: const Icon(Icons.notifications),
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          const SizedBox(height: 12),

          // Clear events
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.orange),
              title: const Text('Clear All Events'),
              subtitle: const Text('Delete all saved events'),
              onTap: _clearAllEvents,
            ),
          ),
          const SizedBox(height: 12),

          // Sign out
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out',
                  style: TextStyle(color: Colors.red)),
              onTap: _signOut,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
