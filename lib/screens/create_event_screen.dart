import 'package:eventora_planner/models/event.dart';
import 'package:eventora_planner/services/event_storage_service.dart';
import 'package:eventora_planner/services/gemini_event_parser_service.dart';
import 'package:eventora_planner/services/notification_services.dart';
import 'package:eventora_planner/widgets/bottom_nav_bar.dart';
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
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _aiPromptController = TextEditingController();
  String title = '';
  String location = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool notificationEnabled = false;
  bool _isAiLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _aiPromptController.dispose();
    super.dispose();
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
    title = _titleController.text.trim();
    location = _locationController.text.trim();
    description = _descriptionController.text.trim();

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
        body: 'Location: $location\nNotes: $description',
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

  Future<void> _generateFromAi() async {
    if (_isAiLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _isAiLoading = true);

    try {
      final draft = await GeminiEventParserService.parseEventText(
        _aiPromptController.text,
      );
      if (!mounted) return;
      setState(() {
        _titleController.text = draft.title;
        _locationController.text = draft.location;
        _descriptionController.text = draft.description;
        selectedDate = draft.date;
        selectedTime = draft.time;
        notificationEnabled = draft.notificationEnabled;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI suggestion applied. Please review before saving.'),
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not generate event right now. You can still fill manually.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAiLoading = false);
      }
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
              TextFormField(
                controller: _aiPromptController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Describe with AI',
                  hintText:
                      'e.g. Meeting with Sir Ali tomorrow at 6 PM in Lab 2',
                  prefixIcon: const Icon(Icons.auto_awesome),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAiLoading ? null : _generateFromAi,
                  icon: _isAiLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology_alt_outlined),
                  label: Text(_isAiLoading
                      ? 'Generating...'
                      : 'Generate Event with Gemini'),
                ),
              ),
              const SizedBox(height: 18),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Title is required' : null,
                onSaved: (v) => title = (v ?? '').trim(),
              ),
              const SizedBox(height: 16),
              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSaved: (v) => location = (v ?? '').trim(),
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                onSaved: (v) => description = (v ?? '').trim(),
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
