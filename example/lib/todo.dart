import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_form/just_form.dart';
import 'package:validatorless/validatorless.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void submitTodo(BuildContext formContext) {
    formContext.justForm.validate();
    if (!formContext.justForm.isValid()) return;
    final task = formContext.justForm.field<String>("task")?.getValue();
    if (task == null) return;
    final todoField = formContext.justForm.field<List<Map<String, dynamic>>>(
      "todo-list",
    );
    final todoList = todoField?.getValue() ?? [];
    todoList.add({"todo": task});
    todoField?.setValue(List.from(todoList));
    formContext.justForm.field("task")?.setValue("");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: JustFormBuilder(
        builder: (context) {
          return Column(
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: JustTextField(
                      name: "task",
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Todo",
                        hintText: "Enter your todo",
                      ),
                      validators: [Validatorless.required("Field is required")],
                      onFieldSubmitted: (value) {
                        submitTodo(context);
                        _focusNode.requestFocus();
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      submitTodo(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      fixedSize: Size(100, 48),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Add"),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: JustFieldList(
                  name: "todo-list",
                  itemBuilder: (context, state) {
                    return ListTile(
                      title: JustField<String>(
                        name: "todo",
                        initialAttributes: {
                          "done":
                              context.justForm.initialValues?["done"]
                                  as bool? ??
                              false,
                        },
                        builder: (context, state) {
                          return Text(
                            state.getValue() ?? "",
                            style: TextStyle(
                              decoration:
                                  state.getAttribute<bool>("done") == true
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          );
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JustCheckbox(
                            name: "done",
                            initialValue: false,
                            onChanged: (value) {
                              context.justForm
                                  .field("todo")
                                  ?.setAttribute("done", value == true);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              state.delete();
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        final doneField = context.justForm.field<bool>("done");
                        doneField?.setValue(!(doneField.getValue() ?? false));
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    var formController = context.justForm;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Todo Form"),
                          content: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black87,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                JsonEncoder.withIndent('  ').convert(
                                  formController
                                      .getValues(withHiddenFields: true)
                                      .map((key, value) {
                                        var formatedValue = value;
                                        if (value is DateTime) {
                                          formatedValue = value.toString();
                                        }
                                        if (value is TimeOfDay) {
                                          formatedValue = value.toString();
                                        }
                                        return MapEntry(key, formatedValue);
                                      }),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
