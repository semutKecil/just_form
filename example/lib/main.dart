import 'package:flutter/material.dart';
import 'package:just_form/field/just_checkbox.dart';
import 'package:just_form/field/just_checkbox_list_tile.dart';
import 'package:just_form/field/just_drop_down_button.dart';
import 'package:just_form/field/just_radio_group.dart';
import 'package:just_form/field/just_range_slider.dart';
import 'package:just_form/field/just_switch.dart';
import 'package:just_form/field/just_switch_list_tile.dart';
import 'package:just_form/field/just_text_field.dart';
import 'package:just_form/field/just_slider.dart';
import 'package:just_form/just_field_error.dart';
import 'package:just_form/just_form_builder.dart';
import 'package:just_form/just_builder.dart';
import 'package:just_form/just_nested_builder.dart';
import 'package:just_form/just_validator.dart';
import 'package:validatorless/validatorless.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  // final _controller = JustFormController(
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: SafeArea(
        child: JustFormBuilder(
          initialValues: {
            "username": "john_dzzz",
            "password": "passwwwww",
            "re-password": "passwwwww",
            "check": true,
            "name": "john zz",
          },
          builder: (context) => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      spacing: 10,
                      children: [
                        JustTextField(
                          name: "username",
                          decoration: InputDecoration(
                            labelText: "Username",
                            hintText: "Input Username",
                          ),
                          validators: [
                            JustValidator.common(
                              Validatorless.multiple([
                                Validatorless.required(
                                  'The field is obligatory',
                                ),
                                Validatorless.min(4, 'Min lenght 4'),
                                Validatorless.max(20, 'Max lenght 20'),
                              ]),
                            ),
                            JustValidator<String>(
                              validator: (value, formValues) =>
                                  ((value?.length) ?? 0) <= 5
                                  ? "username value must be more than 5"
                                  : null,
                            ),
                          ],
                        ),
                        JustTextField(
                          name: "password",
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Input Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                context.justForm
                                    .field("password")
                                    .patchAttribute<bool>(
                                      "obscureText",
                                      (oldValue) => !(oldValue ?? true),
                                    );
                              },
                              icon: Icon(Icons.visibility, color: Colors.grey),
                            ),
                          ),
                          validators: [
                            JustValidator.common(
                              Validatorless.required('The field is obligatory'),
                            ),
                            JustValidator<String>(
                              validator: (value, formValues) {
                                return value == formValues["re-password"]
                                    ? null
                                    : "error";
                              },
                              targets: [
                                JustFieldError(
                                  field: "re-password",
                                  message: (error) => "Password not match",
                                ),
                              ],
                            ),
                          ],
                        ),
                        JustTextField(
                          name: "re-password",
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Retype Password",
                            hintText: "Exactly match with password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                context.justForm
                                    .field("re-password")
                                    .patchAttribute<bool>(
                                      "obscureText",
                                      (oldValue) => !(oldValue ?? true),
                                    );
                              },
                              icon: Icon(Icons.visibility, color: Colors.grey),
                            ),
                          ),
                          validators: [
                            JustValidator<String>(
                              validator: (value, formValues) {
                                return value == formValues["password"]
                                    ? null
                                    : "Password not match";
                              },
                            ),
                          ],
                        ),
                        // JustNestedBuilder(
                        //   name: "sub-form",
                        //   builder: (context) {
                        //     return Column(
                        //       children: [
                        //         JustTextField(
                        //           name: "sub-desc",
                        //           validators: [
                        //             JustValidator.common(
                        //               Validatorless.required(
                        //                 'The field is obligatory',
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         JustTextField(
                        //           name: "sub-desc2",
                        //           validators: [
                        //             JustValidator.common(
                        //               Validatorless.required(
                        //                 'The field is obligatory',
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         JustNestedBuilder(
                        //           name: "sub-sub-1",
                        //           builder: (context) {
                        //             return Column(
                        //               children: [
                        //                 JustTextField(
                        //                   name: "sub-sub-1-desc",
                        //                   validators: [
                        //                     JustValidator.common(
                        //                       Validatorless.required(
                        //                         'The field is obligatory',
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ],
                        //             );
                        //           },
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // ),
                        JustRadioGroup(
                          name: "radioGroup",
                          initialValue: "B",
                          child: Wrap(
                            spacing: 10,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.justForm.field("radioGroup").value =
                                      "A";
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Radio A'),
                                    Radio(value: "A"),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.justForm.field("radioGroup").value =
                                      "B";
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Radio B'),
                                    Radio(value: "B"),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.justForm.field("radioGroup").value =
                                      "C";
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Radio C'),
                                    Radio(value: "C"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("Show Detail Form")),
                            JustCheckbox(name: "check"),
                          ],
                        ),
                        JustBuilder(
                          fields: JustBuilderFields.one("check"),
                          notifyValueUpdate: true,
                          builder: (context, state) {
                            return state.field('check').value == true
                                ? Column(
                                    spacing: 10,
                                    children: [
                                      JustTextField(
                                        name: "name",
                                        decoration: InputDecoration(
                                          labelText: "Name",
                                          hintText: "Input Name",
                                        ),
                                        validators: [
                                          JustValidator.common(
                                            Validatorless.required(
                                              'The field is obligatory',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: Text("DropDown")),
                                          JustDropDownButton(
                                            name: "dropdown",
                                            initialValue: "B",
                                            selectedItemBuilder: (context) {
                                              return [
                                                DropdownMenuItem(
                                                  value: "A",
                                                  child: Text(
                                                    "Dropdown value A Selected",
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: "B",
                                                  child: Text(
                                                    "Dropdown value B Selected",
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: "C",
                                                  child: Text(
                                                    "Dropdown value C Selected",
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: "D",
                                                  child: Text(
                                                    "Dropdown value D Selected",
                                                  ),
                                                ),
                                              ];
                                            },
                                            items: [
                                              DropdownMenuItem(
                                                value: "A",
                                                child: Text("Dropdown value A"),
                                              ),
                                              DropdownMenuItem(
                                                value: "B",
                                                child: Text("Dropdown value B"),
                                              ),
                                              DropdownMenuItem(
                                                value: "C",
                                                child: Text("Dropdown value C"),
                                              ),
                                              DropdownMenuItem(
                                                value: "D",
                                                child: Text("Dropdown value D"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Material(
                                        child: JustCheckboxListTile(
                                          name: "cklist",
                                          title: Text("Checkbox list tile"),
                                          tileColor: Colors.blue,
                                        ),
                                      ),
                                      Material(
                                        child: JustSwitchListTile(
                                          name: "switch-tile",
                                          title: Text("Switch list tile"),
                                          tileColor: Colors.blue,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: JustSlider(
                                              name: "slider",
                                              initialValue: 0.46375,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              // reset value
                                              context.justForm
                                                  .field("slider")
                                                  .value = context.justForm
                                                  .field("slider")
                                                  .initialValue;
                                            },
                                            icon: Icon(Icons.refresh),
                                          ),
                                        ],
                                      ),
                                      JustBuilder(
                                        fields: JustBuilderFields.one("slider"),
                                        notifyValueUpdate: true,
                                        builder: (context, state) {
                                          return Text(
                                            "Slider Value: ${state.field("slider").value}",
                                          );
                                        },
                                      ),
                                      JustRangeSlider(name: "range-slider"),
                                      Row(
                                        children: [
                                          Expanded(child: Text("Switch")),
                                          JustSwitch(name: "switch"),
                                        ],
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () {
                          // _controller.field("username").value = "haaaahaa";
                          context.justForm.values = {
                            "username": "jo",
                            "password": "pass0",
                            "re-password": "password",
                            "check": true,
                            "name": "john doe",
                            "switch-tile": true,
                          };
                        },
                        child: Text("Set Value"),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () {
                          context.justForm
                              .validate(exitOnFirstError: false)
                              .then((value) {
                                if (context.mounted) {
                                  // print("Form Validated");
                                  debugPrint("${context.justForm.values}");
                                  debugPrint("${context.justForm.errors}");
                                }
                              });
                        },
                        child: Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
