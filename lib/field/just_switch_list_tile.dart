import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_form/just_form_builder.dart';

/// This class, `JustSwitchListTile`, is a stateless widget in Flutter that provides a switch list tile for a form. Here's a summary of what each method does:
/// - `name`: The name of the field in the form. This is required for validation.
/// - `initialValue`: The initial value of the field. This value is ignored if it's already set in the `JustFormController` or `JustForm`.
/// - `validators`: A list of validators to check the value of the field against.
/// - `onChanged`: A callback function that is called when the user toggles the switch on or off.
/// - `activeThumbColor`, `activeTrackColor`, `inactiveThumbColor`, `inactiveTrackColor`, `activeThumbImage`, `onActiveThumbImageError`, `inactiveThumbImage`, `onInactiveThumbImageError`, `materialTapTargetSize`, `dragStartBehavior`, `mouseCursor`, `splashRadius`, `focusNode`, `onFocusChange`, `autofocus`, `tileColor`, `title`, `subtitle`, `isThreeLine`, `dense`, `contentPadding`, `secondary`, `selected`, `controlAffinity`, `shape`, `selectedTileColor`, `visualDensity`, `enableFeedback`, `hoverColor`, `internalAddSemanticForOnTap`: These are optional parameters that customize the appearance and behavior of the switch list tile.
/// - `build(BuildContext context)`: This method builds the widget and returns a `JustField<bool>` with a `SwitchListTile` as its builder. The `SwitchListTile` widget is configured with the parameters passed to the `JustSwitchListTile` constructor and the values from the `JustField` state.
class JustSwitchListTile extends StatelessWidget {
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

  /// Called when the user toggles the switch on or off.
  ///
  /// The switch passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the switch tile with the
  /// new value.
  ///
  /// If null, the switch will be displayed as disabled.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// {@tool snippet}
  /// ```dart
  /// SwitchListTile(
  ///   value: _isSelected,
  ///   onChanged: (bool newValue) {
  ///     setState(() {
  ///       _isSelected = newValue;
  ///     });
  ///   },
  ///   title: const Text('Selection'),
  /// )
  /// ```
  /// {@end-tool}
  final ValueChanged<bool>? onChanged;

  final bool saveValueOnDestroy;

  /// {@macro flutter.material.switch.activeThumbColor}
  ///
  /// Defaults to [ColorScheme.secondary] of the current [Theme].
  final Color? activeThumbColor;

  /// {@macro flutter.material.switch.activeTrackColor}
  ///
  /// Defaults to [ColorScheme.secondary] with the opacity set at 50%.
  ///
  /// Ignored if created with [SwitchListTile.adaptive].
  final Color? activeTrackColor;

  /// {@macro flutter.material.switch.inactiveThumbColor}
  ///
  /// Defaults to the colors described in the Material design specification.
  ///
  /// Ignored if created with [SwitchListTile.adaptive].
  final Color? inactiveThumbColor;

  /// {@macro flutter.material.switch.inactiveTrackColor}
  ///
  /// Defaults to the colors described in the Material design specification.
  ///
  /// Ignored if created with [SwitchListTile.adaptive].
  final Color? inactiveTrackColor;

  /// {@macro flutter.material.switch.activeThumbImage}
  final ImageProvider? activeThumbImage;

  /// {@macro flutter.material.switch.onActiveThumbImageError}
  final ImageErrorListener? onActiveThumbImageError;

  /// {@macro flutter.material.switch.inactiveThumbImage}
  ///
  /// Ignored if created with [SwitchListTile.adaptive].
  final ImageProvider? inactiveThumbImage;

  /// {@macro flutter.material.switch.onInactiveThumbImageError}
  final ImageErrorListener? onInactiveThumbImageError;

  /// {@macro flutter.material.switch.materialTapTargetSize}
  ///
  /// defaults to [MaterialTapTargetSize.shrinkWrap].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// {@macro flutter.cupertino.CupertinoSwitch.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

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
  /// If null, then the value of [SwitchThemeData.mouseCursor] is used. If that
  /// is also null, then [WidgetStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// {@macro flutter.material.switch.splashRadius}
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

  /// A widget to display on the opposite side of the tile from the switch.
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

  /// The tile's internal padding.
  ///
  /// Insets a [SwitchListTile]'s contents: its [title], [subtitle],
  /// [secondary], and [Switch] widgets.
  ///
  /// If null, [ListTile]'s default of `EdgeInsets.symmetric(horizontal: 16.0)`
  /// is used.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to render icons and text in the [activeThumbColor].
  ///
  /// No effort is made to automatically coordinate the [selected] state and the
  /// [value] state. To have the list tile appear selected when the switch is
  /// on, pass the same value to both.
  ///
  /// Normally, this property is left to its default value, false.
  final bool selected;

  /// Defines the position of control and [secondary], relative to text.
  ///
  /// By default, the value of [controlAffinity] is [ListTileControlAffinity.platform].
  final ListTileControlAffinity? controlAffinity;

  /// {@macro flutter.material.ListTile.shape}
  final ShapeBorder? shape;

  /// If non-null, defines the background color when [SwitchListTile.selected] is true.
  final Color? selectedTileColor;

  /// Defines how compact the list tile's layout will be.
  ///
  /// {@macro flutter.material.themedata.visualDensity}
  final VisualDensity? visualDensity;

  /// {@macro flutter.material.ListTile.enableFeedback}
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  /// The color for the tile's [Material] when a pointer is hovering over it.
  final Color? hoverColor;

  /// Whether to add button:true to the semantics if onTap is provided.
  /// This is a temporary flag to help changing the behavior of ListTile onTap semantics.
  ///
  // the default value to true.
  final bool internalAddSemanticForOnTap;

  const JustSwitchListTile({
    super.key,

    required this.name,
    this.initialValue,
    this.saveValueOnDestroy = true,
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
    this.splashRadius,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.tileColor,
    this.title,
    this.subtitle,
    this.isThreeLine,
    this.dense,
    this.contentPadding,
    this.secondary,
    this.selected = false,
    this.controlAffinity,
    this.shape,
    this.selectedTileColor,
    this.visualDensity,
    this.enableFeedback,
    this.hoverColor,
    this.internalAddSemanticForOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    return JustField<bool>(
      name: name,
      initialValue: initialValue ?? false,
      validators: validators,
      notifyInternalUpdate: true,
      saveValueOnDestroy: saveValueOnDestroy,
      onChanged: onChanged == null
          ? null
          : (value, isInternalUpdate) {
              onChanged?.call(value ?? false);
            },
      builder: (context, state) {
        return SwitchListTile(
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
          splashRadius: state.getAttribute('splashRadius') ?? splashRadius,
          focusNode: state.getAttribute('focusNode') ?? focusNode,
          onFocusChange: state.getAttribute('onFocusChange') ?? onFocusChange,
          autofocus: state.getAttribute('autofocus') ?? autofocus,
          tileColor: state.getAttribute('tileColor') ?? tileColor,
          title: state.getAttribute('title') ?? title,
          subtitle: state.getAttribute('subtitle') ?? subtitle,
          isThreeLine: state.getAttribute('isThreeLine') ?? isThreeLine,
          dense: state.getAttribute('dense') ?? dense,
          contentPadding:
              state.getAttribute('contentPadding') ?? contentPadding,
          secondary: state.getAttribute('secondary') ?? secondary,
          selected: state.getAttribute('selected') ?? selected,
          controlAffinity:
              state.getAttribute('controlAffinity') ?? controlAffinity,
          shape: state.getAttribute('shape') ?? shape,
          selectedTileColor:
              state.getAttribute('selectedTileColor') ?? selectedTileColor,
          visualDensity: state.getAttribute('visualDensity') ?? visualDensity,
          enableFeedback:
              state.getAttribute('enableFeedback') ?? enableFeedback,
          hoverColor: state.getAttribute('hoverColor') ?? hoverColor,
          internalAddSemanticForOnTap:
              state.getAttribute('internalAddSemanticForOnTap') ??
              internalAddSemanticForOnTap,
        );
      },
    );
  }
}
