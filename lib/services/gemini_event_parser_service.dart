import 'dart:convert';

import 'package:eventora_planner/services/firebase_bootstrap.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParsedEventDraft {
  final String title;
  final String location;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final bool notificationEnabled;

  ParsedEventDraft({
    required this.title,
    required this.location,
    required this.description,
    required this.date,
    required this.time,
    required this.notificationEnabled,
  });
}

class GeminiEventParserService {
  GeminiEventParserService._();

  static Future<ParsedEventDraft> parseEventText(String userInput) async {
    final trimmed = userInput.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Please describe your event first.');
    }

    await _ensureFirebaseInitialized();
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 400,
      ),
    );

    final now = DateTime.now();
    final todayIso = DateFormat('yyyy-MM-dd').format(now);

    final prompt = '''
You are an event extraction assistant.
Extract event details from the user input and return ONLY valid JSON (no markdown, no explanation).

User input: "$trimmed"
Today date: "$todayIso"

Return this exact JSON shape:
{
  "title": "string",
  "location": "string",
  "description": "string",
  "date": "YYYY-MM-DD",
  "time": "HH:mm",
  "notificationEnabled": true
}

Rules:
- If location is unknown, return empty string.
- If description is unknown, return empty string.
- Choose a reasonable future date/time if user input is ambiguous.
- "title" must never be empty.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text?.trim();
    if (raw == null || raw.isEmpty) {
      throw const FormatException('Gemini returned an empty response.');
    }

    final decoded = _decodeJsonObject(raw);
    final title = (decoded['title'] ?? '').toString().trim();
    if (title.isEmpty) {
      throw const FormatException('AI could not infer a valid event title.');
    }

    final location = (decoded['location'] ?? '').toString().trim();
    final description = (decoded['description'] ?? '').toString().trim();
    final notificationEnabled = _asBool(decoded['notificationEnabled']);

    final dateValue = (decoded['date'] ?? '').toString().trim();
    final timeValue = (decoded['time'] ?? '').toString().trim();
    final date = _parseDate(dateValue);
    final time = _parseTime(timeValue);

    final candidateDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (candidateDateTime.isBefore(now)) {
      throw const FormatException(
        'AI suggested a past date/time. Please refine your sentence.',
      );
    }

    return ParsedEventDraft(
      title: title,
      location: location,
      description: description,
      date: date,
      time: time,
      notificationEnabled: notificationEnabled,
    );
  }

  static Future<void> _ensureFirebaseInitialized() async {
    final ready = await FirebaseBootstrap.ensureInitialized();
    if (!ready) {
      throw const FormatException(
        'Firebase AI is not configured for this platform yet. '
        'Please connect the app to Firebase before using AI.',
      );
    }
  }

  static Map<String, dynamic> _decodeJsonObject(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      final fenced = RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true)
          .firstMatch(raw);
      final candidate = fenced?.group(1)?.trim() ?? raw;
      try {
        return jsonDecode(candidate) as Map<String, dynamic>;
      } catch (_) {
        final start = candidate.indexOf('{');
        final end = candidate.lastIndexOf('}');
        if (start >= 0 && end > start) {
          final sliced = candidate.substring(start, end + 1);
          return jsonDecode(sliced) as Map<String, dynamic>;
        }
      }
    }
    throw const FormatException('Failed to parse AI response as JSON.');
  }

  static DateTime _parseDate(String input) {
    final parsed = DateTime.tryParse(input);
    if (parsed == null) {
      throw const FormatException('AI returned invalid date format.');
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static TimeOfDay _parseTime(String input) {
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    final match = regex.firstMatch(input);
    if (match == null) {
      throw const FormatException('AI returned invalid time format.');
    }
    return TimeOfDay(
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
