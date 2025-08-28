import 'dart:async';
import 'package:change_notifier/change_notifier.dart';

import 'models/alert.dart';
import 'models/alert_channel_rules.dart';

/// A singleton state manager for handling alerts across the application.
///
/// It uses the [ChangeNotifier] pattern to allow widgets to listen for changes.
class AlertController extends ChangeNotifier {
  // --- Singleton Setup ---
  AlertController._();
  static final AlertController instance = AlertController._();

  // --- State ---
  final List<Alert> _alerts = [];
  Map<String, AlertChannelRules> _rules = {};

  /// A read-only list of all current alerts, sorted with the newest first.
  List<Alert> get allAlerts => List.unmodifiable(_alerts);

  // --- Configuration ---
  /// Configures the controller with a set of rules for different channels.
  /// This should typically be called once when the app starts.
  void configure(List<AlertChannelRules> rules) {
    _rules = {for (var rule in rules) rule.channelId: rule};
  }

  // --- Public API ---

  /// Adds a new alert and notifies listeners.
  ///
  /// Applies any matching [AlertChannelRules], such as `alertLimit` and `autoClear`.
  void add(Alert alert) {
    final rule = _rules[alert.channel];

    // Insert at the beginning to keep the list sorted by newest first.
    _alerts.insert(0, alert);

    // 1. Apply alert limit rule
    if (rule?.alertLimit != null) {
      final channelAlerts = _alerts
          .where((a) => a.channel == alert.channel)
          .toList();
      if (channelAlerts.length > rule!.alertLimit!) {
        // Find and remove the oldest alert in this channel
        final oldestAlert = channelAlerts.last;
        _alerts.removeWhere((a) => a.id == oldestAlert.id);
      }
    }

    // 2. Apply auto-clear rule
    if (rule?.autoClear == true && rule?.clearTimer != null) {
      Timer(rule!.clearTimer!, () => remove(alert.id));
    }

    notifyListeners();
  }

  /// Removes an alert by its unique ID and notifies listeners.
  void remove(String alertId) {
    final originalLength = _alerts.length;
    _alerts.removeWhere((alert) => alert.id == alertId);

    // Only notify if an alert was actually removed.
    if (_alerts.length < originalLength) {
      notifyListeners();
    }
  }

  /// Clears all alerts from channels that begin with the given [channelPattern].
  /// For example, `clearChannel('auth')` will remove alerts from 'auth.login' and 'auth.signup'.
  void clearChannel(String channelPattern) {
    final originalLength = _alerts.length;
    _alerts.removeWhere((alert) => alert.channel.startsWith(channelPattern));

    if (_alerts.length < originalLength) {
      notifyListeners();
    }
  }

  /// Retrieves a list of alerts for channels that begin with the [channelPattern].
  ///
  /// This is the primary method for widgets to get the alerts they care about.
  /// The `startsWith` matching allows for hierarchical channel filtering.
  List<Alert> getAlerts(String channelPattern) {
    return _alerts
        .where((alert) => alert.channel.startsWith(channelPattern))
        .toList();
  }
}
