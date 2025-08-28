# Champion Alerts

A simple, flexible package for managing in-app alerts and notifications using a singleton `ChangeNotifier`.

## Features

-   **Singleton Controller**: A single source of truth for all alerts, easily accessible anywhere in your app.
-   **Channel-Based**: Organize alerts into channels (e.g., 'auth', 'cart', 'user.profile').
-   **`startsWith` Filtering**: Widgets can subscribe to broad channels (e.g., 'auth') and receive alerts from all sub-channels (e.g., 'auth.login', 'auth.signup').
-   **Configurable Rules**: Define rules per channel, like alert limits and auto-clearing timers.
-   **Framework Agnostic**: Uses `ChangeNotifier` from the Flutter SDK, requiring no specific state management library like Riverpod or Bloc.

## Installation

1.  Add `championalerts` to your `pubspec.yaml` file. If you are using it locally, you can use a path reference:

    ```yaml
    dependencies:
      championalerts:
        path: ../path/to/championalerts
    ```

2.  Run `flutter pub get`.

## Usage

### 1. Configure the Alert Controller

In your `main.dart` or an initialization script, configure the channels you want to use.

```dart
import 'package:flutter/material.dart';
import 'package:championalerts/championalerts.dart';

void main() {
  // Define rules for your alert channels
  final rules = [
    const AlertChannelRules(
      channelId: 'auth',
      alertLimit: 1, // Only show the most recent auth alert
      autoClear: true,
      clearTimer: Duration(seconds: 5),
    ),
    const AlertChannelRules(
      channelId: 'downloads',
      alertLimit: 3,
    ),
  ];

  // Configure the singleton controller
  AlertController.instance.configure(rules);

  runApp(const MyApp());
}
```

### 2. Add Alerts

Use the `GenerateAlert` helper anywhere in your app to easily create and add new alerts.

```dart
// In a login function
void _loginUser() {
  try {
    // ... login logic ...
    GenerateAlert('auth').success(title: 'Login Successful!');
  } catch (e) {
    GenerateAlert('auth').error(
      title: 'Login Failed',
      message: 'Please check your credentials and try again.',
    );
  }
}

// In a download manager
void _startDownload() {
    GenerateAlert('downloads').help(
      title: 'Download Started',
      message: 'Your file is being downloaded.',
    );
}
```

### 3. Display Alerts in a Widget

Use an `AnimatedBuilder` to listen to the `AlertController` and rebuild your UI whenever alerts change.

The `getAlerts('channel.pattern')` method allows you to fetch alerts that match the beginning of a channel name.

```dart
import 'package:flutter/material.dart';
import 'package:championalerts/championalerts.dart';

class AuthAlertsWidget extends StatelessWidget {
  const AuthAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // This builder will re-run whenever an alert is added or removed.
    return AnimatedBuilder(
      animation: AlertController.instance,
      builder: (context, child) {
        // Listen to 'auth' and all sub-channels like 'auth.login', 'auth.reset', etc.
        final authAlerts = AlertController.instance.getAlerts('auth');

        if (authAlerts.isEmpty) {
          return const SizedBox.shrink(); // Render nothing if no alerts
        }

        // Display the first alert as a banner
        final alert = authAlerts.first;
        return MaterialBanner(
          content: Text(alert.title),
          actions: [
            TextButton(
              child: const Text('DISMISS'),
              onPressed: () {
                AlertController.instance.remove(alert.id);
              },
            ),
          ],
        );
      },
    );
  }
}
```
