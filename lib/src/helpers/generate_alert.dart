import '../alert_controller.dart';
import '../models/alert.dart';

/// A helper class to simplify the creation of alerts for a specific channel.
///
/// Example:
/// `GenerateAlert('auth.login').error(title: 'Login Failed', message: 'Invalid credentials.');`
class GenerateAlert {
  final String channel;

  GenerateAlert(this.channel);

  /// Adds a `success` type alert to the specified channel.
  void success({required String title, String? message}) {
    _add(title: title, message: message, type: AlertType.success);
  }

  /// Adds a `failure` type alert to the specified channel.
  void error({required String title, String? message}) {
    _add(title: title, message: message, type: AlertType.failure);
  }

  /// Adds a `warning` type alert to the specified channel.
  void warning({required String title, String? message}) {
    _add(title: title, message: message, type: AlertType.warning);
  }

  /// Adds a `help` type alert to the specified channel.
  void help({required String title, String? message}) {
    _add(title: title, message: message, type: AlertType.help);
  }

  void _add({required String title, String? message, required AlertType type}) {
    final alert = Alert(
      title: title,
      message: message,
      channel: channel,
      type: type,
    );
    AlertController.instance.add(alert);
  }
}
