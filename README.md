# \# 📅 Eventora Planner

# 

# A beautiful and fully offline Flutter application for managing and scheduling personal events with smart notifications. Built with Flutter and Dart, this app provides a seamless experience for keeping track of your important events without requiring any internet connection or user accounts.

# 

# \---

# 

# \## ✨ Features

# 

# \- 📝 \*\*Create Events\*\* — Add title, location, description, date and time

# \- 🔔 \*\*Smart Notifications\*\* — Get reminded before your events automatically

# \- 📅 \*\*Calendar View\*\* — See all your events in monthly or weekly calendar format

# \- ⏰ \*\*Upcoming Events\*\* — Track all, upcoming, and past events in one place

# \- ✏️ \*\*Edit and Delete\*\* — Full control over your events anytime

# \- 🌙 \*\*Dark Mode\*\* — Beautiful dark and light theme support

# \- 💾 \*\*100% Offline\*\* — All data stored locally on your device, no internet needed

# \- 🔒 \*\*Private and Secure\*\* — No accounts, no cloud, no data sharing whatsoever

# \- 📱 \*\*Clean UI\*\* — Modern Material Design 3 interface

# 

# \---

# 

# \## 📱 App Screens

# 

# | Screen | Description |

# |--------|-------------|

# | Login Screen | Enter your name to get started, no password needed |

# | Onboarding | Beautiful introduction to app features |

# | Upcoming Events | View all, upcoming, and past events in tabs |

# | Create Event | Add new events with full details and notifications |

# | Edit Event | Modify any existing event |

# | Calendar View | Monthly and weekly calendar with event markers |

# | Settings | Theme toggle, notification controls, sign out |

# 

# \---

# 

# \## 🚀 Getting Started

# 

# \### Prerequisites

# 

# \- Flutter SDK 3.7.0 or higher

# \- Dart SDK 3.7.0 or higher

# \- Android device or emulator running API 21 or higher

# \- Android Studio or VS Code with Flutter extension

# 

# \### Installation

# 

# 1\. Clone the repository

# 

# ```bash

# git clone https://github.com/Haris-Shahzad/event-reminder-app.git

# ```

# 

# 2\. Navigate to the project folder

# 

# ```bash

# cd event-reminder-app

# ```

# 

# 3\. Install all dependencies

# 

# ```bash

# flutter pub get

# ```

# 

# 4\. Run the app on your connected device

# 

# ```bash

# flutter run

# ```

# 

# \### Build Release APK

# 

# ```bash

# flutter build apk --release

# ```

# 

# The APK will be located at:

# build/app/outputs/flutter-apk/app-release.apk

# 

# \---

# 

# \## 🛠️ Tech Stack

# 

# | Technology | Version | Purpose |

# |------------|---------|---------|

# | Flutter | 3.7.0+ | Cross-platform UI framework |

# | Dart | 3.7.0+ | Programming language |

# | Provider | 6.1.5 | State management |

# | Shared Preferences | 2.5.3 | Local data storage |

# | Flutter Local Notifications | 19.2.1 | Push notification scheduling |

# | Table Calendar | 3.2.0 | Calendar widget |

# | Permission Handler | 12.0.0 | Runtime permissions |

# | Timezone | 0.10.1 | Accurate notification scheduling |

# | Google Fonts | Latest | Beautiful typography |

# | Android Intent Plus | 5.3.0 | Android system intents |

# | Badges | 3.1.2 | UI badge components |

# | Font Awesome Flutter | 10.8.0 | Icon library |

# 

# \---

# 

# \## 📁 Project Structure

# lib/

# ├── main.dart                       # App entry point and initialization

# ├── firebase\_options.dart           # Placeholder (Firebase removed)

# ├── secrets.dart                    # Placeholder (no secrets needed)

# │

# ├── models/

# │   ├── event.dart                  # Event data model with JSON serialization

# │   └── app\_user.dart               # User data model

# │

# ├── providers/

# │   ├── theme\_provider.dart         # Theme state management (light/dark)

# │   └── user\_provider.dart          # User state management

# │

# ├── screens/

# │   ├── auth\_screen.dart            # Local login screen (name + email)

# │   ├── on\_boarding\_screen.dart     # App introduction and onboarding

# │   ├── upcoming\_events\_screen.dart # Main screen with tabbed event list

# │   ├── create\_event\_screen.dart    # Form to create new events

# │   ├── edit\_event\_screen.dart      # Form to edit existing events

# │   ├── calender\_screen.dart        # Calendar view with event markers

# │   └── settings.dart               # Settings page

# │

# ├── services/

# │   ├── event\_storage\_service.dart  # CRUD operations using local storage

# │   └── notification\_services.dart  # Notification scheduling and management

# │

# └── widgets/

# ├── appbar.dart                 # Custom reusable app bar

# ├── bottom\_nav\_bar.dart         # Bottom navigation bar

# └── build\_event\_card.dart       # Event card widget with actions

# 

# \---

# 

# \## 🔧 Key Implementation Details

# 

# \### Local Storage Architecture

# All events are stored locally using `shared\_preferences` as serialized JSON strings. The `EventStorageService` class provides clean CRUD operations:

# \- `getEvents()` — Load all events from device storage

# \- `addEvent()` — Save a new event

# \- `updateEvent()` — Update an existing event

# \- `deleteEvent()` — Remove an event by ID

# 

# \### Notification System

# Events use `flutter\_local\_notifications` with timezone-aware scheduling via the `timezone` package. Notifications are:

# \- Scheduled at the exact event date and time

# \- Cancelled automatically when events are deleted

# \- Rescheduled when events are edited

# \- Persisted across app restarts

# 

# \### Offline First Design

# This app is designed to work completely without internet. All data lives on the device. No Firebase, no Google Sign-In, no cloud sync, no API calls.

# 

# \### Theme System

# Dark and light modes are managed by `ThemeProvider` using Flutter's `ThemeMode`. User preference is persisted across sessions.

# 

# \---

# 

# \## 📋 How to Use

# 

# \### Creating Your First Event

# 1\. Launch the app and enter your name on the login screen

# 2\. Complete the onboarding (first launch only)

# 3\. Tap the \*\*+\*\* floating action button on the home screen

# 4\. Fill in the event title (required)

# 5\. Add location, description (optional)

# 6\. Pick a date using the date picker

# 7\. Pick a time using the time picker

# 8\. Toggle notifications ON if you want a reminder

# 9\. Tap \*\*Create Event\*\*

# 

# \### Viewing Events

# \- \*\*All tab\*\* — shows every event you have created

# \- \*\*Upcoming tab\*\* — shows future events only

# \- \*\*Past tab\*\* — shows events that have already passed

# \- \*\*Calendar tab\*\* — tap any date to see events on that day

# 

# \### Managing Events

# \- Tap the \*\*edit icon\*\* on any event card to modify it

# \- Tap the \*\*delete icon\*\* to permanently remove an event

# \- Pull down to refresh the events list

# 

# \### Settings

# \- Toggle \*\*Dark Mode\*\* for a darker interface

# \- Toggle \*\*Notifications\*\* to enable or disable all reminders

# \- Tap \*\*Clear All Events\*\* to delete everything

# \- Tap \*\*Sign Out\*\* to return to the login screen

# 

# \---

# 

# \## 🤝 Contributing

# 

# Contributions are welcome! Here is how you can help:

# 

# 1\. Fork the repository

# 2\. Create your feature branch

# ```bash

# git checkout -b feature/your-feature-name

# ```

# 3\. Make your changes and commit

# ```bash

# git commit -m "Add your feature description"

# ```

# 4\. Push to your branch

# ```bash

# git push origin feature/your-feature-name

# ```

# 5\. Open a Pull Request on GitHub

# 

# \### Ideas for Contributions

# \- Add event categories and color coding

# \- Add recurring events support

# \- Add event search functionality

# \- Add export to calendar feature

# \- Add widget for home screen

# \- Add iOS support and testing

# \- Improve accessibility features

# 

# \---

# 

# \## 🐛 Known Issues

# 

# \- Notifications may not fire if battery optimization is enabled for the app. Go to Settings → Apps → Eventora → Battery → Unrestricted to fix this.

# \- The app currently supports Android only. iOS support is planned.

# 

# \---

# 

# \## 📄 License

# 

# This project is licensed under the MIT License.

# MIT License

# Copyright (c) 2026 Haris Shahzad

# Permission is hereby granted, free of charge, to any person obtaining a copy

# of this software and associated documentation files (the "Software"), to deal

# in the Software without restriction, including without limitation the rights

# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

# copies of the Software, and to permit persons to whom the Software is

# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all

# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

# 

# \---

# 

# \## 👨‍💻 Developer

# 

# \*\*Haris Shahzad\*\*

# 

# \- GitHub: \[@Haris-Shahzad](https://github.com/Haris-Shahzad)

# 

# \---

# 

# \## 🙏 Acknowledgements

# 

# \- \[Flutter](https://flutter.dev) — Amazing cross-platform framework

# \- \[pub.dev](https://pub.dev) — Dart package repository


# 

# \---

# 

# ⭐ If you found this project useful or interesting, please give it a star on GitHub!

# 


# \\---
#
# \\## ✅ Cross-platform compatibility (simple)
#
# This app now runs safely on Android, iOS, and Web with graceful fallback behavior:
#
# \- If Firebase is configured on the platform, cloud features work (Google sign-in, Firestore profile/events, Gemini AI).
# \- If Firebase is not configured on the platform, the app still opens and local/offline flow continues.
#
# \\### iOS (Swift/Xcode) quick setup
#
# 1\. Add your iOS app in Firebase Console with bundle ID.
# 2\. Download `GoogleService-Info.plist`.
# 3\. Place it in `ios/Runner/GoogleService-Info.plist` using Xcode.
# 4\. Run:
#
# ```bash
# flutter run -d ios
# ```
#
# \\### Web quick setup
#
# 1\. Add Web app in Firebase Console.
# 2\. Configure Firebase for web (FlutterFire) for your project.
# 3\. Run:
#
# ```bash
# flutter run -d chrome
# ```
#
# \\### Important note
#
# Event data is now user-scoped:
# \- User A and User B see separate events.
# \- Events are saved under Firestore `users/{uid}/events/{eventId}`.
#
# \\---
#
# \\## 📤 How to share app with friends
#
# For quick sharing (Android APK):
#
# ```bash
# flutter build apk --release
# ```
#
# Share this file:
# `build/app/outputs/flutter-apk/app-release.apk`
#
# For Play Store:
#
# ```bash
# flutter build appbundle --release
# ```
#
# Upload:
# `build/app/outputs/bundle/release/app-release.aab`
#
