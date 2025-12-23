import 'dart:convert';
import 'package:example/basic_example_nested_form.dart';
import 'package:flutter/material.dart';
import 'package:just_form/just_form.dart';
import 'package:validatorless/validatorless.dart';

class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: JustFormBuilder(
        initialValues: {
          "username": "John_Doe",
          "birth-date": DateTime.now(),
          "sub-form": {
            "hidden-text": "some random 2",
            "dropdown": "C",
            "checkbox": true,
          },
        },
        validators: [
          JustValidator(
            triggers: ["password", "re-password"],
            validator: (value) {
              if (value?["password"] != value?["re-password"]) {
                return "not_match";
              }
              return null;
            },
            targets: [
              JustTargetError(
                field: "re-password",
                message: (error) {
                  return "The password doesn't match";
                },
              ),
            ],
          ),
        ],
        builder: (context) {
          return Column(
            spacing: 10,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      JustTextField(
                        name: "username",
                        initialValue: "John Doe",
                        decoration: InputDecoration(labelText: "Username"),
                        validators: [
                          Validatorless.required("Field is required"),
                          Validatorless.min(6, 'Min lenght 6'),
                          Validatorless.max(20, 'Max lenght 20'),
                        ],
                      ),
                      JustCheckbox(
                        name: "cktri",
                        tristate: true,
                        initialValue: null,
                        enabled: false,
                      ),
                      JustCheckboxListTile(
                        name: "cktri2",
                        tristate: true,
                        initialValue: null,
                        enabled: false,
                      ),
                      JustTextField(
                        name: "password",
                        initialValue: "password",
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: JustBuilder(
                            fields: ["password"],
                            rebuildOnAttributeChanged: true,
                            builder: (context, state) {
                              var obscure =
                                  state["password"]?.getAttribute(
                                    "obscureText",
                                  ) ??
                                  true;
                              return IconButton(
                                onPressed: () {
                                  state["password"]?.setAttribute(
                                    "obscureText",
                                    !obscure,
                                  );
                                },
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              );
                            },
                          ),
                        ),
                        validators: [
                          Validatorless.required("Field is required"),
                          Validatorless.min(6, 'Min lenght 6'),
                        ],
                      ),
                      JustTextField(
                        name: "re-password",
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Retype Password",
                          suffixIcon: JustBuilder(
                            fields: ["re-password"],
                            rebuildOnAttributeChanged: true,
                            builder: (context, state) {
                              var obscure =
                                  state["re-password"]?.getAttribute(
                                    "obscureText",
                                  ) ??
                                  true;
                              return IconButton(
                                onPressed: () {
                                  state["re-password"]?.setAttribute(
                                    "obscureText",
                                    !obscure,
                                  );
                                },
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      JustTextField(
                        name: "name",
                        decoration: InputDecoration(labelText: "Name"),
                        validators: [
                          Validatorless.required("Field is required"),
                        ],
                      ),
                      JustDateField(
                        name: "birth-date",
                        firstDate: DateTime(1800),
                        lastDate: DateTime.now(),
                        // freeText: false,
                        dateFormatText: "yyyy-MM-dd",
                        decoration: InputDecoration(labelText: "Birth Date"),
                      ),
                      JustTimeField(
                        name: "time",
                        freeText: true,
                        decoration: InputDecoration(labelText: "Time"),
                      ),
                      JustSwitchListTile(
                        name: "display-sub-form",
                        title: Text("Show more fields"),
                      ),

                      BasicExampleNestedForm(parentForm: context.justForm),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    var formController = context.justForm;
                    formController.validate();
                    if (!formController.isValid()) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Invalid Form"),
                            content: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black87,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  JsonEncoder.withIndent(
                                    '  ',
                                  ).convert(formController.getErrors()),
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
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Valid Form"),
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
                    }
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
