import 'package:uuid/uuid.dart';

/// Defines the category or severity of an alert.
enum AlertType { failure, success, help, warning }

/// Represents a single alert object.
class Alert {
  final String id;
  final String title;
  final String? message;
  final DateTime time;
  final String channel;
  final AlertType type;
  final String? link;

  /// When true, the alert is added to the list but does not trigger
  /// overlay notifications. Useful for syncing unread counts from the
  /// database without re-notifying the user.
  final bool silent;

  Alert({
    String? id,
    required this.title,
    this.message,
    DateTime? time,
    required this.channel,
    this.type = AlertType.success,
    this.link,
    this.silent = false,
  }) : id = id ?? const Uuid().v4(),
       time = time ?? DateTime.now();
}
