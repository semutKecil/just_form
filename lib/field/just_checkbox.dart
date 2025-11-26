import 'package:flutter/material.dart';
import 'package:just_form/just_form_builder.dart';

/// The `JustCheckbox` class is a Flutter widget that represents a checkbox field in a form. It extends the `StatelessWidget` class. Here's a summary of what each field and method does:
///
/// - `name`: This is the name of the field in the form. It's used to identify the field in the `JustFormController` and is required for validation.
/// - `initialValue`: This is the initial value of the field. If the initial value is already set in the `JustFormController` or `JustForm`, this value is ignored.
/// - `validators`: This is a list of validators to check the value of the field against. These validators will be run whenever the value of the field changes.
/// - `onChanged`: This is a callback that is called when the value of the checkbox should change. The checkbox passes the new value to the callback but does not actually change state until the parent widget rebuilds the checkbox with the new value.
/// - `tristate`: If true, the checkbox's `value` can be true, false, or null. When a tri-state checkbox is tapped, its `onChanged` callback will be applied to true if the current value is false, to null if value is true, and to false if value is null (i.e. it cycles through false => true => null => false when tapped).
/// - `mouseCursor`: The cursor for a mouse pointer when it enters or is hovering over the widget.
/// - `activeColor`: The color to use when this checkbox is checked.
/// - `checkColor`: The color to use for the check icon when this checkbox is checked.
/// - `focusColor`: The color for the checkbox's Material when it has the input focus.
/// - `hoverColor`: The color for the checkbox's Material when a pointer is hovering over it.
/// - `splashRadius`: The splash radius of the circular Material ink response.
/// - `materialTapTargetSize`: Configures the minimum size of the tap target.
/// - `visualDensity`: Defines how compact the checkbox's layout will be.
/// - `focusNode`: The focus node for this checkbox.
/// - `autofocus`: Whether this checkbox should be focused when the form is first loaded.
/// - `shape`: The shape of the checkbox's Material.
/// - `side`: The color and width of the checkbox's border.
/// - `isError`: True if this checkbox wants to show an error state.
/// - `semanticLabel`: The semantic label for the checkbox that will be announced by screen readers.
///
/// The `build` method builds the widget and returns a `JustField<bool>` with a `Checkbox` as its builder. The `Checkbox` widget is configured with the parameters passed to the `JustCheckbox` constructor and the values from the `JustField` state.
class JustCheckbox extends StatelessWidget {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "name", "email",
  /// "password").
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
  final List<FormFieldValidator<bool>> validators;

  /// Called when the value of the checkbox should change.
  ///
  /// The checkbox passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the checkbox with the new
  /// value.
  ///
  /// If this callback is null, the checkbox will be displayed as disabled
  /// and will not respond to input gestures.
  ///
  /// When the checkbox is tapped, if [tristate] is false (the default) then
  /// the [onChanged] callback will be applied to `!value`. If [tristate] is
  /// true this callback cycle from false to true to null.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// Checkbox(
  ///   value: _throwShotAway,
  ///   onChanged: (bool? newValue) {
  ///     setState(() {
  ///       _throwShotAway = newValue!;
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<bool?>? onChanged;

  final bool saveValueOnDestroy;

  /// {@template flutter.material.checkbox.mouseCursor}
  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.selected].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  /// {@endtemplate}
  ///
  /// When [value] is null and [tristate] is true, [WidgetState.selected] is
  /// included as a state.
  ///
  /// If null, then the value of [CheckboxThemeData.mouseCursor] is used. If
  /// that is also null, then [WidgetStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// The color to use when this checkbox is checked.
  ///
  /// Defaults to [ColorScheme.secondary].
  ///
  /// If [fillColor] returns a non-null color in the [WidgetState.selected]
  /// state, it will be used instead of this color.
  final Color? activeColor;

  /// {@template flutter.material.checkbox.checkColor}
  /// The color to use for the check icon when this checkbox is checked.
  /// {@endtemplate}
  ///
  /// If null, then the value of [CheckboxThemeData.checkColor] is used. If
  /// that is also null, then Color(0xFFFFFFFF) is used.
  final Color? checkColor;

  /// If true the checkbox's [value] can be true, false, or null.
  ///
  /// [Checkbox] displays a dash when its value is null.
  ///
  /// When a tri-state checkbox ([tristate] is true) is tapped, its [onChanged]
  /// callback will be applied to true if the current value is false, to null if
  /// value is true, and to false if value is null (i.e. it cycles through false
  /// => true => null => false when tapped).
  ///
  /// If tristate is false (the default), [value] must not be null.
  final bool tristate;

  /// {@template flutter.material.checkbox.materialTapTargetSize}
  /// Configures the minimum size of the tap target.
  /// {@endtemplate}
  ///
  /// If null, then the value of [CheckboxThemeData.materialTapTargetSize] is
  /// used. If that is also null, then the value of
  /// [ThemeData.materialTapTargetSize] is used.
  ///
  /// See also:
  ///
  ///  * [MaterialTapTargetSize], for a description of how this affects tap targets.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// {@template flutter.material.checkbox.visualDensity}
  /// Defines how compact the checkbox's layout will be.
  /// {@endtemplate}
  ///
  /// {@macro flutter.material.themedata.visualDensity}
  ///
  /// If null, then the value of [CheckboxThemeData.visualDensity] is used. If
  /// that is also null and if [ThemeData.useMaterial3] is false, then the
  /// value of [ThemeData.visualDensity] is used. Otherwise, the default value
  /// is [VisualDensity.standard].
  ///
  /// See also:
  ///
  ///  * [ThemeData.visualDensity], which specifies the [visualDensity] for all
  ///    widgets within a [Theme].
  final VisualDensity? visualDensity;

  /// The color for the checkbox's [Material] when it has the input focus.
  ///
  /// If [overlayColor] returns a non-null color in the [WidgetState.focused]
  /// state, it will be used instead.
  ///
  /// If null, then the value of [CheckboxThemeData.overlayColor] is used in the
  /// focused state. If that is also null, then the value of
  /// [ThemeData.focusColor] is used.
  final Color? focusColor;

  /// {@template flutter.material.checkbox.hoverColor}
  /// The color for the checkbox's [Material] when a pointer is hovering over it.
  ///
  /// If [overlayColor] returns a non-null color in the [WidgetState.hovered]
  /// state, it will be used instead.
  /// {@endtemplate}
  ///
  /// If null, then the value of [CheckboxThemeData.overlayColor] is used in the
  /// hovered state. If that is also null, then the value of
  /// [ThemeData.hoverColor] is used.
  final Color? hoverColor;

  /// {@template flutter.material.checkbox.splashRadius}
  /// The splash radius of the circular [Material] ink response.
  /// {@endtemplate}
  ///
  /// If null, then the value of [CheckboxThemeData.splashRadius] is used. If
  /// that is also null, then [kRadialReactionRadius] is used.
  final double? splashRadius;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@template flutter.material.checkbox.shape}
  /// The shape of the checkbox's [Material].
  /// {@endtemplate}
  ///
  /// If this property is null then [CheckboxThemeData.shape] of [ThemeData.checkboxTheme]
  /// is used. If that's null then the shape will be a [RoundedRectangleBorder]
  /// with a circular corner radius of 1.0 in Material 2, and 2.0 in Material 3.
  final OutlinedBorder? shape;

  /// {@template flutter.material.checkbox.side}
  /// The color and width of the checkbox's border.
  ///
  /// This property can be a [WidgetStateBorderSide] that can
  /// specify different border color and widths depending on the
  /// checkbox's state.
  ///
  /// Resolves in the following states:
  ///  * [WidgetState.pressed].
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///  * [WidgetState.error].
  ///
  /// If this property is not a [WidgetStateBorderSide] and it is
  /// non-null, then it is only rendered when the checkbox's value is
  /// false. The difference in interpretation is for backwards
  /// compatibility.
  /// {@endtemplate}
  ///
  /// If this property is null, then [CheckboxThemeData.side] of
  /// [ThemeData.checkboxTheme] is used. If that is also null, then the side
  /// will be width 2.
  final BorderSide? side;

  /// {@template flutter.material.checkbox.isError}
  /// True if this checkbox wants to show an error state.
  ///
  /// The checkbox will have different default container color and check color when
  /// this is true. This is only used when [ThemeData.useMaterial3] is set to true.
  /// {@endtemplate}
  ///
  /// Defaults to false.
  final bool isError;

  /// {@template flutter.material.checkbox.semanticLabel}
  /// The semantic label for the checkbox that will be announced by screen readers.
  ///
  /// This is announced by assistive technologies (e.g TalkBack/VoiceOver).
  ///
  /// This label does not show in the UI.
  /// {@endtemplate}
  final String? semanticLabel;

  /// The width of a checkbox widget.
  static const double width = 18.0; // final _CheckboxType _checkboxType;

  const JustCheckbox({
    super.key,
    this.initialValue,
    this.validators = const [],
    required this.name,
    this.onChanged,
    this.saveValueOnDestroy = true,
    this.tristate = false,
    this.mouseCursor,
    this.activeColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,
    this.isError = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return JustField<bool>(
      name: name,
      initialValue: tristate ? initialValue : initialValue ?? false,
      notifyError: false,
      notifyInternalUpdate: true,
      validators: validators,
      saveValueOnDestroy: saveValueOnDestroy,
      onChanged: onChanged == null
          ? null
          : (value, isInternalUpdate) {
              onChanged?.call(value);
            },
      builder: (context, state) {
        return Checkbox(
          value: (state.getAttribute('tristate') ?? tristate)
              ? state.value
              : state.value ?? false,
          onChanged: (value) {
            state.setValue(value);
          },
          tristate: state.getAttribute('tristate') ?? tristate,
          mouseCursor: state.getAttribute('mouseCursor') ?? mouseCursor,
          activeColor: state.getAttribute('activeColor') ?? activeColor,
          checkColor: state.getAttribute('checkColor') ?? checkColor,
          focusColor: state.getAttribute('focusColor') ?? focusColor,
          hoverColor: state.getAttribute('hoverColor') ?? hoverColor,
          splashRadius: state.getAttribute('splashRadius') ?? splashRadius,
          materialTapTargetSize:
              state.getAttribute('materialTapTargetSize') ??
              materialTapTargetSize,
          visualDensity: state.getAttribute('visualDensity') ?? visualDensity,
          focusNode: state.getAttribute('focusNode') ?? focusNode,
          autofocus: state.getAttribute('autofocus') ?? autofocus,
          shape: state.getAttribute('shape') ?? shape,
          side: state.getAttribute('side') ?? side,
          isError: state.getAttribute('isError') ?? isError,
          semanticLabel: state.getAttribute('semanticLabel') ?? semanticLabel,
        );
      },
    );
  }
}
