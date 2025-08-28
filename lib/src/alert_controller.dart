import 'dart:async';
import 'package:change_notifier/change_notifier.dart';

import 'models/alert.dart';
import 'models/alert_channel_rules.dart';

/// A singleton state manager for handling alerts across the application.
class AlertController extends ChangeNotifier {
  // --- Singleton Setup ---
  AlertController._();
  static final AlertController instance = AlertController._();

  // --- State ---
  final List<Alert> _alerts = [];
  Map<String, AlertChannelRules> _rules = {};
  void Function(Alert alert)? _onAlertAddedCallback;

  /// A read-only list of all current alerts, sorted with the newest first.
  List<Alert> get allAlerts => List.unmodifiable(_alerts);

  // --- Configuration ---
  /// Configures the controller with a set of rules for different channels.
  void configure(List<AlertChannelRules> rules) {
    _rules = {for (var rule in rules) rule.channelId: rule};
  }

  /// Registers a global callback that fires when an alert is added to a channel
  /// marked with `triggerOverlay: true`.
  void onAlertAdded(void Function(Alert alert) callback) {
    _onAlertAddedCallback = callback;
  }

  // --- Private Helper for Hierarchical Rule Lookup ---

  /// Finds the most specific rule for a given channel by traversing up its hierarchy.
  /// For example, for 'auth.login.error', it will check for rules in this order:
  /// 1. 'auth.login.error'
  /// 2. 'auth.login'
  /// 3. 'auth'
  AlertChannelRules? _findMostSpecificRule(String channel) {
    String currentChannel = channel;
    while (true) {
      if (_rules.containsKey(currentChannel)) {
        return _rules[currentChannel];
      }
      int lastDotIndex = currentChannel.lastIndexOf('.');
      if (lastDotIndex == -1) {
        return null; // Reached the top level with no match
      }
      currentChannel = currentChannel.substring(0, lastDotIndex);
    }
  }

  // --- Public API ---

  /// Adds a new alert and notifies listeners.
  void add(Alert alert) {
    // UPDATED: Use the new hierarchical rule lookup.
    final rule = _findMostSpecificRule(alert.channel);

    // Insert at the beginning to keep the list sorted by newest first.
    _alerts.insert(0, alert);

    // 1. Apply alert limit rule
    if (rule?.alertLimit != null) {
      final channelAlerts = _alerts
          .where((a) => a.channel == alert.channel)
          .toList();
      if (channelAlerts.length > rule!.alertLimit!) {
        final oldestAlert = channelAlerts.last;
        _alerts.removeWhere((a) => a.id == oldestAlert.id);
      }
    }

    // 2. Apply auto-clear rule
    if (rule?.autoClear == true && rule?.clearTimer != null) {
      Timer(rule!.clearTimer!, () => remove(alert.id));
    }

    // 3. Trigger the global "on alert added" callback for overlays
    if (rule?.triggerOverlay == true && _onAlertAddedCallback != null) {
      _onAlertAddedCallback!(alert);
    }

    notifyListeners();
  }

  /// Removes an alert by its unique ID and notifies listeners.
  void remove(String alertId) {
    final originalLength = _alerts.length;
    _alerts.removeWhere((alert) => alert.id == alertId);

    if (_alerts.length < originalLength) {
      notifyListeners();
    }
  }

  /// Clears all alerts from channels that begin with the given [channelPattern].
  void clearChannel(String channelPattern) {
    final originalLength = _alerts.length;
    _alerts.removeWhere((alert) => alert.channel.startsWith(channelPattern));

    if (_alerts.length < originalLength) {
      notifyListeners();
    }
  }

  /// Retrieves a list of alerts for channels that begin with the [channelPattern].
  List<Alert> getAlerts(String channelPattern) {
    return _alerts
        .where((alert) => alert.channel.startsWith(channelPattern))
        .toList();
  }

  /// Retrieves the most specific rule for a given channel, if one exists.
  AlertChannelRules? getRuleForChannel(String channel) {
    // UPDATED: Use the new hierarchical rule lookup.
    return _findMostSpecificRule(channel);
  }
}
