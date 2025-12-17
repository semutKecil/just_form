import 'package:flutter/material.dart';
import 'package:just_form/src/ui/just_form_builder.dart';

/// The `JustRangeSlider` class is a Flutter widget that provides a range slider for a form. Here's a summary of what each method does:
///
/// - `name`: This is the name of the field in the form. It's used to identify the field in the `JustFormController` and is required for validation.
/// - `initialValue`: This is the initial value of the field. If the initial value is already set in the `JustFormController` or `JustForm`, this value is ignored.
/// - `validators`: This is a list of validators to check the value of the field against. These validators will be run whenever the value of the field changes.
/// - `onChanged`: This is a callback that is called when the user is selecting a new value for the slider by dragging. It should update the state of the parent `StatefulWidget` using the `State.setState` method.
/// - `onChangeStart`: This is a callback that is called when the user starts changing the values of the slider. It should be used to be notified when the user has started selecting a new value by starting a drag or with a tap.
/// - `onChangeEnd`: This is a callback that is called when the user is done selecting new values for the slider. It differs from `onChanged` because it is only called once at the end of the interaction.
/// - `min` and `max`: These define the range of values the user can select.
/// - `divisions`: This defines the number of discrete divisions. If null, the slider is continuous.
/// - `labels`: This is used to show the current discrete values of the slider.
/// - `activeColor` and `inactiveColor`: These are used to customize the appearance of the slider.
/// - `semanticFormatterCallback`: This is used to create a semantic value from the slider's values.
/// - `padding`: This determines the padding around the slider.
///
/// The `build` method builds the widget and returns a `JustField<RangeValues>` with a `RangeSlider` as its builder. The `RangeSlider` widget is configured with the parameters passed to the `JustRangeSlider` constructor and the values from the `JustField` state.
class JustRangeSlider extends StatelessWidget
    implements JustFieldAbstract<RangeValues> {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "name", "email",
  /// "password").
  @override
  final String name;

  /// The initial value of the field. This value is ignored when the initial value
  /// is already set on the [JustFormController] or [JustForm].
  @override
  final RangeValues? initialValue;

  /// Called when the user is selecting a new value for the slider by dragging.
  ///
  /// The slider passes the new values to the callback but does not actually
  /// change state until the parent widget rebuilds the slider with the new
  /// values.
  ///
  /// If null, the slider will be displayed as disabled.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// RangeSlider(
  ///   values: _rangeValues,
  ///   min: 1.0,
  ///   max: 10.0,
  ///   onChanged: (RangeValues newValues) {
  ///     setState(() {
  ///       _rangeValues = newValues;
  ///     });
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart], which is called when the user starts changing the
  ///    values.
  ///  * [onChangeEnd], which is called when the user stops changing the values.
  @override
  final ValueChanged<RangeValues>? onChanged;

  @override
  final bool keepValueOnDestroy;

  @override
  final Map<String, dynamic> initialAttributes;

  /// Called when the user starts selecting new values for the slider.
  ///
  /// This callback shouldn't be used to update the slider [values] (use
  /// [onChanged] for that). Rather, it should be used to be notified when the
  /// user has started selecting a new value by starting a drag or with a tap.
  ///
  /// The values passed will be the last [values] that the slider had before the
  /// change began.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// RangeSlider(
  ///   values: _rangeValues,
  ///   min: 1.0,
  ///   max: 10.0,
  ///   onChanged: (RangeValues newValues) {
  ///     setState(() {
  ///       _rangeValues = newValues;
  ///     });
  ///   },
  ///   onChangeStart: (RangeValues startValues) {
  ///     print('Started change at $startValues');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeEnd] for a callback that is called when the value change is
  ///    complete.
  final ValueChanged<RangeValues>? onChangeStart;

  /// Called when the user is done selecting new values for the slider.
  ///
  /// This differs from [onChanged] because it is only called once at the end
  /// of the interaction, while [onChanged] is called as the value is getting
  /// updated within the interaction.
  ///
  /// This callback shouldn't be used to update the slider [values] (use
  /// [onChanged] for that). Rather, it should be used to know when the user has
  /// completed selecting a new [values] by ending a drag or a click.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// RangeSlider(
  ///   values: _rangeValues,
  ///   min: 1.0,
  ///   max: 10.0,
  ///   onChanged: (RangeValues newValues) {
  ///     setState(() {
  ///       _rangeValues = newValues;
  ///     });
  ///   },
  ///   onChangeEnd: (RangeValues endValues) {
  ///     print('Ended change at $endValues');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when a value change
  ///    begins.
  final ValueChanged<RangeValues>? onChangeEnd;

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
  /// Typically used with [labels] to show the current discrete values.
  ///
  /// If null, the slider is continuous.
  final int? divisions;

  /// Labels to show as text in the [SliderThemeData.rangeValueIndicatorShape]
  /// when the slider is active and [SliderThemeData.showValueIndicator]
  /// is satisfied.
  ///
  /// There are two labels: one for the start thumb and one for the end thumb.
  ///
  /// Each label is rendered using the active [ThemeData]'s
  /// [TextTheme.bodyLarge] text style, with the theme data's
  /// [ColorScheme.onPrimary] color. The label's text style can be overridden
  /// with [SliderThemeData.valueIndicatorTextStyle].
  ///
  /// If null, then the value indicator will not be displayed.
  ///
  /// See also:
  ///
  ///  * [RangeSliderValueIndicatorShape] for how to create a custom value
  ///    indicator shape.
  final RangeLabels? labels;

  /// The color of the track's active segment, i.e. the span of track between
  /// the thumbs.
  ///
  /// Defaults to [ColorScheme.primary].
  ///
  /// Using a [SliderTheme] gives more fine-grained control over the
  /// appearance of various components of the slider.
  final Color? activeColor;

  /// The color of the track's inactive segments, i.e. the span of tracks
  /// between the min and the start thumb, and the end thumb and the max.
  ///
  /// If null, [SliderThemeData.inactiveTrackColor] of the ambient [SliderTheme]
  /// then [ColorScheme.secondaryContainer] is used. Otherwise, [ColorScheme.primary]
  /// with an opacity of 0.24 is used.
  ///
  /// Using a [SliderTheme] gives more fine-grained control over the
  /// appearance of various components of the slider.
  final Color? inactiveColor;

  /// The callback used to create a semantic value from the slider's values.
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
  /// RangeSlider(
  ///   values: _dollarsRange,
  ///   min: 20.0,
  ///   max: 330.0,
  ///   onChanged: (RangeValues newValues) {
  ///     setState(() {
  ///       _dollarsRange = newValues;
  ///     });
  ///   },
  ///   semanticFormatterCallback: (double newValue) {
  ///     return '${newValue.round()} dollars';
  ///   }
  ///  )
  /// ```
  /// {@end-tool}
  final SemanticFormatterCallback? semanticFormatterCallback;

  /// Determines the padding around the [RangeSlider].
  ///
  /// If specified, this padding overrides the vertical padding and the
  /// horizontal padding of the [RangeSlider]. By default, the vertical padding
  /// is the height of the overlay shape, and the horizontal padding is the
  /// larger size between the width of the thumb shape and overlay shape.
  final EdgeInsetsGeometry? padding;

  const JustRangeSlider({
    super.key,
    required this.name,
    this.initialValue,
    this.keepValueOnDestroy = true,
    this.initialAttributes = const {},
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    this.activeColor,
    this.inactiveColor,
    this.semanticFormatterCallback,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return JustField<RangeValues>(
      name: name,
      initialValue: initialValue,
      rebuildOnValueChangedInternally: true,
      keepValueOnDestroy: keepValueOnDestroy,
      initialAttributes: initialAttributes,
      onChanged: onChanged == null
          ? null
          : (value, isInternalUpdate) {
              onChanged?.call(value ?? RangeValues(min, max));
            },
      builder: (context, state) {
        return RangeSlider(
          values: state.getValue() ?? RangeValues(min, max),
          onChanged: (value) {
            state.setValue(value);
          },
          onChangeStart: state.getAttribute('onChangeStart') ?? onChangeStart,
          onChangeEnd: state.getAttribute('onChangeEnd') ?? onChangeEnd,
          min: state.getAttribute('min') ?? min,
          max: state.getAttribute('max') ?? max,
          divisions: state.getAttribute('divisions') ?? divisions,
          labels: state.getAttribute('labels') ?? labels,
          activeColor: state.getAttribute('activeColor') ?? activeColor,
          inactiveColor: state.getAttribute('inactiveColor') ?? inactiveColor,
          semanticFormatterCallback:
              state.getAttribute('semanticFormatterCallback') ??
              semanticFormatterCallback,
          padding: state.getAttribute('padding') ?? padding,
        );
      },
    );
  }
}
