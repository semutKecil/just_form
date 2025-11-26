import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final JustBuilderFields fields;
  final bool notifyError;
  final bool notifyValueUpdate;
  final bool notifyAttributeUpdate;
  final Widget Function(BuildContext context, JustFormController state) builder;

  const JustBuilder({
    super.key,
    required this.fields,
    this.notifyValueUpdate = false,
    this.notifyError = false,
    this.notifyAttributeUpdate = false,
    required this.builder,
  });

  bool _buildFieldWhen(JustFieldState previous, JustFieldState current) {
    for (var mode in current.mode) {
      switch (mode) {
        case JustFieldStateMode.update:
        case JustFieldStateMode.updateInternal:
          if (notifyValueUpdate && !current.valueEqualWith(previous.value)) {
            return true;
          }
          break;
        case JustFieldStateMode.error:
          if (notifyError && current.error != previous.error) {
            return true;
          }
          break;
        case JustFieldStateMode.attribute:
          if (notifyAttributeUpdate) {
            return true;
          }
        case JustFieldStateMode.none:
        case JustFieldStateMode.initialization:
        case JustFieldStateMode.validateExternal:
          break;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JustFormController, Map<String, JustRegisteredField>>(
      buildWhen: (previous, current) {
        if (current.isEmpty) return false;
        if (fields.all) return true;
        var bld =
            current.entries
                .where((e) => e.value.controller != null)
                .map((e) => fields.fields.contains(e.key))
                .contains(true) !=
            previous.entries
                .where((e) => e.value.controller != null)
                .map((e) => fields.fields.contains(e.key))
                .contains(true);
        return bld;
      },
      builder: (context, state) {
        if (!fields.all &&
            !(state.entries
                .where((e) => e.value.controller != null)
                .map((e) => fields.fields.contains(e.key))
                .contains(true))) {
          return SizedBox.shrink();
        }
        var fieldsMonitor = fields.all
            ? state.entries
                  .where((element) => element.value.controller != null)
                  .map((e) => e.key)
                  .toList()
            : state.entries
                  .where(
                    (element) =>
                        element.value.controller != null &&
                        fields.fields.contains(element.key),
                  )
                  .map((e) => e.key)
                  .toList();

        if (fieldsMonitor.isEmpty) return const SizedBox.shrink();
        // state.values.first.co
        Widget blocWidget(
          JustFieldController fieldController,
          WidgetBuilder builder,
        ) {
          return BlocBuilder<JustFieldController, JustFieldState>(
            bloc: fieldController,
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
            content = blocWidget(state[field]!.controller!, (context) {
              return builder(context, context.justForm);
            });
          } else {
            content = blocWidget(state[field]!.controller!, (context) {
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
