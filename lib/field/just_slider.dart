import 'package:flutter/material.dart';
import 'package:just_form/just_form.dart';
import 'package:just_form/just_validator.dart';

class JustSlider extends StatelessWidget {
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
  final double? initialValue;

  /// A list of validators to check the value of the field against.
  ///
  /// These validators will be run whenever the value of the field changes.
  ///
  /// The validators will be passed the current value of the field and the
  /// entire form values.
  ///
  /// If any of the validators return an error string, the field will be
  /// marked as invalid.
  final List<JustValidator<double>> validators;

  /// The secondary track value for this slider.
  ///
  /// If not null, a secondary track using [Slider.secondaryActiveColor] color
  /// is drawn between the thumb and this value, over the inactive track.
  ///
  /// If less than [Slider.value], then the secondary track is not shown.
  ///
  /// It can be ideal for media scenarios such as showing the buffering progress
  /// while the [Slider.value] shows the play progress.
  final double? secondaryTrackValue;

  /// Called during a drag when the user is selecting a new value for the slider
  /// by dragging.
  ///
  /// The slider passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the slider with the new
  /// value.
  ///
  /// If null, the slider will be displayed as disabled.
  ///
  /// The callback provided to onChanged should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Slider(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when the user starts
  ///    changing the value.
  ///  * [onChangeEnd] for a callback that is called when the user stops
  ///    changing the value.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts selecting a new value for the slider.
  ///
  /// This callback shouldn't be used to update the slider [value] (use
  /// [onChanged] for that), but rather to be notified when the user has started
  /// selecting a new value by starting a drag or with a tap.
  ///
  /// The value passed will be the last [value] that the slider had before the
  /// change began.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Slider(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  ///   onChangeStart: (double startValue) {
  ///     print('Started change at $startValue');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeEnd] for a callback that is called when the value change is
  ///    complete.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done selecting a new value for the slider.
  ///
  /// This callback shouldn't be used to update the slider [value] (use
  /// [onChanged] for that), but rather to know when the user has completed
  /// selecting a new [value] by ending a drag or a click.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Slider(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  ///   onChangeEnd: (double newValue) {
  ///     print('Ended change on $newValue');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when a value change
  ///    begins.
  final ValueChanged<double>? onChangeEnd;

  /// The minimum value the user can select.
  ///
  /// Defaults to 0.0. Must be less than or equal to [max].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double min;

  /// The maximum value the user can select.
  ///
  /// Defaults to 1.0. Must be greater than or equal to [min].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double max;

  /// The number of discrete divisions.
  ///
  /// Typically used with [label] to show the current discrete value.
  ///
  /// If null, the slider is continuous.
  final int? divisions;

  /// A label to show above the slider when the slider is active and
  /// [SliderThemeData.showValueIndicator] is satisfied.
  ///
  /// It is used to display the value of a discrete slider, and it is displayed
  /// as part of the value indicator shape.
  ///
  /// The label is rendered using the active [ThemeData]'s [TextTheme.bodyLarge]
  /// text style, with the theme data's [ColorScheme.onPrimary] color. The
  /// label's text style can be overridden with
  /// [SliderThemeData.valueIndicatorTextStyle].
  ///
  /// If null, then the value indicator will not be displayed.
  ///
  /// Ignored if this slider is created with [Slider.adaptive].
  ///
  /// See also:
  ///
  ///  * [SliderComponentShape] for how to create a custom value indicator
  ///    shape.
  final String? label;

  /// The color to use for the portion of the slider track that is active.
  ///
  /// The "active" side of the slider is the side between the thumb and the
  /// minimum value.
  ///
  /// If null, [SliderThemeData.activeTrackColor] of the ambient
  /// [SliderTheme] is used. If that is null, [ColorScheme.primary] of the
  /// surrounding [ThemeData] is used.
  ///
  /// Using a [SliderTheme] gives much more fine-grained control over the
  /// appearance of various components of the slider.
  final Color? activeColor;

  /// The color for the inactive portion of the slider track.
  ///
  /// The "inactive" side of the slider is the side between the thumb and the
  /// maximum value.
  ///
  /// If null, [SliderThemeData.inactiveTrackColor] of the ambient [SliderTheme]
  /// then [ColorScheme.secondaryContainer] is used and if [ThemeData.useMaterial3]
  /// is false, [ColorScheme.primary] with an opacity of 0.24 is used. Otherwise,
  /// [ColorScheme.surfaceContainerHighest] is used.
  ///
  /// Using a [SliderTheme] gives much more fine-grained control over the
  /// appearance of various components of the slider.
  ///
  /// Ignored if this slider is created with [Slider.adaptive].
  final Color? inactiveColor;

  /// The color to use for the portion of the slider track between the thumb and
  /// the [Slider.secondaryTrackValue].
  ///
  /// Defaults to the [SliderThemeData.secondaryActiveTrackColor] of the current
  /// [SliderTheme].
  ///
  /// If that is also null, defaults to [ColorScheme.primary] with an
  /// opacity of 0.54.
  ///
  /// Using a [SliderTheme] gives much more fine-grained control over the
  /// appearance of various components of the slider.
  ///
  /// Ignored if this slider is created with [Slider.adaptive].
  final Color? secondaryActiveColor;

  /// The color of the thumb.
  ///
  /// If this color is null, [Slider] will use [activeColor], If [activeColor]
  /// is also null, [Slider] will use [SliderThemeData.thumbColor].
  ///
  /// If that is also null, defaults to [ColorScheme.primary].
  ///
  /// * [CupertinoSlider] will have a white thumb
  /// (like the native default iOS slider).
  final Color? thumbColor;

  /// {@template flutter.material.slider.mouseCursor}
  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.dragged].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  /// {@endtemplate}
  ///
  /// If null, then the value of [SliderThemeData.mouseCursor] is used. If that
  /// is also null, then [WidgetStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// The callback used to create a semantic value from a slider value.
  ///
  /// Defaults to formatting values as a percentage.
  ///
  /// This is used by accessibility frameworks like TalkBack on Android to
  /// inform users what the currently selected value is with more context.
  ///
  /// {@tool snippet}
  ///
  /// In the example below, a slider for currency values is configured to
  /// announce a value with a currency label.
  ///
  /// ```dart
  /// Slider(
  ///   value: _dollars.toDouble(),
  ///   min: 20.0,
  ///   max: 330.0,
  ///   label: '$_dollars dollars',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _dollars = newValue.round();
  ///     });
  ///   },
  ///   semanticFormatterCallback: (double newValue) {
  ///     return '${newValue.round()} dollars';
  ///   }
  ///  )
  /// ```
  /// {@end-tool}
  ///
  /// Ignored if this slider is created with [Slider.adaptive]
  final SemanticFormatterCallback? semanticFormatterCallback;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Allowed way for the user to interact with the [Slider].
  ///
  /// For example, if this is set to [SliderInteraction.tapOnly], the user can
  /// interact with the slider only by tapping anywhere on the track. Sliding
  /// will have no effect.
  ///
  /// Defaults to [SliderInteraction.tapAndSlide].
  final SliderInteraction? allowedInteraction;

  /// Determines the padding around the [Slider].
  ///
  /// If specified, this padding overrides the default vertical padding of
  /// the [Slider], defaults to the height of the overlay shape, and the
  /// horizontal padding, defaults to the width of the thumb shape or
  /// overlay shape, whichever is larger.
  final EdgeInsetsGeometry? padding;

  const JustSlider({
    super.key,
    required this.name,
    this.initialValue,
    this.validators = const [],
    this.secondaryTrackValue,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.secondaryActiveColor,
    this.thumbColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
    this.allowedInteraction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return JustField<double>(
      name: name,
      validators: validators,
      initialValue: initialValue ?? min,
      notifyInternalUpdate: true,
      builder: (context, state) {
        return Slider(
          value: state.value ?? min,
          onChanged: (value) {
            state.value = value;
            onChanged?.call(value);
          },
          onChangeEnd: (value) {
            onChangeEnd?.call(value);
          },
          onChangeStart: (value) {
            onChangeStart?.call(value);
          },

          secondaryTrackValue:
              state.getAttribute('secondaryTrackValue') ?? secondaryTrackValue,
          divisions: state.getAttribute('divisions') ?? divisions,
          label: state.getAttribute('label') ?? label,
          activeColor: state.getAttribute('activeColor') ?? activeColor,
          inactiveColor: state.getAttribute('inactiveColor') ?? inactiveColor,
          secondaryActiveColor:
              state.getAttribute('secondaryActiveColor') ??
              secondaryActiveColor,
          thumbColor: state.getAttribute('thumbColor') ?? thumbColor,
          mouseCursor: state.getAttribute('mouseCursor') ?? mouseCursor,
          semanticFormatterCallback:
              state.getAttribute('semanticFormatterCallback') ??
              semanticFormatterCallback,
          focusNode: state.getAttribute('focusNode') ?? focusNode,
          autofocus: state.getAttribute('autofocus') ?? autofocus,
          allowedInteraction:
              state.getAttribute('allowedInteraction') ?? allowedInteraction,
          padding: state.getAttribute('padding') ?? padding,
          min: state.getAttribute('min') ?? min,
          max: state.getAttribute('max') ?? max,
        );
      },
    );
  }
}
