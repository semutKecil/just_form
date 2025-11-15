import 'package:flutter/material.dart';
import 'package:just_form/just_form_builder.dart';
import 'package:just_form/just_validator.dart';

/// The `JustCheckboxListTile` class is a stateless widget in Flutter that provides a checkbox list tile for a form. Here's a summary of what each method does:
///
/// - `name`: The name of the field in the form. This is required for validation.
/// - `initialValue`: The initial value of the field. This value is ignored if it's already set in the `JustFormController` or `JustForm`.
/// - `validators`: A list of validators to check the value of the field against.
/// - `onChanged`: A callback function that is called when the checkbox value should change.
/// - `mouseCursor`: The cursor for a mouse pointer when it enters or is hovering over the widget.
/// - `activeColor`: The color to use when the checkbox is checked.
/// - `checkColor`: The color to use for the check icon when the checkbox is checked.
/// - `hoverColor`: The color to use when the checkbox is hovered.
/// - `splashRadius`: The radius of the splash effect when the checkbox is pressed.
/// - `materialTapTargetSize`: The size of the tap target for the checkbox.
/// - `visualDensity`: The visual density of the checkbox.
/// - `focusNode`: The focus node for the checkbox.
/// - `autofocus`: Whether the checkbox should be focused automatically.
/// - `shape`: The shape of the checkbox.
/// - `side`: The side of the checkbox.
/// - `isError`: Whether the checkbox is in an error state.
/// - `tileColor`: The color of the checkbox tile.
/// - `title`: The primary content of the checkbox tile.
/// - `subtitle`: The additional content displayed below the title.
/// - `isThreeLine`: Whether the checkbox tile is intended to display three lines of text.
/// - `dense`: Whether the checkbox tile is part of a vertically dense list.
/// - `secondary`: The widget displayed on the opposite side of the tile from the checkbox.
/// - `selected`: Whether the checkbox tile is selected.
/// - `controlAffinity`: The alignment of the checkbox and the title.
/// - `contentPadding`: The padding surrounding the checkbox, title, subtitle, and secondary widget.
/// - `tristate`: Whether the checkbox can have a true, false, or null value.
/// - `checkboxShape`: The shape of the checkbox.
/// - `selectedTileColor`: The background color when the checkbox tile is selected.
/// - `onFocusChange`: The callback function called when the checkbox tile loses focus.
/// - `enableFeedback`: Whether feedback should be enabled for the checkbox tile.
/// - `checkboxSemanticLabel`: The semantic label for the checkbox.
/// - `checkboxScaleFactor`: The scaling factor applied to the checkbox.
/// - `titleAlignment`: The alignment of the title and subtitle.
/// - `internalAddSemanticForOnTap`: Whether to add button:true to the semantics if onTap is provided. This is a temporary flag to help changing the behavior of ListTile onTap semantics.
///
/// The `build` method builds the widget and returns a `JustField<bool>` with a `CheckboxListTile` as its builder. The `CheckboxListTile` widget is configured with the parameters passed to the `JustCheckboxListTile` constructor and the values from the `JustField` state.
class JustCheckboxListTile extends StatelessWidget {
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
  final List<JustValidator<bool>> validators;

  /// Called when the value of the checkbox should change.
  ///
  /// The checkbox passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the checkbox tile with the
  /// new value.
  ///
  /// If null, the checkbox will be displayed as disabled.
  ///
  /// {@tool snippet}
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// CheckboxListTile(
  ///   value: _throwShotAway,
  ///   onChanged: (bool? newValue) {
  ///     setState(() {
  ///       _throwShotAway = newValue;
  ///     });
  ///   },
  ///   title: const Text('Throw away your shot'),
  /// )
  /// ```
  /// {@end-tool}
  final ValueChanged<bool?>? onChanged;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.disabled].
  ///
  /// If null, then the value of [CheckboxThemeData.mouseCursor] is used. If
  /// that is also null, then [WidgetStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// The color to use when this checkbox is checked.
  ///
  /// Defaults to [ColorScheme.secondary] of the current [Theme].
  final Color? activeColor;

  /// The color to use for the check icon when this checkbox is checked.
  ///
  /// Defaults to Color(0xFFFFFFFF).
  final Color? checkColor;

  /// {@macro flutter.material.checkbox.hoverColor}
  final Color? hoverColor;

  /// {@macro flutter.material.checkbox.splashRadius}
  ///
  /// If null, then the value of [CheckboxThemeData.splashRadius] is used. If
  /// that is also null, then [kRadialReactionRadius] is used.
  final double? splashRadius;

  /// {@macro flutter.material.checkbox.materialTapTargetSize}
  ///
  /// Defaults to [MaterialTapTargetSize.shrinkWrap].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Defines how compact the list tile's layout will be.
  ///
  /// {@macro flutter.material.themedata.visualDensity}
  final VisualDensity? visualDensity;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.material.ListTile.shape}
  final ShapeBorder? shape;

  /// {@macro flutter.material.checkbox.side}
  ///
  /// The given value is passed directly to [Checkbox.side].
  ///
  /// If this property is null, then [CheckboxThemeData.side] of
  /// [ThemeData.checkboxTheme] is used. If that is also null, then the side
  /// will be width 2.
  final BorderSide? side;

  /// {@macro flutter.material.checkbox.isError}
  ///
  /// Defaults to false.
  final bool isError;

  /// {@macro flutter.material.ListTile.tileColor}
  final Color? tileColor;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// A widget to display on the opposite side of the tile from the checkbox.
  ///
  /// Typically an [Icon] widget.
  final Widget? secondary;

  /// Whether this list tile is intended to display three lines of text.
  ///
  /// If null, the value from [ListTileThemeData.isThreeLine] is used.
  /// If that is also null, the value from [ThemeData.listTileTheme] is used.
  /// If still null, the default value is `false`.
  final bool? isThreeLine;

  /// Whether this list tile is part of a vertically dense list.
  ///
  /// If this property is null then its value is based on [ListTileThemeData.dense].
  final bool? dense;

  /// Whether to render icons and text in the [activeColor].
  ///
  /// No effort is made to automatically coordinate the [selected] state and the
  /// [value] state. To have the list tile appear selected when the checkbox is
  /// checked, pass the same value to both.
  ///
  /// Normally, this property is left to its default value, false.
  final bool selected;

  /// Where to place the control relative to the text.
  final ListTileControlAffinity? controlAffinity;

  /// Defines insets surrounding the tile's contents.
  ///
  /// This value will surround the [Checkbox], [title], [subtitle], and [secondary]
  /// widgets in [CheckboxListTile].
  ///
  /// When the value is null, the [contentPadding] is `EdgeInsets.symmetric(horizontal: 16.0)`.
  final EdgeInsetsGeometry? contentPadding;

  /// If true the checkbox's [value] can be true, false, or null.
  ///
  /// Checkbox displays a dash when its value is null.
  ///
  /// When a tri-state checkbox ([tristate] is true) is tapped, its [onChanged]
  /// callback will be applied to true if the current value is false, to null if
  /// value is true, and to false if value is null (i.e. it cycles through false
  /// => true => null => false when tapped).
  ///
  /// If tristate is false (the default), [value] must not be null.
  final bool tristate;

  /// {@macro flutter.material.checkbox.shape}
  ///
  /// If this property is null then [CheckboxThemeData.shape] of [ThemeData.checkboxTheme]
  /// is used. If that's null then the shape will be a [RoundedRectangleBorder]
  /// with a circular corner radius of 1.0.
  final OutlinedBorder? checkboxShape;

  /// If non-null, defines the background color when [CheckboxListTile.selected] is true.
  final Color? selectedTileColor;

  /// {@macro flutter.material.inkwell.onFocusChange}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.material.ListTile.enableFeedback}
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  /// Whether the CheckboxListTile is interactive.
  ///
  /// If false, this list tile is styled with the disabled color from the
  /// current [Theme] and the [ListTile.onTap] callback is
  /// inoperative.
  final bool? enabled;

  /// Defines how [ListTile.leading] and [ListTile.trailing] are
  /// vertically aligned relative to the [ListTile]'s titles
  /// ([ListTile.title] and [ListTile.subtitle]).
  ///
  /// If this property is null then [ListTileThemeData.titleAlignment]
  /// is used. If that is also null then [ListTileTitleAlignment.threeLine]
  /// is used.
  ///
  /// See also:
  ///
  /// * [ListTileTheme.of], which returns the nearest [ListTileTheme]'s
  ///   [ListTileThemeData].
  final ListTileTitleAlignment? titleAlignment;

  /// Whether to add button:true to the semantics if onTap is provided.
  /// This is a temporary flag to help changing the behavior of ListTile onTap semantics.
  ///
  // the default value to true.
  final bool internalAddSemanticForOnTap;

  /// Controls the scaling factor applied to the [Checkbox] within the [CheckboxListTile].
  ///
  /// Defaults to 1.0.
  final double checkboxScaleFactor;

  /// {@macro flutter.material.checkbox.semanticLabel}
  final String? checkboxSemanticLabel;

  const JustCheckboxListTile({
    super.key,
    required this.name,
    this.initialValue,
    this.validators = const [],
    this.onChanged,
    this.mouseCursor,
    this.activeColor,
    this.checkColor,
    this.hoverColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,
    this.isError = false,
    this.enabled,
    this.tileColor,
    this.title,
    this.subtitle,
    this.isThreeLine,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity,
    this.contentPadding,
    this.tristate = false,
    this.checkboxShape,
    this.selectedTileColor,
    this.onFocusChange,
    this.enableFeedback,
    this.checkboxSemanticLabel,
    this.checkboxScaleFactor = 1.0,
    this.titleAlignment,
    this.internalAddSemanticForOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    return JustField<bool>(
      name: name,
      validators: validators,
      initialValue: initialValue,
      notifyInternalUpdate: true,
      onChanged: onChanged == null
          ? null
          : (value, isInternalUpdate) {
              onChanged?.call(value);
            },
      builder: (context, state) {
        return CheckboxListTile(
          value: (state.getAttribute('tristate') ?? tristate)
              ? state.value
              : state.value ?? false,
          onChanged: (value) {
            state.setValue(value);
          },
          mouseCursor: state.getAttribute('mouseCursor') ?? mouseCursor,
          activeColor: state.getAttribute('activeColor') ?? activeColor,
          checkColor: state.getAttribute('checkColor') ?? checkColor,
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
          enabled: state.getAttribute('enabled') ?? enabled,
          tileColor: state.getAttribute('tileColor') ?? tileColor,
          title: state.getAttribute('title') ?? title,
          subtitle: state.getAttribute('subtitle') ?? subtitle,
          isThreeLine: state.getAttribute('isThreeLine') ?? isThreeLine,
          dense: state.getAttribute('dense') ?? dense,
          secondary: state.getAttribute('secondary') ?? secondary,
          selected: state.getAttribute('selected') ?? selected,
          controlAffinity:
              state.getAttribute('controlAffinity') ?? controlAffinity,
          contentPadding:
              state.getAttribute('contentPadding') ?? contentPadding,
          tristate: state.getAttribute('tristate') ?? tristate,
          checkboxShape: state.getAttribute('checkboxShape') ?? checkboxShape,
          selectedTileColor:
              state.getAttribute('selectedTileColor') ?? selectedTileColor,
          onFocusChange: state.getAttribute('onFocusChange') ?? onFocusChange,
          enableFeedback:
              state.getAttribute('enableFeedback') ?? enableFeedback,
          checkboxSemanticLabel:
              state.getAttribute('checkboxSemanticLabel') ??
              checkboxSemanticLabel,
          checkboxScaleFactor:
              state.getAttribute('checkboxScaleFactor') ?? checkboxScaleFactor,
          titleAlignment:
              state.getAttribute('titleAlignment') ?? titleAlignment,
          internalAddSemanticForOnTap:
              state.getAttribute('internalAddSemanticForOnTap') ??
              internalAddSemanticForOnTap,
        );
      },
    );
  }
}
