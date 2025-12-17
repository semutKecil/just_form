import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_form/src/ui/field/just_picker_field.dart';
import 'package:just_form/src/ui/just_form_builder.dart';

class JustDateField extends StatefulWidget
    implements JustFieldValidatorAbstract<DateTime> {
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
  final DateTime? initialValue;

  /// A list of validators to check the value of the field against.
  ///
  /// These validators will be run whenever the value of the field changes.
  ///
  /// The validators will be passed the current value of the field and the
  /// entire form values.
  ///
  /// If any of the validators return an error string, the field will be
  /// marked as invalid.
  @override
  final List<FormFieldValidator<DateTime>> validators;

  @override
  final ValueChanged<DateTime?>? onChanged;

  @override
  final bool keepValueOnDestroy;

  @override
  final Map<String, dynamic> initialAttributes;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration decoration;

  final DateTime firstDate;
  final DateTime lastDate;

  final DateFormat? dateFormat;
  final String? dateFormatText;
  final JustDateFieldCalendarConfig calendarConfig;
  final String invalidDateErrorText;
  final bool freeText;
  final Widget calendarIcon;
  final Future<DateTime?> Function(
    BuildContext context,
    DateTime? currentValue,
  )?
  pickerBuilder;

  final Widget? clearIcon;
  final bool? withClearButton;
  final bool enabled;

  const JustDateField({
    super.key,
    required this.name,
    required this.firstDate,
    required this.lastDate,
    this.initialValue,
    this.validators = const [],
    this.keepValueOnDestroy = true,
    this.initialAttributes = const {},
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.dateFormat,
    this.dateFormatText,
    this.freeText = true,
    this.calendarConfig = const JustDateFieldCalendarConfig(),
    this.invalidDateErrorText = "Invalid date",
    this.calendarIcon = const Icon(Icons.calendar_month),
    this.pickerBuilder,
    this.enabled = true,
    this.clearIcon,
    this.withClearButton,
  });

  @override
  State<JustDateField> createState() => _JustDateFieldState();
}

class _JustDateFieldState extends State<JustDateField> {
  late DateFormat formatter;

  @override
  void initState() {
    super.initState();
    formatter =
        widget.dateFormat ??
        ((widget.dateFormatText != null)
            ? DateFormat(widget.dateFormatText!)
            : DateFormat.yMd());
  }

  @override
  Widget build(BuildContext context) {
    return JustPickerField<DateTime>(
      name: widget.name,
      parseValue: (valueText) => formatter.tryParseStrict(valueText),
      renderValue: (value) {
        return value?.toFormatString(formatter);
      },
      pickerBuilder: (context, state) async {
        return widget.pickerBuilder != null
            ? widget.pickerBuilder!.call(context, state.getValue())
            : showDatePicker(
                context: context,
                firstDate: state.getAttribute('firstDate') ?? widget.firstDate,
                lastDate: state.getAttribute('lastDate') ?? widget.lastDate,
                initialDate:
                    state.getValue()?.isInRange(
                          DateTimeRange(
                            start: widget.firstDate,
                            end: widget.lastDate,
                          ),
                        ) ==
                        true
                    ? state.getValue()
                    : null,
                currentDate: widget.calendarConfig.currentDate,
                initialEntryMode: widget.calendarConfig.initialEntryMode,
                selectableDayPredicate:
                    widget.calendarConfig.selectableDayPredicate,
                helpText: widget.calendarConfig.helpText,
                cancelText: widget.calendarConfig.cancelText,
                confirmText: widget.calendarConfig.confirmText,
                locale: widget.calendarConfig.locale,
                barrierDismissible: widget.calendarConfig.barrierDismissible,
                barrierColor: widget.calendarConfig.barrierColor,
                barrierLabel: widget.calendarConfig.barrierLabel,
                useRootNavigator: widget.calendarConfig.useRootNavigator,
                routeSettings: widget.calendarConfig.routeSettings,
                textDirection: widget.calendarConfig.textDirection,
                builder: widget.calendarConfig.builder,
                initialDatePickerMode:
                    widget.calendarConfig.initialDatePickerMode,
                errorFormatText: widget.calendarConfig.errorFormatText,
                errorInvalidText: widget.calendarConfig.errorInvalidText,
                fieldHintText: widget.calendarConfig.fieldHintText,
                fieldLabelText: widget.calendarConfig.fieldLabelText,
                keyboardType: widget.calendarConfig.keyboardType,
                anchorPoint: widget.calendarConfig.anchorPoint,
                onDatePickerModeChange:
                    widget.calendarConfig.onDatePickerModeChange,
                switchToInputEntryModeIcon:
                    widget.calendarConfig.switchToInputEntryModeIcon,
                switchToCalendarEntryModeIcon:
                    widget.calendarConfig.switchToCalendarEntryModeIcon,
                calendarDelegate: widget.calendarConfig.calendarDelegate,
              );
      },
      pickerIcon: widget.calendarIcon,
      decoration: widget.decoration,
      freeText: widget.freeText,
      initialAttributes: widget.initialAttributes,
      initialValue: widget.initialValue,
      keepValueOnDestroy: widget.keepValueOnDestroy,
      validators: widget.validators,
      onChanged: widget.onChanged,
      invalidErrorText: widget.invalidDateErrorText,
      enabled: widget.enabled,
      withClearButton: widget.withClearButton,
      clearIcon: widget.clearIcon,
    );
  }
}

class JustDateFieldCalendarConfig {
  final DateTime? currentDate;
  final DatePickerEntryMode initialEntryMode;
  final SelectableDayPredicate? selectableDayPredicate;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;
  final Locale? locale;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool useRootNavigator;
  final RouteSettings? routeSettings;
  final ui.TextDirection? textDirection;
  final TransitionBuilder? builder;
  final DatePickerMode initialDatePickerMode;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldHintText;
  final String? fieldLabelText;
  final TextInputType? keyboardType;
  final Offset? anchorPoint;
  final ValueChanged<DatePickerEntryMode>? onDatePickerModeChange;
  final Icon? switchToInputEntryModeIcon;
  final Icon? switchToCalendarEntryModeIcon;
  final CalendarDelegate<DateTime> calendarDelegate;
  const JustDateFieldCalendarConfig({
    this.currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.locale,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.useRootNavigator = true,
    this.routeSettings,
    this.textDirection,
    this.builder,
    this.initialDatePickerMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.anchorPoint,
    this.onDatePickerModeChange,
    this.switchToInputEntryModeIcon,
    this.switchToCalendarEntryModeIcon,
    this.calendarDelegate = const GregorianCalendarDelegate(),
  });
}

extension DateTimeExtensions on DateTime {
  /// Format DateTime using the current device/app locale
  String toFormatString(DateFormat formatter) {
    return formatter.format(this);
  }

  DateTime toDate() =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  bool isInRange(DateTimeRange range) {
    var nd = toDate();
    return nd.isAfter(range.start.subtract(Duration(days: 1))) &&
        nd.isBefore(range.end.add(Duration(days: 1)));
  }
}
