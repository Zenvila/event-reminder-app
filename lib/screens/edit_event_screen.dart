import 'package:event_reminder_app/models/event.dart';
import 'package:event_reminder_app/services/event_storage_service.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String location;
  late String description;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late bool notificationEnabled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    title = widget.event.title;
    location = widget.event.location;
    description = widget.event.description;
    notificationEnabled = widget.event.notificationEnabled;
    selectedDate = _parseDate(widget.event.date);
    selectedTime = _parseTime(widget.event.time);
    selectedDate ??= DateTime.now();
    selectedTime ??= TimeOfDay.now();
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('EEEE, MMMM d, yyyy').parse(dateStr.trim());
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final cleaned = timeStr
          .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final parts = cleaned.split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all required fields.')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final combinedDateTime = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day,
        selectedTime!.hour, selectedTime!.minute,
      );

      final formattedDate =
          DateFormat('EEEE, MMMM d, yyyy').format(combinedDateTime);
      final formattedTime =
          DateFormat('h:mm a').format(combinedDateTime);

      int? notificationId = widget.event.notificationId;
      if (notificationEnabled && notificationId == null) {
        notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }

      // Cancel old notification if exists
      if (widget.event.notificationId != null) {
        await cancelNotification(widget.event.notificationId!);
      }

      final updatedEvent = Event(
        eventID: widget.event.eventID,
        title: title,
        date: formattedDate,
        time: formattedTime,
        location: location,
        description: description,
        notificationEnabled: notificationEnabled,
        notificationId: notificationEnabled ? notificationId : null,
      );

      await EventStorageService.updateEvent(updatedEvent);

      if (notificationEnabled && notificationId != null) {
        await scheduleNotification(
          id: notificationId,
          title: title,
          body: 'ðŸ“ $location\nðŸ“ $description',
          scheduledDateTime: combinedDateTime,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Event updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Title is required' : null,
                onSaved: (v) => title = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: location,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSaved: (v) => location = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                onSaved: (v) => description = v ?? '',
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                leading: const Icon(Icons.calendar_today,
                    color: Colors.blue),
                title: Text(selectedDate == null
                    ? 'Select Date *'
                    : DateFormat('EEEE, MMMM d, yyyy')
                        .format(selectedDate!)),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                leading: const Icon(Icons.access_time,
                    color: Colors.blue),
                title: Text(selectedTime == null
                    ? 'Select Time *'
                    : selectedTime!.format(context)),
                onTap: _pickTime,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                title: const Text('Enable Notification'),
                secondary: const Icon(Icons.notifications,
                    color: Colors.blue),
                value: notificationEnabled,
                onChanged: (v) =>
                    setState(() => notificationEnabled = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Update Event',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
