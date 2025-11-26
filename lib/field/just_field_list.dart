import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_form/just_form_builder.dart';

class JustFieldList extends StatefulWidget {
  final String name;
  final Widget Function(BuildContext context, Map<String, dynamic> item)
  itemBuilder;
  const JustFieldList({
    super.key,
    required this.name,
    required this.itemBuilder,
  });

  @override
  State<JustFieldList> createState() => _JustFieldListState();
}

class _JustFieldListState extends State<JustFieldList> {
  final List<JustFormController> _listForm = [];
  @override
  Widget build(BuildContext context) {
    return JustField<List<Map<String, dynamic>>>(
      name: widget.name,
      notifyInternalUpdate: false,
      notifyError: false,
      validators: [
        (value) {
          if (context.justForm
                  .field(widget.name)
                  ?.state
                  .mode
                  .contains(JustFieldStateMode.validateExternal) ==
              true) {
            for (var element in _listForm) {
              element.validate();
            }

            var errors = _listForm
                .map((e) => e.errors)
                .where((e) => e.isNotEmpty)
                .toList();
            if (errors.isNotEmpty) {
              return jsonEncode(errors);
            }
          }
          return null;
        },
      ],
      builder: (context, state) {
        var values = state.value ?? [];
        return ListView.builder(
          itemBuilder: (context, index) {
            if (_listForm.length > index) {
              _listForm[index].close();
              _listForm[index] = JustFormController(
                initialValues: values[index],
              );
            } else {
              _listForm.add(JustFormController(initialValues: values[index]));
            }

            return JustFormBuilder(
              key: ValueKey("${widget.name}_$index"),
              controller: _listForm[index],
              onValuesChanged: (value) {
                var newValues = List<Map<String, dynamic>>.from(values)
                  ..[index] = value;
                state.setValue(newValues);
              },
              builder: (context) {
                return widget.itemBuilder(context, values[index]);
              },
            );
          },
          itemCount: values.length,
        );
      },
    );
  }
}
