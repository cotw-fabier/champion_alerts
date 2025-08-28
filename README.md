# Champion Alerts

A simple, flexible package for managing in-app alerts and notifications using a singleton `ChangeNotifier`.

-----

## Features

  - **Singleton Controller**: A single source of truth for all alerts, easily accessible anywhere in your app.
  - **Hierarchical Channels**: Organize alerts into channels (e.g., `auth`, `auth.login`). Define rules for parent channels that automatically apply to sub-channels, allowing for default behaviors with specific overrides.
  - **Powerful Alert Retrieval**: Use `startsWith` filtering to get alerts from a parent channel and all its sub-channels at once.
  - **UI Overlay Triggers**: A simple listener system to connect alert events to UI components like **SnackBars**, **Toasts**, or custom popovers without coupling the core logic to the UI framework.
  - **Framework Agnostic**: The core logic has no dependency on Flutter, making it usable in any Dart project. UI helpers are provided for easy integration with Flutter.

-----

## Installation

1.  Add `championalerts` to your `pubspec.yaml` file.

    ```yaml
    dependencies:
      championalerts:
        path: ../path/to/championalerts # Or use the version from pub.dev
    ```

2.  Run `flutter pub get` or `dart pub get`.

-----

## Usage

### 1\. Configure the Alert Controller

In your app's initialization script, configure the channel rules. Rules are inherited from parent channels.

```dart
import 'package:championalerts/championalerts.dart';

void initializeAlerts() {
  // Define rules for your alert channels
  final rules = [
    const AlertChannelRules(
      channelId: 'auth',
      // This rule applies to 'auth', 'auth.login', 'auth.signup', etc.
      triggerOverlay: true, // Fire the overlay listener for this channel family
      alertLimit: 1, // Only show the most recent auth-related alert
    ),
    const AlertChannelRules(
      channelId: 'auth.login',
      // This rule is more specific and adds to or overrides the 'auth' rule.
      autoClear: true, // Only login alerts will auto-clear
      clearTimer: Duration(seconds: 5),
    ),
    const AlertChannelRules(
      channelId: 'downloads',
      alertLimit: 3,
    ),
  ];

  // Configure the singleton controller
  AlertController.instance.configure(rules);
}
```

### 2\. Add Alerts

Use the `GenerateAlert` helper anywhere in your app to create alerts. The controller will automatically find the most specific rule to apply.

```dart
// This alert will trigger an overlay and have a 5-second auto-clear timer.
GenerateAlert('auth.login').success(title: 'Login Successful!');

// This alert will also trigger an overlay (from the 'auth' rule) but will not auto-clear.
GenerateAlert('auth.signup').success(title: 'Welcome!');
```

### 3\. Using Alerts in the UI

You can interact with alerts in two main ways: displaying them in a list or reacting to them with pop-ups.

#### A. Displaying a List of Alerts

To display alerts declaratively in your UI, listen to the controller and use `getAlerts()` to retrieve the alerts for a specific channel family. The following is a **Flutter example** using `AnimatedBuilder`.

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
        // Get alerts for 'auth' and all its sub-channels ('auth.login', etc.)
        final authAlerts = AlertController.instance.getAlerts('auth');

        if (authAlerts.isEmpty) {
          return const SizedBox.shrink(); // Render nothing if no alerts
        }

        // Display the alerts in a list
        return ListView.builder(
          itemCount: authAlerts.length,
          itemBuilder: (context, index) {
            final alert = authAlerts[index];
            return ListTile(
              title: Text(alert.title),
              subtitle: alert.message != null ? Text(alert.message!) : null,
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => AlertController.instance.remove(alert.id),
              ),
            );
          },
        );
      },
    );
  }
}
```

#### B. Triggering Overlays (SnackBars, Toasts)

To react to alerts as they are created, use the `listenForAlertOverlays` helper. This is ideal for showing temporary notifications. Place this listener in a top-level widget, like your main `Scaffold`.

```dart
// Inside a StatefulWidget, like your main app shell
@override
void initState() {
  super.initState();

  // This listener will only be triggered by alerts on channels with `triggerOverlay: true`
  listenForAlertOverlays(
    onAlertTriggered: (alert, rule) {
      // Your custom code to show a SnackBar, Toast, or other pop-up.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${alert.title}: ${alert.message ?? ''}'),
          // Use properties from the found rule to configure the UI
          showCloseIcon: rule?.isOverlayDismissable,
          duration: rule?.clearTimer ?? const Duration(seconds: 4),
        ),
      );
    },
  );
}
```
