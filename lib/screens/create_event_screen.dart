import 'package:event_reminder_app/models/event.dart';
import 'package:event_reminder_app/services/event_storage_service.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String location = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool notificationEnabled = false;

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

    final combinedDateTime = DateTime(
      selectedDate!.year, selectedDate!.month, selectedDate!.day,
      selectedTime!.hour, selectedTime!.minute,
    );

    final tzDateTime =
        tz.TZDateTime.from(combinedDateTime, tz.local);
    if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot schedule an event in the past.')),
      );
      return;
    }

    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final notificationId =
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final newEvent = Event(
      eventID: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: dateFormat.format(combinedDateTime),
      time: timeFormat.format(combinedDateTime),
      location: location,
      description: description,
      notificationEnabled: notificationEnabled,
      notificationId: notificationEnabled ? notificationId : null,
    );

    await EventStorageService.addEvent(newEvent);

    if (notificationEnabled) {
      await scheduleNotification(
        id: notificationId,
        title: title,
        body: 'ðŸ“ $location\nðŸ“ $description',
        scheduledDateTime: combinedDateTime,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
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
              // Location
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSaved: (v) => location = v ?? '',
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
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
              // Date picker
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
              // Time picker
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
              // Notification toggle
              SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                title: const Text('Enable Notification'),
                subtitle: const Text('Get reminded before the event'),
                secondary:
                    const Icon(Icons.notifications, color: Colors.blue),
                value: notificationEnabled,
                onChanged: (v) =>
                    setState(() => notificationEnabled = v),
              ),
              const SizedBox(height: 24),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create Event',
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
