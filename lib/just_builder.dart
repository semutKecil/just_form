import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/just_field_state.dart';
import 'package:just_form/just_form_builder.dart';

/// A configuration class for specifying which form fields to monitor in a [JustBuilder].
///
/// Provides factory constructors for common patterns:
/// - Monitor all fields in the form
/// - Monitor multiple specific fields
/// - Monitor a single field
///
/// This class is used as a parameter to control selective field rebuilding,
/// allowing widgets to update only when relevant fields change.
///
/// ## Usage
///
/// ```dart
/// // Monitor all fields
/// JustBuilderFields.all()
///
/// // Monitor specific fields
/// JustBuilderFields.multiple(['email', 'password'])
/// JustBuilderFields.one('email')
/// ```
class JustBuilderFields {
  /// Whether to monitor all fields in the form.
  final bool all;

  /// The specific field names to monitor.
  ///
  /// Empty if [all] is true.
  final List<String> fields;

  /// Internal constructor for [JustBuilderFields].
  ///
  /// Use factory constructors instead: [all], [multiple], [one].
  JustBuilderFields._({this.all = false, this.fields = const []});

  /// Creates a configuration to monitor all form fields.
  ///
  /// The builder will rebuild whenever any field in the form changes
  /// (respecting the rebuild flags set on [JustBuilder]).
  factory JustBuilderFields.all() => JustBuilderFields._(all: true);

  /// Creates a configuration to monitor multiple specific fields.
  ///
  /// The builder will rebuild only when the specified fields change.
  ///
  /// Parameters:
  /// - [fields] - List of field names to monitor
  factory JustBuilderFields.multiple(List<String> fields) =>
      JustBuilderFields._(fields: fields);

  /// Creates a configuration to monitor a single field.
  ///
  /// The builder will rebuild only when the specified field changes.
  ///
  /// Parameters:
  /// - [field] - The field name to monitor
  factory JustBuilderFields.one(String field) =>
      JustBuilderFields._(fields: [field]);
}

/// A stateless widget that selectively rebuilds based on changes to specific form fields.
///
/// [JustBuilder] listens to changes in the form and rebuilds only when:
/// - One of the monitored fields changes (if using selective monitoring)
/// - The monitored state aspects change (value, error, or attributes)
/// - The rebuild conditions are met (controlled by rebuild flags)
///
/// This is useful for:
/// - Building UI that reacts to specific field changes
/// - Creating dependent field updates (e.g., amount field that updates total)
/// - Displaying field errors or validation states
/// - Optimizing performance by limiting rebuilds to relevant fields
///
/// ## Difference from [JustField]
///
/// - [JustField] - Individual form field with builder
/// - [JustBuilder] - Monitors multiple fields and rebuilds a single widget
///
/// ## Usage
///
/// Monitor specific fields:
/// ```dart
/// JustBuilder(
///   fields: ['email', 'password'],
///   rebuildOnValueChanged: true,
///   rebuildOnErrorChanged: true,
///   builder: (context, state) {
///     final email = state['email'];
///     final password = state['password'];
///     return Column(
///       children: [
///         if (email?.error != null)
///           Text('Email error: ${email?.error}'),
///         if (password?.error != null)
///           Text('Password error: ${password?.error}'),
///       ],
///     );
///   },
/// )
/// ```
///
/// Monitor all fields:
/// ```dart
/// JustBuilder(
///   allFields: true,
///   builder: (context, state) {
///     final isFormValid = state.values.every((f) => f.error == null);
///     return Text('Form valid: $isFormValid');
///   },
/// )
/// ```
class JustBuilder extends StatelessWidget {
  /// List of specific field names to monitor.
  ///
  /// The builder will rebuild only when these fields change.
  /// Ignored if [allFields] is true.
  ///
  /// If both [fields] and [allFields] are empty/false, no rebuilds occur.
  final List<String> fields;

  /// Whether to monitor all fields in the form.
  ///
  /// If true, the builder rebuilds whenever any field changes,
  /// ignoring the [fields] list.
  ///
  /// Default is false.
  final bool allFields;

  /// The builder function that constructs the widget.
  ///
  /// Called with:
  /// - [BuildContext] - The widget's build context
  /// - [Map<String, JustFieldController>] - Map of all field controllers,
  ///   keyed by field name. Only includes the monitored fields.
  ///
  /// The builder is called whenever monitored fields change and rebuild
  /// conditions are met.
  ///
  /// Example:
  /// ```dart
  /// builder: (context, state) {
  ///   return Column(
  ///     children: state.entries.map((e) {
  ///       return Text('${e.key}: ${e.value.value}');
  ///     }).toList(),
  ///   );
  /// }
  /// ```
  final Widget Function(
    BuildContext context,
    Map<String, JustFieldController> state,
  )
  builder;

  /// Whether to rebuild when monitored field values change.
  ///
  /// If true (default):
  /// - The builder rebuilds when any monitored field's value changes
  /// - Useful for displaying field values
  ///
  /// If false:
  /// - Value changes don't trigger rebuilds
  /// - The builder can still access values via the controller map
  final bool rebuildOnValueChanged;

  /// Whether to rebuild when monitored field attributes change.
  ///
  /// If true:
  /// - The builder rebuilds when any monitored field's attributes change
  /// - Attributes are custom metadata stored on fields
  ///
  /// If false (default):
  /// - Attribute changes don't trigger rebuilds
  /// - More performant if attributes aren't used in the builder
  final bool rebuildOnAttributeChanged;

  /// Whether to rebuild when monitored field validation errors change.
  ///
  /// If true:
  /// - The builder rebuilds when any monitored field's error changes
  /// - Useful for displaying validation error messages
  ///
  /// If false (default):
  /// - Error changes don't trigger rebuilds
  /// - The builder can still access errors via the controller map
  final bool rebuildOnErrorChanged;

  /// Creates a [JustBuilder] widget.
  ///
  /// Either [fields] or [allFields] should be specified (or both can be empty
  /// to disable automatic rebuilds, though this is rarely useful).
  ///
  /// The [builder] parameter is required.
  ///
  /// Defaults:
  /// - `fields`: empty list (no specific fields)
  /// - `allFields`: false (don't monitor all fields)
  /// - `rebuildOnValueChanged`: true
  /// - `rebuildOnAttributeChanged`: false (optimize performance)
  /// - `rebuildOnErrorChanged`: false
  const JustBuilder({
    super.key,
    this.fields = const [],
    this.allFields = false,
    this.rebuildOnValueChanged = true,
    this.rebuildOnAttributeChanged = false,
    this.rebuildOnErrorChanged = false,
    required this.builder,
  });

  /// Determines if a field state change should trigger a rebuild.
  ///
  /// Evaluates the rebuild conditions by checking:
  /// - [rebuildOnValueChanged] - whether value changed
  /// - [rebuildOnErrorChanged] - whether error changed
  /// - [rebuildOnAttributeChanged] - whether attributes changed
  ///
  /// Returns true if any configured condition is met, false otherwise.
  ///
  /// Used internally by [BlocBuilder] to optimize rebuilds and prevent
  /// unnecessary widget reconstructions.
  ///
  /// Parameters:
  /// - `previous` - The previous field state
  /// - `current` - The current field state
  ///
  /// Returns:
  /// - true if the field changed in a way that should trigger a rebuild
  /// - false if the change should be ignored
  bool _buildFieldWhen(JustFieldState previous, JustFieldState current) {
    if (rebuildOnValueChanged && current.value != previous.value) return true;
    if (rebuildOnErrorChanged && current.error != previous.error) return true;
    if (rebuildOnAttributeChanged &&
        !mapEquals(current.attributes, previous.attributes)) {
      return true;
    }

    return false;
  }

  /// Builds the widget tree with selective field monitoring and rebuilds.
  ///
  /// This method:
  /// 1. Listens to the form controller's field data changes
  /// 2. Filters to only monitored fields (based on [allFields] and [fields])
  /// 3. Returns empty widget if no fields to monitor
  /// 4. Sets up nested [BlocBuilder]s for each monitored field
  /// 5. Calls the builder with the monitored field controllers
  ///
  /// The nesting of [BlocBuilder]s allows fine-grained rebuild control:
  /// - Outer [BlocBuilder] checks if monitored fields were added/removed
  /// - Inner [BlocBuilder]s check if field state changed per [_buildFieldWhen]
  ///
  /// ## Rebuild Logic
  ///
  /// The outer [buildWhen]:
  /// - Returns false if no fields exist in the form
  /// - Returns true if monitoring all fields
  /// - Returns true if the count of monitored fields changed
  /// - Returns false if the count of monitored fields stayed the same
  ///
  /// The inner [buildWhen] uses [_buildFieldWhen] to check value, error,
  /// and attribute changes based on the rebuild flags.
  ///
  /// ## Nesting Strategy
  ///
  /// Fields are monitored in reverse order, with each field's [BlocBuilder]
  /// wrapping the previous field's builder. This creates a chain of listeners
  /// that allows each field change to trigger a rebuild of the final widget
  /// returned by the user's builder function.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JustFormController, Map<String, JustFieldData>>(
      buildWhen: (previous, current) {
        if (current.isEmpty) return false;
        if (allFields) return true;

        return previous.keys
                .where((element) => fields.contains(element))
                .length !=
            current.keys.where((element) => fields.contains(element)).length;
      },
      builder: (context, state) {
        var fieldsMonitor = allFields
            ? state.keys.toList()
            : state.keys.where((element) => fields.contains(element)).toList();

        if (fieldsMonitor.isEmpty) return const SizedBox.shrink();

        /// Helper function that wraps a widget in a [BlocBuilder] for a specific field.
        ///
        /// Creates a [BlocBuilder] that:
        /// - Listens to the given field's [JustFieldData] bloc
        /// - Uses [_buildFieldWhen] to determine rebuild conditions
        /// - Passes the build context to the provided builder function
        ///
        /// Parameters:
        /// - `fieldCubit` - The [JustFieldData] bloc for the field to monitor
        /// - `builder` - The widget builder function to call when rebuilds occur
        ///
        /// Returns:
        /// - A [BlocBuilder] widget that rebuilds based on field state changes
        Widget blocWidget(JustFieldData fieldCubit, WidgetBuilder builder) {
          return BlocBuilder<JustFieldData, JustFieldState>(
            bloc: fieldCubit,
            buildWhen: (previous, current) =>
                _buildFieldWhen(previous, current),
            builder: (context, state) {
              return builder.call(context);
            },
          );
        }

        Widget? content;
        var i = 0;

        /// Build nested [BlocBuilder]s for each monitored field in reverse order.
        ///
        /// This creates a chain where:
        /// - The outermost field's builder wraps the innermost
        /// - Each field change can trigger a rebuild through the entire chain
        /// - All monitored fields contribute to the rebuild decision
        ///
        /// Example with fields ['a', 'b', 'c']:
        /// ```
        /// blocWidget(c, (context) {
        ///   return blocWidget(b, (context) {
        ///     return blocWidget(a, (context) {
        ///       return builder(context, context.justForm.fields());
        ///     });
        ///   });
        /// });
        /// ```
        ///
        /// The reverse order ensures the first field called is the innermost
        /// and the last field called is the outermost wrapper.
        for (var field in fieldsMonitor.reversed) {
          if (i == 0) {
            content = blocWidget(state[field]!, (context) {
              return builder(context, context.justForm.fields());
            });
          } else {
            content = blocWidget(state[field]!, (context) {
              return content!;
            });
          }
          i++;
        }
        return content!;
      },
    );
  }
}
