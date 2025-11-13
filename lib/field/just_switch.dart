import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_form/just_form.dart';
import 'package:just_form/just_validator.dart';

/// A boolean toggle switch widget integrated with the just_form system.
///
/// [JustSwitch] is a convenience widget that wraps Flutter's [Switch] and integrates
/// it with the just_form form management system. It automatically handles field registration,
/// validation, state management, and value synchronization for toggle/checkbox functionality.
///
/// The widget supports all standard [Switch] properties while adding form-specific features
/// like validators and automatic state tracking. It's ideal for boolean form fields such as
/// agreement checkboxes, feature toggles, and yes/no questions.
///
/// Key features:
/// - Automatic form field registration via [JustField]
/// - Integrated validation with [JustValidator]
/// - Automatic value synchronization with form controller
/// - Support for dynamic property overrides via field attributes
/// - Full [Switch] customization options
/// - Focus and keyboard support
///
/// Example - Checkbox-like agreement field:
/// ```dart
/// JustSwitch(
///   name: 'agreeToTerms',
///   initialValue: false,
///   validators: [
///     JustValidator(
///       validate: (value, formValues) =>
///         value != true ? 'You must agree to the terms' : null,
///     ),
///   ],
///   onChanged: (value) => print('Agreement toggled: $value'),
/// )
/// ```
class JustSwitch extends StatelessWidget {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "agreeToTerms",
  /// "rememberMe", "notifications").
  final String name;

  /// The initial value of the field. This value is ignored when the initial value
  /// is already set on the [JustFormController] or [JustForm].
  final bool? initialValue;

  /// A list of validators to check the value of the field against.
  ///
  /// These validators will be run whenever the value of the field changes.
  ///
  /// The validators will be passed the current value of the field and the
  /// entire form values.
  ///
  /// If any of the validators return an error string, the field will be
  /// marked as invalid.
  final List<JustValidator<bool>> validators;

  /// Called when the user toggles the switch on or off.
  ///
  /// The switch passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the switch with the new
  /// value.
  ///
  /// If null, the switch will be displayed as disabled.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// Switch(
  ///   value: _giveVerse,
  ///   onChanged: (bool newValue) {
  ///     setState(() {
  ///       _giveVerse = newValue;
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<bool>? onChanged;

  /// {@template flutter.material.switch.activeThumbColor}
  /// The color to use when this switch is on.
  /// {@endtemplate}
  ///
  /// Defaults to [ColorScheme.secondary].
  ///
  /// If [thumbColor] returns a non-null color in the [WidgetState.selected]
  /// state, it will be used instead of this color.
  final Color? activeThumbColor;

  /// {@template flutter.material.switch.activeTrackColor}
  /// The color to use on the track when this switch is on.
  /// {@endtemplate}
  ///
  /// Defaults to [ColorScheme.secondary] with the opacity set at 50%.
  ///
  /// If [trackColor] returns a non-null color in the [WidgetState.selected]
  /// state, it will be used instead of this color.
  final Color? activeTrackColor;

  /// {@template flutter.material.switch.inactiveThumbColor}
  /// The color to use on the thumb when this switch is off.
  /// {@endtemplate}
  ///
  /// Defaults to the colors described in the Material design specification.
  ///
  /// If [thumbColor] returns a non-null color in the default state, it will be
  /// used instead of this color.
  final Color? inactiveThumbColor;

  /// {@template flutter.material.switch.inactiveTrackColor}
  /// The color to use on the track when this switch is off.
  /// {@endtemplate}
  ///
  /// Defaults to the colors described in the Material design specification.
  ///
  /// If [trackColor] returns a non-null color in the default state, it will be
  /// used instead of this color.
  final Color? inactiveTrackColor;

  /// {@template flutter.material.switch.activeThumbImage}
  /// An image to use on the thumb of this switch when the switch is on.
  /// {@endtemplate}
  final ImageProvider? activeThumbImage;

  /// {@template flutter.material.switch.onActiveThumbImageError}
  /// An optional error callback for errors emitted when loading
  /// [activeThumbImage].
  /// {@endtemplate}
  final ImageErrorListener? onActiveThumbImageError;

  /// {@template flutter.material.switch.inactiveThumbImage}
  /// An image to use on the thumb of this switch when the switch is off.
  /// {@endtemplate}
  final ImageProvider? inactiveThumbImage;

  /// {@template flutter.material.switch.onInactiveThumbImageError}
  /// An optional error callback for errors emitted when loading
  /// [inactiveThumbImage].
  /// {@endtemplate}
  final ImageErrorListener? onInactiveThumbImageError;

  /// {@template flutter.material.switch.materialTapTargetSize}
  /// Configures the minimum size of the tap target.
  /// {@endtemplate}
  ///
  /// If null, then the value of [SwitchThemeData.materialTapTargetSize] is
  /// used. If that is also null, then the value of
  /// [ThemeData.materialTapTargetSize] is used.
  ///
  /// See also:
  ///
  ///  * [MaterialTapTargetSize], for a description of how this affects tap targets.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// {@macro flutter.cupertino.CupertinoSwitch.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@template flutter.material.switch.mouseCursor}
  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  /// {@endtemplate}
  ///
  /// If null, then the value of [SwitchThemeData.mouseCursor] is used. If that
  /// is also null, then [WidgetStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// The color for the button's [Material] when it has the input focus.
  ///
  /// If [overlayColor] returns a non-null color in the [WidgetState.focused]
  /// state, it will be used instead.
  ///
  /// If null, then the value of [SwitchThemeData.overlayColor] is used in the
  /// focused state. If that is also null, then the value of
  /// [ThemeData.focusColor] is used.
  final Color? focusColor;

  /// The color for the button's [Material] when a pointer is hovering over it.
  ///
  /// If [overlayColor] returns a non-null color in the [WidgetState.hovered]
  /// state, it will be used instead.
  ///
  /// If null, then the value of [SwitchThemeData.overlayColor] is used in the
  /// hovered state. If that is also null, then the value of
  /// [ThemeData.hoverColor] is used.
  final Color? hoverColor;

  /// {@template flutter.material.switch.splashRadius}
  /// The splash radius of the circular [Material] ink response.
  /// {@endtemplate}
  ///
  /// If null, then the value of [SwitchThemeData.splashRadius] is used. If that
  /// is also null, then [kRadialReactionRadius] is used.
  final double? splashRadius;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.material.inkwell.onFocusChange}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The amount of space to surround the child inside the bounds of the [Switch].
  ///
  /// Defaults to horizontal padding of 4 pixels. If [ThemeData.useMaterial3] is false,
  /// then there is no padding by default.
  final EdgeInsetsGeometry? padding;

  /// Creates a [JustSwitch] widget.
  ///
  /// The [name] parameter is required for form integration. Most other parameters
  /// match their [Switch] equivalents. The [validators] parameter is form-specific
  /// and used for validation.
  ///
  /// Example:
  /// ```dart
  /// JustSwitch(
  ///   name: 'rememberMe',
  ///   initialValue: false,
  ///   activeThumbColor: Colors.green,
  ///   activeTrackColor: Colors.greenAccent,
  /// )
  /// ```
  const JustSwitch({
    super.key,
    required this.name,
    this.initialValue,
    this.validators = const [],
    this.onChanged,
    this.activeThumbColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.activeThumbImage,
    this.onActiveThumbImageError,
    this.inactiveThumbImage,
    this.onInactiveThumbImageError,
    this.materialTapTargetSize,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.splashRadius,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.padding,
  });

  /// Builds the switch widget integrated with the form system.
  ///
  /// This method wraps the switch with a [JustField] widget to integrate
  /// with the form controller. It:
  /// 1. Sets up value synchronization between the switch and form state
  /// 2. Handles validation
  /// 3. Allows dynamic property overrides via field attributes
  /// 4. Builds a [Switch] with all standard properties
  ///
  /// The [notifyInternalUpdate] is set to true for switches so the UI updates
  /// immediately when the user toggles the switch.
  ///
  /// Dynamic properties can be changed at runtime via [controller.setAttribute()]:
  /// ```dart
  /// controller.setAttribute('fieldName', 'activeThumbColor', Colors.blue);
  /// ```
  @override
  Widget build(BuildContext context) {
    return JustField<bool>(
      name: name,
      initialValue: initialValue,
      validators: validators,
      notifyInternalUpdate: true,
      onChanged: onChanged == null
          ? null
          : (value, isInternalUpdate) {
              onChanged?.call(value ?? false);
            },
      builder: (context, state) {
        return Switch(
          value: state.value ?? false,
          onChanged: (value) {
            state.setValue(value);
          },
          activeThumbColor:
              state.getAttribute('activeThumbColor') ?? activeThumbColor,
          activeTrackColor:
              state.getAttribute('activeTrackColor') ?? activeTrackColor,
          inactiveThumbColor:
              state.getAttribute('inactiveThumbColor') ?? inactiveThumbColor,
          inactiveTrackColor:
              state.getAttribute('inactiveTrackColor') ?? inactiveTrackColor,
          activeThumbImage:
              state.getAttribute('activeThumbImage') ?? activeThumbImage,
          onActiveThumbImageError:
              state.getAttribute('onActiveThumbImageError') ??
              onActiveThumbImageError,
          inactiveThumbImage:
              state.getAttribute('inactiveThumbImage') ?? inactiveThumbImage,
          onInactiveThumbImageError:
              state.getAttribute('onInactiveThumbImageError') ??
              onInactiveThumbImageError,
          materialTapTargetSize:
              state.getAttribute('materialTapTargetSize') ??
              materialTapTargetSize,
          dragStartBehavior:
              state.getAttribute('dragStartBehavior') ?? dragStartBehavior,
          mouseCursor: state.getAttribute('mouseCursor') ?? mouseCursor,
          focusColor: state.getAttribute('focusColor') ?? focusColor,
          hoverColor: state.getAttribute('hoverColor') ?? hoverColor,
          splashRadius: state.getAttribute('splashRadius') ?? splashRadius,
          focusNode: state.getAttribute('focusNode') ?? focusNode,
          onFocusChange: state.getAttribute('onFocusChange') ?? onFocusChange,
          autofocus: state.getAttribute('autofocus') ?? autofocus,
          padding: state.getAttribute('padding') ?? padding,
        );
      },
    );
  }
}
