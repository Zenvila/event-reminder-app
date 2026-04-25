import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora_planner/services/firebase_bootstrap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventora_planner/models/event.dart';

class EventStorageService {
  static const String _legacyKey = 'local_events';

  static Future<CollectionReference<Map<String, dynamic>>?>
      _userEventsCollection() async {
    final firebaseReady = await FirebaseBootstrap.ensureInitialized();
    if (!firebaseReady) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events');
  }

  static Future<String> _userScopedKey() async {
    final firebaseReady = await FirebaseBootstrap.ensureInitialized();
    if (!firebaseReady) {
      final prefs = await SharedPreferences.getInstance();
      final localEmail = prefs.getString('user_email') ?? '';
      if (localEmail.isNotEmpty) {
        return 'local_events_${localEmail.toLowerCase()}';
      }
      final localName = prefs.getString('user_name') ?? 'local_user';
      return 'local_events_${localName.toLowerCase()}';
    }

    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    if (firebaseUid != null && firebaseUid.isNotEmpty) {
      return 'local_events_$firebaseUid';
    }

    final prefs = await SharedPreferences.getInstance();
    final localEmail = prefs.getString('user_email') ?? '';
    if (localEmail.isNotEmpty) {
      return 'local_events_${localEmail.toLowerCase()}';
    }

    final localName = prefs.getString('user_name') ?? 'local_user';
    return 'local_events_${localName.toLowerCase()}';
  }

  static Future<List<Event>> getEvents() async {
    final eventsCollection = await _userEventsCollection();
    if (eventsCollection != null) {
      final snapshot = await eventsCollection.get();
      final events = snapshot.docs.map((doc) {
        final data = doc.data();
        data['eventID'] = data['eventID'] ?? doc.id;
        return Event.fromMap(data);
      }).toList();
      events.sort((a, b) => a.eventID.compareTo(b.eventID));
      return events;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = await _userScopedKey();
    String? data = prefs.getString(key);

    // One-time migration for old app versions that used a shared global key.
    if (data == null) {
      final legacyData = prefs.getString(_legacyKey);
      if (legacyData != null) {
        data = legacyData;
        await prefs.setString(key, legacyData);
        await prefs.remove(_legacyKey);
      }
    }

    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Event.fromMap(e)).toList();
  }

  static Future<void> saveEvents(List<Event> events) async {
    final eventsCollection = await _userEventsCollection();
    if (eventsCollection != null) {
      final snapshot = await eventsCollection.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      for (final event in events) {
        final docRef = eventsCollection.doc(event.eventID);
        batch.set(docRef, event.toMap());
      }

      await batch.commit();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = await _userScopedKey();
    final String data =
        jsonEncode(events.map((e) => e.toMap()).toList());
    await prefs.setString(key, data);
  }

  static Future<void> addEvent(Event event) async {
    final eventsCollection = await _userEventsCollection();
    if (eventsCollection != null) {
      await eventsCollection.doc(event.eventID).set(event.toMap());
      return;
    }

    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  static Future<void> updateEvent(Event updated) async {
    final eventsCollection = await _userEventsCollection();
    if (eventsCollection != null) {
      await eventsCollection.doc(updated.eventID).set(updated.toMap());
      return;
    }

    final events = await getEvents();
    final index =
        events.indexWhere((e) => e.eventID == updated.eventID);
    if (index != -1) {
      events[index] = updated;
      await saveEvents(events);
    }
  }

  static Future<void> deleteEvent(String eventID) async {
    final eventsCollection = await _userEventsCollection();
    if (eventsCollection != null) {
      await eventsCollection.doc(eventID).delete();
      return;
    }

    final events = await getEvents();
    events.removeWhere((e) => e.eventID == eventID);
    await saveEvents(events);
  }
}