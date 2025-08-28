import '../alert_controller.dart';
import '../models/alert.dart';
import '../models/alert_channel_rules.dart';

/// A helper to listen for new alerts intended to be shown as overlays (e.g., SnackBars, Toasts).
///
/// This function registers a global listener on the [AlertController]. When an alert is added
/// to a channel with `triggerOverlay: true` in its rules, the [onAlertTriggered] callback is executed.
///
/// Place this in a top-level widget like your main Scaffold's `initState` to set up the listener.
///
/// ### Example:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   listenForAlertOverlays(
///     onAlertTriggered: (alert, rule) {
///       // Your code to show a SnackBar, Toast, or custom popover
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(
///           content: Text('${alert.title}: ${alert.message ?? ''}'),
///           showCloseIcon: rule?.isOverlayDismissable,
///           duration: rule?.clearTimer ?? const Duration(seconds: 4),
///         ),
///       );
///     },
///   );
/// }
/// ```
void listenForAlertOverlays({
  required void Function(Alert alert, AlertChannelRules? rule) onAlertTriggered,
}) {
  AlertController.instance.onAlertAdded((alert) {
    // The controller has already checked if the rule allows triggering.
    // We fetch the rule again here to provide its details (like `isOverlayDismissable`)
    // to the callback, so the UI knows how to behave.
    final rule = AlertController.instance.getRuleForChannel(alert.channel);
    onAlertTriggered(alert, rule);
  });
}
