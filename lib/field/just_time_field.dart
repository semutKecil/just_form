import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_form/field/just_picker_field.dart';
import 'package:just_form/just_form_builder.dart';

class JustTimeField extends StatefulWidget {
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
  final TimeOfDay? initialValue;

  /// A list of validators to check the value of the field against.
  ///
  /// These validators will be run whenever the value of the field changes.
  ///
  /// The validators will be passed the current value of the field and the
  /// entire form values.
  ///
  /// If any of the validators return an error string, the field will be
  /// marked as invalid.
  final List<FormFieldValidator<TimeOfDay>> validators;

  final ValueChanged<TimeOfDay?>? onChanged;

  final Map<String, dynamic> initialAttributes;
  final bool keepValueOnDestroy;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration decoration;

  final String? timeFormatText;
  final DateFormat? timeFormat;
  final Future<TimeOfDay?> Function(
    BuildContext context,
    TimeOfDay? currentValue,
  )?
  pickerBuilder;

  final bool freeText;
  final String invalidTimeErrorText;
  final Widget clockIcon;
  final Widget? clearIcon;
  final bool? withClearButton;
  final bool enabled;

  const JustTimeField({
    super.key,
    required this.name,
    this.initialValue,
    this.keepValueOnDestroy = true,
    this.initialAttributes = const {},
    this.validators = const [],
    this.onChanged,
    this.timeFormat,
    this.enabled = true,
    this.timeFormatText,
    this.decoration = const InputDecoration(),
    this.pickerBuilder,
    this.freeText = true,
    this.clearIcon,
    this.withClearButton,
    this.invalidTimeErrorText = "Invalid time",
    this.clockIcon = const Icon(Icons.access_time),
  });

  @override
  State<JustTimeField> createState() => _JustTimeFieldState();
}

class _JustTimeFieldState extends State<JustTimeField> {
  late DateFormat formatter;

  @override
  void initState() {
    super.initState();
    formatter =
        widget.timeFormat ??
        ((widget.timeFormatText != null)
            ? DateFormat(widget.timeFormatText!)
            : DateFormat.Hm());
  }

  @override
  Widget build(BuildContext context) {
    return JustPickerField<TimeOfDay>(
      name: widget.name,
      parseValue: (valueText) {
        final date = formatter.tryParseStrict(valueText);
        if (date == null) return null;
        return TimeOfDay(hour: date.hour, minute: date.minute);
      },
      renderValue: (value) {
        return value?.toFormatString(formatter);
      },
      pickerBuilder: (context, state) async {
        return widget.pickerBuilder != null
            ? widget.pickerBuilder!.call(context, state.getValue())
            : showTimePicker(
                context: context,
                initialTime: state.getValue() ?? TimeOfDay.now(),
              );
      },
      pickerIcon: widget.clockIcon,
      decoration: widget.decoration,
      freeText: widget.freeText,
      enabled: widget.enabled,
      withClearButton: widget.withClearButton,
      clearIcon: widget.clearIcon,
      initialAttributes: widget.initialAttributes,
      initialValue: widget.initialValue,
      keepValueOnDestroy: widget.keepValueOnDestroy,
      validators: widget.validators,
      onChanged: widget.onChanged,
      invalidErrorText: widget.invalidTimeErrorText,
    );
  }
}

extension TimeOfDayExtensions on TimeOfDay {
  String toFormatString(DateFormat formatter) {
    DateTime date = DateTime(2022, 1, 1, hour, minute);
    return formatter.format(date);
  }
}
