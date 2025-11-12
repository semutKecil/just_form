import 'package:flutter/material.dart';
import 'package:just_form/just_form.dart';
import 'package:just_form/just_validator.dart';

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
  final List<JustValidator<T>> validators;

  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  const JustRadioGroup({
    super.key,
    required this.name,
    required this.child,
    this.initialValue,
    this.validators = const [],
  });

  @override
  Widget build(BuildContext context) {
    return JustField<T>(
      name: name,
      validators: validators,
      initialValue: initialValue,
      notifyInternalUpdate: true,
      builder: (context, state) {
        return RadioGroup(
          onChanged: (value) {
            state.value = value;
          },
          groupValue: state.value,
          child: child,
        );
      },
    );
  }
}
