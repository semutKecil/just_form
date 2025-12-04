import 'package:flutter/material.dart';
import 'package:just_form/field/just_checkbox.dart';
import 'package:just_form/field/just_checkbox_list_tile.dart';
import 'package:just_form/field/just_drop_down_button.dart';
import 'package:just_form/field/just_radio_group.dart';
import 'package:just_form/field/just_slider.dart';
import 'package:just_form/field/just_text_field.dart';
import 'package:just_form/just_builder.dart';
import 'package:just_form/just_form_builder.dart';
import 'package:validatorless/validatorless.dart';

class BasicExampleNestedForm extends StatelessWidget {
  final JustFormController parentForm;
  const BasicExampleNestedForm({super.key, required this.parentForm});

  @override
  Widget build(BuildContext context) {
    return JustBuilder(
      fields: ["display-sub-form"],
      rebuildOnValueChanged: true,
      builder: (context, state) {
        final bool showDisplay = state["display-sub-form"]?.getValue() ?? false;
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: showDisplay
              ? SizedBox(
                  key: ValueKey(1),
                  width: double.maxFinite,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: JustNestedBuilder(
                        name: "sub-form",
                        builder: (context) {
                          return Column(
                            spacing: 10,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  JustCheckbox(name: "some-text-enabled"),
                                  Expanded(
                                    child: JustBuilder(
                                      fields: ["some-text-enabled"],
                                      rebuildOnValueChanged: true,
                                      builder: (context, state) {
                                        return JustTextField(
                                          name: "some-text",
                                          validators: [
                                            Validatorless.required(
                                              "Field is required",
                                            ),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: "Some Text",
                                            enabled:
                                                state["some-text-enabled"]
                                                    ?.getValue() ??
                                                false,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              JustRadioGroup(
                                name: "radioGroup",
                                initialValue: "B",
                                child: Wrap(
                                  spacing: 10,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context.justForm
                                            .field("radioGroup")
                                            ?.setValue("A");
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
                                        context.justForm
                                            .field("radioGroup")
                                            ?.setValue("B");
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
                                        context.justForm
                                            .field("radioGroup")
                                            ?.setValue("C");
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
                              Card(
                                elevation: 0,
                                color: Colors.grey[400],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    spacing: 10,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text("Slider")),
                                          JustBuilder(
                                            fields: ["slider"],

                                            rebuildOnValueChanged: true,
                                            builder: (context, state) {
                                              return Text(
                                                "${state["slider"]?.getValue()}",
                                              );
                                            },
                                          ),
                                        ],
                                      ),

                                      JustSlider(
                                        name: "slider",
                                        initialValue: 0.46375,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              JustCheckboxListTile(
                                name: "checkbox",
                                title: Text("Checkbox"),
                              ),
                              JustBuilder(
                                fields: ["checkbox"],
                                rebuildOnValueChanged: true,
                                builder: (context, state) {
                                  if (state["checkbox"]?.getValue() == true) {
                                    return JustTextField(
                                      name: "hidden-text",
                                      initialValue: "hidden text",
                                      decoration: InputDecoration(
                                        labelText: "Hidden text",
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text("Select item")),
                                    JustDropDownButton(
                                      name: "dropdown",
                                      hint: Text("select value"),
                                      items: [
                                        DropdownMenuItem(
                                          value: "A",
                                          child: Text("A"),
                                        ),
                                        DropdownMenuItem(
                                          value: "B",
                                          child: Text("B"),
                                        ),
                                        DropdownMenuItem(
                                          value: "C",
                                          child: Text("C"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  parentForm
                                      .field("display-sub-form")
                                      ?.setValue(false);
                                },
                                icon: Icon(Icons.close),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(key: ValueKey(2)),
        );

        // return ;
      },
    );
  }
}
