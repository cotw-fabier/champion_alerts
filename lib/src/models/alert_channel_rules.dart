/// Defines a set of rules for a specific alert channel.
class AlertChannelRules {
  /// The unique identifier for the channel (e.g., 'auth', 'user.profile').
  final String channelId;

  /// Whether alerts in this channel should be automatically removed after a delay.
  final bool autoClear;

  /// The duration to wait before auto-clearing an alert.
  /// This is only used if [autoClear] is true.
  final Duration? clearTimer;

  /// The maximum number of alerts to keep in this channel.
  /// When a new alert is added and the limit is exceeded, the oldest alert is removed.
  final int? alertLimit;

  /// If true, adding an alert to this channel will trigger the global overlay listener.
  final bool triggerOverlay;

  /// A flag you can use in your UI to determine if the overlay should be dismissable.
  final bool isOverlayDismissable;

  const AlertChannelRules({
    required this.channelId,
    this.autoClear = false,
    this.clearTimer,
    this.alertLimit,
    this.triggerOverlay = false,
    this.isOverlayDismissable = true,
  });
}
