import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/just_form_builder.dart';

/// Specifies which form fields should trigger rebuilds of a [JustBuilder] widget.
///
/// [JustBuilderFields] allows selective field monitoring, so widgets can choose to
/// rebuild only when specific fields change, rather than on any form state change.
/// This enables fine-grained control over which field changes cause expensive rebuilds.
///
/// Use one of the factory constructors:
/// - [JustBuilderFields.all()] - rebuild on any field change
/// - [JustBuilderFields.one(String)] - rebuild only for a single field
/// - [JustBuilderFields.multiple(List<String>)] - rebuild for multiple specific fields
class JustBuilderFields {
  /// Whether to monitor all fields in the form.
  ///
  /// If true, the [fields] list is ignored and all field changes are monitored.
  final bool all;

  /// The list of specific field names to monitor.
  ///
  /// Only used if [all] is false. Empty if using [all()].
  final List<String> fields;

  /// Private constructor for creating instances.
  JustBuilderFields._({this.all = false, this.fields = const []});

  /// Creates a fields specification that monitors all form fields.
  ///
  /// The builder will rebuild whenever any field in the form changes.
  factory JustBuilderFields.all() => JustBuilderFields._(all: true);

  /// Creates a fields specification that monitors multiple specific fields.
  ///
  /// The builder will rebuild only when one of the specified fields changes.
  ///
  /// Example: `JustBuilderFields.multiple(['email', 'password'])`
  factory JustBuilderFields.multiple(List<String> fields) =>
      JustBuilderFields._(fields: fields);

  /// Creates a fields specification that monitors a single field.
  ///
  /// The builder will rebuild only when the specified field changes.
  ///
  /// Example: `JustBuilderFields.one('email')`
  factory JustBuilderFields.one(String field) =>
      JustBuilderFields._(fields: [field]);
}

/// A selective form state listener that rebuilds based on specific field changes.
///
/// [JustBuilder] is similar to [BlocBuilder] but provides more control over which
/// field state changes trigger rebuilds. Instead of rebuilding on all form state changes,
/// you can specify exactly which fields should trigger rebuilds via [JustBuilderFields].
///
/// You can also control which types of changes trigger rebuilds:
/// - [notifyValueUpdate]: Rebuild when field values change (default: false)
/// - [notifyError]: Rebuild when validation errors change (default: false)
/// - [notifyAttributeUpdate]: Rebuild when field attributes change (default: false)
///
/// This is useful for building optimized UI components that only need to react to
/// changes in specific fields, avoiding unnecessary rebuilds.
///
/// Example - rebuild only when email field value changes:
/// ```dart
/// JustBuilder(
///   fields: JustBuilderFields.one('email'),
///   notifyValueUpdate: true,
///   builder: (context, controller) {
///     final emailField = controller.field<String>('email');
///     return Text('Email: ${emailField?.value}');
///   },
/// )
/// ```
class JustBuilder extends StatelessWidget {
  /// Specification of which fields should trigger rebuilds.
  ///
  /// Determines whether to monitor all fields or only specific field names.
  final JustBuilderFields fields;

  /// Whether to rebuild when field validation errors change.
  ///
  /// Defaults to false. Set to true to rebuild when a field's error message changes.
  final bool notifyError;

  /// Whether to rebuild when field values change.
  ///
  /// Defaults to false. Set to true to rebuild when a monitored field's value changes.
  final bool notifyValueUpdate;

  /// Whether to rebuild when field attributes change.
  ///
  /// Defaults to false. Set to true to rebuild when custom field attributes are updated.
  final bool notifyAttributeUpdate;

  /// A builder function that constructs the widget tree.
  ///
  /// The builder receives the current [BuildContext] and the [JustFormController]
  /// for accessing form and field state. This function is called whenever a monitored
  /// field changes according to the notification settings.
  final Widget Function(BuildContext context, JustFormController state) builder;

  /// Creates a [JustBuilder] widget.
  ///
  /// The [fields] and [builder] parameters are required. All notification flags
  /// default to false, meaning the widget won't rebuild unless you explicitly
  /// enable the notifications you're interested in.
  const JustBuilder({
    super.key,
    required this.fields,
    this.notifyValueUpdate = false,
    this.notifyError = false,
    this.notifyAttributeUpdate = false,
    required this.builder,
  });

  /// Internal helper method that determines if a specific field change should trigger a rebuild.
  ///
  /// This method compares a field's previous and current state to determine if any monitored
  /// changes occurred. It checks:
  /// - Value changes (if [notifyValueUpdate] is true)
  /// - Error changes (if [notifyError] is true)
  /// - Attribute changes (if [notifyAttributeUpdate] is true)
  ///
  /// Returns true if a change matching the notification settings was detected.
  bool _fieldBuildWhen(
    String name,
    List<JustFieldState> previous,
    List<JustFieldState> current,
  ) {
    var previousField = previous
        .where((element) => element.name == name)
        .firstOrNull;

    var currentField = current
        .where((element) => element.name == name)
        .firstOrNull;

    if (currentField == null) return false;
    // var update = false;
    for (var mode in currentField.mode) {
      switch (mode) {
        case JustFieldStateMode.update:
        case JustFieldStateMode.updateInternal:
          if (notifyValueUpdate &&
              !currentField.valueEqualWith(previousField?.value)) {
            return true;
          }
          break;
        case JustFieldStateMode.error:
          if (notifyError && previousField?.error != currentField.error) {
            return true;
          }
          break;
        case JustFieldStateMode.attribute:
          if (notifyAttributeUpdate) {
            return true;
          }
        case JustFieldStateMode.none:
          break;
      }
    }
    return false;
  }

  /// Builds the widget tree with selective field monitoring.
  ///
  /// This method uses a [BlocBuilder] to efficiently rebuild only when changes
  /// to monitored fields occur. The [buildWhen] logic:
  /// 1. Determines which fields to monitor (all or specific fields)
  /// 2. Checks each monitored field for relevant changes using [_fieldBuildWhen]
  /// 3. Triggers a rebuild only if a monitored field changed in a relevant way
  ///
  /// This selective rebuilding is crucial for performance in large forms where
  /// you don't want the entire UI to rebuild when unrelated fields change.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JustFormController, Map<String, JustFieldState>>(
      buildWhen: (previous, current) {
        var fieldsMonitor = fields.all
            ? current.values.map((e) => e.name).toList()
            : fields.fields;

        for (var f in fieldsMonitor) {
          if (_fieldBuildWhen(
            f,
            previous.values.toList(),
            current.values.toList(),
          )) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        return builder(context, context.justForm);
      },
    );
  }
}

/// A placeholder class reserved for future field state management functionality.
///
/// This class is currently empty but is defined for forward compatibility.
/// Future versions may add methods here to manage individual field controller state.
class JustFieldStateController {}
