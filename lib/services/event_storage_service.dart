import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_reminder_app/models/event.dart';

class EventStorageService {
  static const String _key = 'local_events';

  static Future<List<Event>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Event.fromMap(e)).toList();
  }

  static Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
        jsonEncode(events.map((e) => e.toMap()).toList());
    await prefs.setString(_key, data);
  }

  static Future<void> addEvent(Event event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  static Future<void> updateEvent(Event updated) async {
    final events = await getEvents();
    final index =
        events.indexWhere((e) => e.eventID == updated.eventID);
    if (index != -1) {
      events[index] = updated;
      await saveEvents(events);
    }
  }

  static Future<void> deleteEvent(String eventID) async {
    final events = await getEvents();
    events.removeWhere((e) => e.eventID == eventID);
    await saveEvents(events);
  }
}