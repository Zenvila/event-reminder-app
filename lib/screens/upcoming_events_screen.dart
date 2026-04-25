import 'package:event_reminder_app/models/event.dart';
import 'package:event_reminder_app/providers/user_provider.dart';
import 'package:event_reminder_app/screens/create_event_screen.dart';
import 'package:event_reminder_app/services/event_storage_service.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:event_reminder_app/widgets/build_event_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class UpcomingEventScreenWidget extends StatefulWidget {
  const UpcomingEventScreenWidget({super.key});

  @override
  State<UpcomingEventScreenWidget> createState() =>
      _UpcomingEventScreenWidgetState();
}

class _UpcomingEventScreenWidgetState
    extends State<UpcomingEventScreenWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: 1);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final events = await EventStorageService.getEvents();
    if (mounted) {
      setState(() {
        _events = events;
        _loading = false;
      });
      _scheduleNotifications(events);
    }
  }

  Future<void> _scheduleNotifications(List<Event> events) async {
    for (final event in events) {
      if (!event.notificationEnabled || event.notificationId == null) continue;
      try {
        final date =
            DateFormat('EEEE, MMMM d, yyyy').parse(event.date);
        final time = _parseTime(event.time);
        if (time == null) continue;
        final combinedDateTime = DateTime(
          date.year, date.month, date.day,
          time.hour, time.minute,
        );
        final tzDateTime =
            tz.TZDateTime.from(combinedDateTime, tz.local);
        if (tzDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
          await scheduleNotification(
            id: event.notificationId!,
            title: event.title,
            body: 'ðŸ“ ${event.location}\nðŸ“ ${event.description}',
            scheduledDateTime: combinedDateTime,
          );
        }
      } catch (_) {}
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final format = DateFormat('h:mm a');
      final dt = format.parse(timeStr);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteEvent(Event event) async {
    if (event.notificationId != null) {
      await cancelNotification(event.notificationId!);
    }
    await EventStorageService.deleteEvent(event.eventID);
    await _loadEvents();
  }

  List<Event> get _upcomingEvents {
    final now = DateTime.now();
    return _events.where((e) {
      try {
        final date =
            DateFormat('EEEE, MMMM d, yyyy').parse(e.date);
        return date.isAfter(now) ||
            date.day == now.day &&
                date.month == now.month &&
                date.year == now.year;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  List<Event> get _pastEvents {
    final now = DateTime.now();
    return _events.where((e) {
      try {
        final date =
            DateFormat('EEEE, MMMM d, yyyy').parse(e.date);
        return date.isBefore(now);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Hello, ${user?.name ?? 'there'}! ðŸ‘‹'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(_events),
                _buildEventList(_upcomingEvents),
                _buildEventList(_pastEvents),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateEventScreen()),
          );
          _loadEvents();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildEventList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No events found',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return BuildEventCard(
            event: event,
            onDelete: () => _deleteEvent(event),
            onRefresh: _loadEvents,
          );
        },
      ),
    );
  }
}
