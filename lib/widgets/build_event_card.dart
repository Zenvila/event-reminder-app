import 'package:event_reminder_app/models/event.dart';
import 'package:event_reminder_app/screens/edit_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String calculateRemainingTime(Event event, {bool returnStatus = false}) {
  try {
    final parsedDate =
        DateFormat('EEEE, MMMM d, yyyy').parse(event.date);
    final cleaned = event.time
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final parts = cleaned.split(' ');
    if (parts.length != 2) throw FormatException('Invalid time');
    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) throw FormatException('Invalid time');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final period = parts[1].toUpperCase();
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    final eventDateTime = DateTime(
      parsedDate.year, parsedDate.month, parsedDate.day,
      hour, minute,
    );
    final diff = eventDateTime.difference(DateTime.now());

    if (returnStatus) {
      if (diff.isNegative) return 'passed';
      if (diff.inMinutes < 60) return 'near';
      if (diff.inHours < 24) return 'soon';
      return 'future';
    }

    if (diff.isNegative) return 'Passed';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return '< 1 min left';
  } catch (_) {
    return 'TBC';
  }
}

class BuildEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const BuildEventCard({
    super.key,
    required this.event,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final remainingTime = calculateRemainingTime(event);
    final status = calculateRemainingTime(event, returnStatus: true);

    final Color timeColor;
    switch (status) {
      case 'passed':
        timeColor = Colors.grey;
        break;
      case 'near':
        timeColor = Colors.orange;
        break;
      case 'soon':
        timeColor =
            Theme.of(context).colorScheme.primary.withOpacity(0.7);
        break;
      default:
        timeColor = Theme.of(context).primaryColor;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time badge
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: timeColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(remainingTime,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 20),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditEventScreen(event: event),
                          ),
                        );
                        if (result == true) onRefresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Event'),
                            content: const Text(
                                'Are you sure you want to delete this event?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: const Text('Delete',
                                    style:
                                        TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) onDelete();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                        fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _row(context, Icons.calendar_today_rounded, event.date),
            const SizedBox(height: 4),
            _row(context, Icons.access_time_rounded, event.time),
            const SizedBox(height: 4),
            _row(context, Icons.location_on_outlined, event.location),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              _row(context, Icons.notes, event.description),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}