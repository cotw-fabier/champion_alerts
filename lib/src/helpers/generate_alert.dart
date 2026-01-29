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
  ///
  /// Set [silent] to true to add the alert without triggering overlay notifications.
  void success({required String title, String? message, String? link, bool silent = false}) {
    _add(title: title, message: message, type: AlertType.success, link: link, silent: silent);
  }

  /// Adds a `failure` type alert to the specified channel.
  ///
  /// Set [silent] to true to add the alert without triggering overlay notifications.
  void error({required String title, String? message, String? link, bool silent = false}) {
    _add(title: title, message: message, type: AlertType.failure, link: link, silent: silent);
  }

  /// Adds a `warning` type alert to the specified channel.
  ///
  /// Set [silent] to true to add the alert without triggering overlay notifications.
  void warning({required String title, String? message, String? link, bool silent = false}) {
    _add(title: title, message: message, type: AlertType.warning, link: link, silent: silent);
  }

  /// Adds a `help` type alert to the specified channel.
  ///
  /// Set [silent] to true to add the alert without triggering overlay notifications.
  void help({required String title, String? message, String? link, bool silent = false}) {
    _add(title: title, message: message, type: AlertType.help, link: link, silent: silent);
  }

  void _add({required String title, String? message, required AlertType type, String? link, bool silent = false}) {
    final alert = Alert(
      title: title,
      message: message,
      channel: channel,
      type: type,
      link: link,
      silent: silent,
    );
    AlertController.instance.add(alert);
  }
}
