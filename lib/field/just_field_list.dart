import 'package:flutter/material.dart';
import 'package:just_form/just_form_builder.dart';

class JustFieldListState {
  final Map<String, dynamic> value;
  final void Function() delete;
  const JustFieldListState({required this.value, required this.delete});
}

class JustFieldList extends StatefulWidget {
  final String name;
  final List<Map<String, dynamic>>? initialValue;
  final Widget Function(BuildContext context, JustFieldListState state)
  itemBuilder;
  final ScrollController? scrollController;
  const JustFieldList({
    super.key,
    required this.name,
    required this.itemBuilder,
    this.scrollController,
    this.initialValue,
  });

  @override
  State<JustFieldList> createState() => _JustFieldListState();
}

class _JustFieldListState extends State<JustFieldList> {
  late final JustFormController _mainFormController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _mainFormController = context.justForm;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JustField<List<Map<String, dynamic>>>(
      name: widget.name,
      initialValue: widget.initialValue,
      rebuildOnValueChangedInternally: false,
      rebuildOnErrorChanged: false,
      rebuildOnAttributeChanged: false,
      builder: (context, state) {
        return ListView.builder(
          controller: widget.scrollController,
          itemBuilder: (context, index) {
            return JustFormBuilder(
              key: ValueKey(state.getValue()![index]),
              initialValues: state.getValue()![index],
              onValuesChanged: (value) {
                final listValue = state.getValue() ?? [];
                listValue[index] = value;
                state.setValue(List.from(listValue));
              },
              onFieldRegistered: (value) {
                final listValue = state.getValue() ?? [];
                listValue[index] = value;
                state.setValue(List.from(listValue));
              },
              builder: (context) {
                return widget.itemBuilder(
                  context,
                  JustFieldListState(
                    value: state.getValue()![index],
                    delete: () {
                      final todoField = _mainFormController
                          .field<List<Map<String, dynamic>>>(widget.name);
                      todoField?.setValue(
                        List.from((todoField.getValue() ?? []))
                          ..removeAt(index),
                      );
                    },
                  ),
                );
              },
            );
          },
          itemCount: state.getValue()?.length ?? 0,
        );
      },
    );
  }
}
