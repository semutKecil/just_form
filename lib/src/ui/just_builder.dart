import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/src/just_field_state.dart';
import 'package:just_form/src/ui/just_form_builder.dart';

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
class JustBuilder extends StatefulWidget {
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

  @override
  State<JustBuilder> createState() => _JustBuilderState();
}

class _JustBuilderState extends State<JustBuilder> {
  late final AnyCubit<Map<String, JustFieldController<dynamic>>> fieldChange;

  @override
  void initState() {
    super.initState();
    fieldChange = AnyCubit<Map<String, JustFieldController<dynamic>>>(
      context.justForm.fields(),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fieldChange.update(Map.from(context.justForm.fields()));
    });
  }

  @override
  void dispose() {
    fieldChange.close();
    super.dispose();
  }

  bool _buildFieldWhen(JustFieldState previous, JustFieldState current) {
    if (widget.rebuildOnValueChanged && current.value != previous.value) {
      return true;
    }
    if (widget.rebuildOnErrorChanged && current.error != previous.error) {
      return true;
    }
    if (widget.rebuildOnAttributeChanged &&
        !mapEquals(current.attributes, previous.attributes)) {
      return true;
    }

    return false;
  }

  /// Builds the widget tree with selective field monitoring and rebuilds.
  ///
  /// This method:
  /// 1. Listens to the form controller's field data changes
  /// 2. Filters to only monitored fields (based on [widget.allFields] and [widget.fields])
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
        if (widget.allFields) return true;

        return previous.keys
                .where((element) => widget.fields.contains(element))
                .length !=
            current.keys
                .where((element) => widget.fields.contains(element))
                .length;
      },
      builder: (context, state) {
        var fieldsMonitor = widget.allFields
            ? state.values.toList()
            : state.keys
                  .where((element) => widget.fields.contains(element))
                  .map((e) => state[e])
                  .whereType<JustFieldData<dynamic>>()
                  .toList();

        if (fieldsMonitor.isEmpty) return const SizedBox.shrink();
        return MultiBlocListener(
          listeners: List.generate(fieldsMonitor.length, (index) {
            return BlocListener<
              JustFieldData<dynamic>,
              JustFieldState<dynamic>
            >(
              bloc: fieldsMonitor[index],
              listenWhen: (previous, current) {
                return _buildFieldWhen(previous, current);
              },
              listener: (context, state) {
                fieldChange.update(Map.from(context.justForm.fields()));
              },
            );
          }),
          child:
              BlocBuilder<
                AnyCubit<Map<String, JustFieldController<dynamic>>>,
                Map<String, JustFieldController<dynamic>>
              >(
                bloc: fieldChange,
                builder: (context, state) {
                  return widget.builder(context, state);
                },
              ),
        );
      },
    );
  }
}

class AnyCubit<T> extends Cubit<T> {
  AnyCubit(super.initialState);
  void update(T value) => emit(value);
}
