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

  const AlertChannelRules({
    required this.channelId,
    this.autoClear = false,
    this.clearTimer,
    this.alertLimit,
  });
}
