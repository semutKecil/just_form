import 'package:flutter/material.dart';
import 'package:just_form/just_form_builder.dart';

/// This class `JustRadioGroup<T>` is a Flutter widget that represents a radio button group in a form. It extends `StatelessWidget` and is used to create a form field with a group of radio buttons. Here's what each method does:
///
/// - `name`: This is the name of the field in the form. It's used to identify the field in the `JustFormController` and is required for validation.
/// - `initialValue`: This is the initial value of the field. If the initial value is already set in the `JustFormController` or `JustForm`, this value is ignored.
/// - `validators`: This is a list of validators to check the value of the field against. These validators will be run whenever the value of the field changes.
/// - `onChanged`: This is a callback that is called when selection has changed. The value can be null when unselecting a `RawRadio` with `toggleable` set to true.
/// - `child`: This is the widget that contains the radio buttons.
/// - `build`: This method builds the widget and returns a `JustField<T>` with a `RadioGroup` as its builder. The `RadioGroup` widget is configured with the parameters passed to the `JustRadioGroup` constructor and the values from the `JustField` state.
class JustRadioGroup<T> extends StatelessWidget {
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
  final T? initialValue;

  /// A list of validators to check the value of the field against.
  ///
  /// These validators will be run whenever the value of the field changes.
  ///
  /// The validators will be passed the current value of the field and the
  /// entire form values.
  ///
  /// If any of the validators return an error string, the field will be
  /// marked as invalid.
  final List<FormFieldValidator<T>> validators;

  /// Called when selection has changed.
  ///
  /// The value can be null when unselect the [RawRadio] with
  /// [RawRadio.toggleable] set to true.
  final ValueChanged<T?>? onChanged;

  final bool saveValueOnDestroy;

  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  const JustRadioGroup({
    super.key,
    required this.name,
    required this.child,
    this.saveValueOnDestroy = true,
    this.initialValue,
    this.validators = const [],
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return JustField<T>(
      name: name,
      validators: validators,
      initialValue: initialValue,
      notifyInternalUpdate: true,
      saveValueOnDestroy: saveValueOnDestroy,
      onChanged: onChanged == null
          ? null
          : (value, isInternalUpdate) {
              onChanged?.call(value);
            },
      builder: (context, state) {
        return RadioGroup(
          onChanged: (value) {
            state.setValue(value);
          },
          groupValue: state.value,
          child: child,
        );
      },
    );
  }
}
