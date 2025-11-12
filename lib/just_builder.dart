import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/just_form.dart';

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
        return builder(context, context.read<JustFormController>());
      },
    );
  }
}

class JustFieldStateController {}
