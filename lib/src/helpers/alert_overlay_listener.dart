import '../alert_controller.dart';
import '../models/alert.dart';
import '../models/alert_channel_rules.dart';

/// A disposable handle for an alert overlay listener.
/// Call [dispose()] to remove the listener and prevent memory leaks.
class AlertOverlayListenerHandle {
  final void Function() _disposeCallback;
  bool _isDisposed = false;

  AlertOverlayListenerHandle(this._disposeCallback);

  /// Removes the alert overlay listener.
  /// Safe to call multiple times.
  void dispose() {
    if (!_isDisposed) {
      _disposeCallback();
      _isDisposed = true;
    }
  }

  /// Whether this handle has been disposed.
  bool get isDisposed => _isDisposed;
}

/// A helper to listen for new alerts intended to be shown as overlays (e.g., SnackBars, Toasts).
///
/// This function registers a global listener on the [AlertController]. When an alert is added
/// to a channel with `triggerOverlay: true` in its rules, the [onAlertTriggered] callback is executed.
///
/// Returns an [AlertOverlayListenerHandle] that should be disposed when the listening widget
/// is disposed to prevent memory leaks and stale context issues.
///
/// ### Example:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> {
///   AlertOverlayListenerHandle? _alertHandle;
///
///   @override
///   void initState() {
///     super.initState();
///     _alertHandle = listenForAlertOverlays(
///       onAlertTriggered: (alert, rule) {
///         if (!mounted) return; // Guard against stale context
///
///         // Your code to show a SnackBar, Toast, or custom popover
///         ScaffoldMessenger.of(context).showSnackBar(
///           SnackBar(
///             content: Text('${alert.title}: ${alert.message ?? ''}'),
///             showCloseIcon: rule?.isOverlayDismissable,
///             duration: rule?.clearTimer ?? const Duration(seconds: 4),
///           ),
///         );
///       },
///     );
///   }
///
///   @override
///   void dispose() {
///     _alertHandle?.dispose();
///     super.dispose();
///   }
/// }
/// ```
AlertOverlayListenerHandle listenForAlertOverlays({
  required void Function(Alert alert, AlertChannelRules? rule) onAlertTriggered,
}) {
  // Create the callback that will be registered
  void callback(Alert alert) {
    // The controller has already checked if the rule allows triggering.
    // We fetch the rule again here to provide its details (like `isOverlayDismissable`)
    // to the callback, so the UI knows how to behave.
    final rule = AlertController.instance.getRuleForChannel(alert.channel);
    onAlertTriggered(alert, rule);
  }

  // Register the callback and get the dispose function
  final disposeCallback = AlertController.instance.onAlertAdded(callback);

  // Return a handle that can dispose the listener
  return AlertOverlayListenerHandle(disposeCallback);
}
