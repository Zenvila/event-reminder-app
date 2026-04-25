import 'package:eventora_planner/models/event.dart';
import 'package:eventora_planner/services/event_storage_service.dart';
import 'package:eventora_planner/widgets/bottom_nav_bar.dart';
import 'package:eventora_planner/widgets/appbar.dart';
import 'package:eventora_planner/widgets/build_event_card.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calenderscreen extends StatefulWidget {
  const Calenderscreen({super.key});

  static const String routeName = 'CALENDER';
  static const String routePath = '/calender';

  @override
  State<Calenderscreen> createState() => _CalenderScreen();
}

class _CalenderScreen extends State<Calenderscreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Event> _allEvents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay!;
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {
          _calendarFormat = _tabController.index == 0
              ? CalendarFormat.month
              : CalendarFormat.week;
        });
      });
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
        _allEvents = events;
        _loading = false;
      });
    }
  }

  List<Event> _eventsForDay(DateTime? day) {
    if (day == null) return [];
    final formatted = _formatDateToString(day);
    return _allEvents.where((e) => e.date == formatted).toList();
  }

  String _formatDateToString(DateTime? date) {
    if (date == null) return '';
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];
    return '$dayName, $monthName ${date.day}, ${date.year}';
  }

  Future<void> _deleteEvent(Event event) async {
    await EventStorageService.deleteEvent(event.eventID);
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: buildAppBar('Calendar', context),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor:
                    Theme.of(context).textTheme.bodyLarge?.color,
                unselectedLabelColor:
                    Theme.of(context).textTheme.bodyMedium?.color,
                indicator: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Theme.of(context).dividerColor),
                ),
                tabs: const [
                  Tab(text: 'Month'),
                  Tab(text: 'Week')
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCalendarView(context),
                        _buildCalendarView(context),
                      ],
                    ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final selectedEvents = _eventsForDay(_selectedDay);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Theme.of(context)
                      .shadowColor
                      .withValues(alpha: 0.12),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day),
              eventLoader: _eventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context)
                      .primaryColor
                      .withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
            child: Text(
              'Events on ${_formatDateToString(_selectedDay)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(
                      fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          if (selectedEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No events on this day.',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                final event = selectedEvents[index];
                return BuildEventCard(
                  event: event,
                  onDelete: () => _deleteEvent(event),
                  onRefresh: _loadEvents,
                );
              },
            ),
        ],
      ),
    );
  }
}