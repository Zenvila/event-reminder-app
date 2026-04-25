import 'dart:convert';

class Event {
  String eventID;
  String title;
  String date;
  String time;
  String description;
  String location;
  bool notificationEnabled;
  int? notificationId;

  Event({
    required this.eventID,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    required this.location,
    required this.notificationEnabled,
    this.notificationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventID': eventID,
      'title': title,
      'date': date,
      'time': time,
      'description': description,
      'location': location,
      'notificationEnabled': notificationEnabled,
      'notificationId': notificationId,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventID: map['eventID'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      notificationEnabled: map['notificationEnabled'] ?? false,
      notificationId: map['notificationId'],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Event.fromJson(String source) =>
      Event.fromMap(jsonDecode(source));
}