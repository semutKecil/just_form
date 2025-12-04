import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/just_field_state.dart';
import 'package:just_form/just_form_builder.dart';

class JustBuilderFields {
  final bool all;
  final List<String> fields;
  JustBuilderFields._({this.all = false, this.fields = const []});
  factory JustBuilderFields.all() => JustBuilderFields._(all: true);
  factory JustBuilderFields.multiple(List<String> fields) =>
      JustBuilderFields._(fields: fields);
  factory JustBuilderFields.one(String field) =>
      JustBuilderFields._(fields: [field]);
}

class JustBuilder extends StatelessWidget {
  final List<String> fields;
  final bool allFields;
  final Widget Function(
    BuildContext context,
    Map<String, JustFieldController> state,
  )
  builder;
  final bool rebuildOnValueChanged;
  final bool rebuildOnAttributeChanged;
  final bool rebuildOnErrorChanged;

  const JustBuilder({
    super.key,
    this.fields = const [],
    this.allFields = false,
    this.rebuildOnValueChanged = true,
    this.rebuildOnAttributeChanged = false,
    this.rebuildOnErrorChanged = false,
    required this.builder,
  });

  bool _buildFieldWhen(JustFieldState previous, JustFieldState current) {
    if (rebuildOnValueChanged && current.value != previous.value) return true;
    if (rebuildOnErrorChanged && current.error != previous.error) return true;
    if (rebuildOnAttributeChanged &&
        !mapEquals(current.attributes, previous.attributes)) {
      return true;
    }

    return false;
  }

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
