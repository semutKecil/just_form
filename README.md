# Just Form

# This README are UNDER CONSTRUCTION
Example code may be not work. i'm in rush generate it with AI couse my team need to use it asap. will be back soon

A powerful and flexible Flutter form management package that provides automatic field registration, validation, state management using BLoC pattern, and built-in field widgets.

## Table of Contents

- [Just Form](#just-form)
- [This README are UNDER CONSTRUCTION](#this-readme-are-under-construction)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [Getting Started](#getting-started)
    - [Installation](#installation)
    - [Basic Usage](#basic-usage)
  - [Validation](#validation)
    - [Built-in Validators](#built-in-validators)
    - [Custom Validators](#custom-validators)
    - [Cross-Field Validation](#cross-field-validation)
  - [Form Fields](#form-fields)
    - [Available Fields](#available-fields)
      - [1. **JustTextField**](#1-justtextfield)
      - [2. **JustDateField**](#2-justdatefield)
      - [3. **JustTimeField**](#3-justtimefield)
      - [4. **JustDropDownButton**](#4-justdropdownbutton)
      - [5. **JustCheckbox**](#5-justcheckbox)
      - [6. **JustSwitch**](#6-justswitch)
      - [7. **JustSlider**](#7-justslider)
      - [8. **JustRangeSlider**](#8-justrangeslider)
      - [9. **JustRadioGroup**](#9-justradiogroup)
      - [10. **JustCheckboxListTile**](#10-justcheckboxlisttile)
      - [11. **JustSwitchListTile**](#11-justswitchlisttile)
      - [12. **JustFieldList**](#12-justfieldlist)
      - [13. **JustPickerField**](#13-justpickerfield)
      - [14. **JustNestedBuilder**](#14-justnestedbuilder)
    - [Creating Custom Fields](#creating-custom-fields)
  - [Advanced Features](#advanced-features)
    - [Manipulating Attributes](#manipulating-attributes)
    - [Form Control](#form-control)
    - [Selective Rebuilds](#selective-rebuilds)
  - [Examples](#examples)
  - [API Reference](#api-reference)
    - [JustFormBuilder](#justformbuilder)
    - [JustField](#justfield)
    - [JustBuilder](#justbuilder)
    - [JustFieldController](#justfieldcontroller)
  - [License](#license)
  - [Contributing](#contributing)
  - [Support](#support)

---

## Overview

**Just Form** simplifies form building in Flutter by:

- **Automatic Field Management** - Fields register themselves with the form controller
- **Type-Safe** - Full generic type support for any value type
- **Performance Optimized** - Selective rebuild control and fine-grained state tracking
- **Validation Ready** - Built-in validators and cross-field validation support
- **BLoC Powered** - Uses Flutter BLoC for predictable state management
- **Extensible** - Easily create custom field widgets
- **Attribute Tracking** - Store and track custom metadata alongside field values

---

## Features

✅ Automatic form field registration and lifecycle management  
✅ Real-time field value and error tracking  
✅ Cross-field validation support  
✅ Custom field widget creation  
✅ Flexible rebuild triggers (value, error, attributes)  
✅ Field attribute manipulation  
✅ External and internal controller management  
✅ Built-in field widgets (TextField, DateField, DropdownField, etc.)  
✅ Selective field rebuilding with `JustBuilder`  
✅ Debouncing and validation optimization  

---

## Getting Started

### Installation

Add `just_form` to your `pubspec.yaml`:

```yaml
dependencies:
  just_form: ^0.0.1
  flutter_bloc: ^9.1.1
```

### Basic Usage

The simplest form requires just a `JustFormBuilder` and some fields:

```dart
import 'package:flutter/material.dart';
import 'package:just_form/just_form_builder.dart';
import 'package:just_form/field/just_text_field.dart';

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JustFormBuilder(
      builder: (context) {
        return Column(
          children: [
            // Email field
            JustTextField(
              name: 'email',
              builder: (context, controller) {
                return TextField(
                  onChanged: (value) => controller.value = value,
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    errorText: controller.error,
                  ),
                );
              },
            ),
            
            // Password field
            JustTextField(
              name: 'password',
              builder: (context, controller) {
                return TextField(
                  onChanged: (value) => controller.value = value,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    errorText: controller.error,
                  ),
                );
              },
            ),
            
            // Submit button
            ElevatedButton(
              onPressed: () {
                final formController = context.read<JustFormController>();
                print('Form values: ${formController.getValues()}');
                print('Form errors: ${formController.getErrors()}');
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
```

---

## Validation

### Built-in Validators

Just Form supports any `FormFieldValidator<T>` from Flutter. Use packages like `validatorless` or create your own:

```dart
JustTextField(
  name: 'email',
  validators: [
    (value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      if (!value.contains('@')) {
        return 'Please enter a valid email';
      }
      return null;
    },
  ],
  builder: (context, controller) {
    return TextField(
      onChanged: (value) => controller.value = value,
      decoration: InputDecoration(errorText: controller.error),
    );
  },
)
```

### Custom Validators

Create reusable custom validators:

```dart
class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }
}

// Usage
JustTextField(
  name: 'email',
  validators: [EmailValidator.validate],
  builder: (context, controller) => TextField(...),
)
```

### Cross-Field Validation

Validate multiple fields together using `JustValidator`:

```dart
JustFormBuilder(
  validators: [
    JustValidator(
      triggers: ['password', 're-password'],
      validator: (formValues) {
        final password = formValues?['password'];
        final confirmPassword = formValues?['re-password'];
        
        if (password != confirmPassword) {
          return 'Passwords do not match';
        }
        return null;
      },
      targets: [
        JustTargetError(
          field: 're-password',
          message: (error) => 'Passwords do not match',
        ),
      ],
    ),
  ],
  builder: (context) {
    return Column(
      children: [
        JustTextField(
          name: 'password',
          builder: (context, controller) => TextField(...),
        ),
        JustTextField(
          name: 're-password',
          builder: (context, controller) => TextField(...),
        ),
      ],
    );
  },
)
```

---

## Form Fields

### Available Fields

Just Form provides pre-built field widgets for common use cases:

#### 1. **JustTextField**
Text input field with optional validation display.

```dart
JustTextField(
  name: 'username',
  initialValue: 'John',
  validators: [/* validators */],
  builder: (context, controller) {
    return TextField(
      controller: TextEditingController(text: controller.value),
      onChanged: (value) => controller.value = value,
      decoration: InputDecoration(errorText: controller.error),
    );
  },
)
```

#### 2. **JustDateField**
Date picker field.

```dart
JustDateField(
  name: 'birth-date',
  initialValue: DateTime(2000, 1, 1),
  builder: (context, controller) {
    return TextField(
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: controller.value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) controller.value = date;
      },
      decoration: InputDecoration(
        hintText: 'Select date',
        suffixIcon: Icon(Icons.calendar_today),
      ),
    );
  },
)
```

#### 3. **JustTimeField**
Time picker field.

```dart
JustTimeField(
  name: 'appointment-time',
  builder: (context, controller) {
    return TextField(
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: controller.value ?? TimeOfDay.now(),
        );
        if (time != null) controller.value = time;
      },
      decoration: InputDecoration(
        hintText: 'Select time',
        suffixIcon: Icon(Icons.access_time),
      ),
    );
  },
)
```

#### 4. **JustDropDownButton**
Dropdown selection field.

```dart
JustDropDownButton<String>(
  name: 'country',
  initialValue: 'US',
  builder: (context, controller) {
    return DropdownButton<String>(
      value: controller.value,
      onChanged: (value) => controller.value = value,
      items: ['US', 'UK', 'CA', 'AU']
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
    );
  },
)
```

#### 5. **JustCheckbox**
Boolean checkbox field.

```dart
JustCheckbox(
  name: 'agree-terms',
  initialValue: false,
  builder: (context, controller) {
    return Checkbox(
      value: controller.value ?? false,
      onChanged: (value) => controller.value = value,
    );
  },
)
```

#### 6. **JustSwitch**
Toggle switch field.

```dart
JustSwitch(
  name: 'notifications-enabled',
  initialValue: true,
  builder: (context, controller) {
    return Switch(
      value: controller.value ?? false,
      onChanged: (value) => controller.value = value,
    );
  },
)
```

#### 7. **JustSlider**
Slider field for numeric values.

```dart
JustSlider(
  name: 'brightness',
  initialValue: 0.5,
  builder: (context, controller) {
    return Slider(
      value: controller.value ?? 0.5,
      onChanged: (value) => controller.value = value,
      min: 0,
      max: 1,
    );
  },
)
```

#### 8. **JustRangeSlider**
Range slider for selecting min/max values.

```dart
JustRangeSlider(
  name: 'price-range',
  initialValue: RangeValues(10, 100),
  builder: (context, controller) {
    final range = controller.value ?? RangeValues(10, 100);
    return RangeSlider(
      values: range,
      onChanged: (value) => controller.value = value,
      min: 0,
      max: 500,
    );
  },
)
```

#### 9. **JustRadioGroup**
Radio button group field.

```dart
JustRadioGroup<String>(
  name: 'plan',
  initialValue: 'basic',
  builder: (context, controller) {
    return Column(
      children: ['basic', 'pro', 'enterprise'].map((plan) {
        return RadioListTile<String>(
          value: plan,
          groupValue: controller.value,
          onChanged: (value) => controller.value = value,
          title: Text(plan),
        );
      }).toList(),
    );
  },
)
```

#### 10. **JustCheckboxListTile**
Checkbox list tile field.

```dart
JustCheckboxListTile(
  name: 'marketing-emails',
  initialValue: true,
  builder: (context, controller) {
    return CheckboxListTile(
      value: controller.value ?? false,
      onChanged: (value) => controller.value = value,
      title: Text('Receive marketing emails'),
    );
  },
)
```

#### 11. **JustSwitchListTile**
Switch list tile field.

```dart
JustSwitchListTile(
  name: 'dark-mode',
  initialValue: false,
  builder: (context, controller) {
    return SwitchListTile(
      value: controller.value ?? false,
      onChanged: (value) => controller.value = value,
      title: Text('Dark Mode'),
    );
  },
)
```

#### 12. **JustFieldList**
Dynamic list of fields.

```dart
JustFieldList(
  name: 'phone-numbers',
  initialValue: [],
  builder: (context, controller) {
    return Column(
      children: [
        ...List.generate(
          controller.value?.length ?? 0,
          (index) => JustTextField(
            name: 'phone-numbers.$index',
            builder: (context, fieldController) => TextField(),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final numbers = controller.value ?? [];
            controller.value = [...numbers, ''];
          },
          child: Text('Add Phone'),
        ),
      ],
    );
  },
)
```

#### 13. **JustPickerField**
Generic picker field for custom selection.

```dart
JustPickerField<Color>(
  name: 'favorite-color',
  initialValue: Colors.blue,
  builder: (context, controller) {
    return ListTile(
      title: Text('Favorite Color'),
      trailing: Container(
        width: 50,
        color: controller.value ?? Colors.blue,
      ),
      onTap: () async {
        // Show color picker
      },
    );
  },
)
```

#### 14. **JustNestedBuilder**
Nested form fields.

```dart
JustNestedBuilder(
  name: 'address',
  initialValue: {},
  builder: (context, controller) {
    return Column(
      children: [
        JustTextField(
          name: 'address.street',
          builder: (context, fieldController) => TextField(),
        ),
        JustTextField(
          name: 'address.city',
          builder: (context, fieldController) => TextField(),
        ),
      ],
    );
  },
)
```

### Creating Custom Fields

Create your own field widgets by extending `JustField<T>`:

```dart
class MyCustomField extends StatelessWidget {
  final String name;
  final String? initialValue;
  final void Function(String?)? onChanged;

  const MyCustomField({
    required this.name,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return JustField<String>(
      name: name,
      initialValue: initialValue,
      builder: (context, controller) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) {
                  controller.value = value;
                  onChanged?.call(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  border: InputBorder.none,
                  errorText: controller.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Usage
MyCustomField(
  name: 'custom-field',
  initialValue: 'Hello',
  onChanged: (value) => print('Changed: $value'),
)
```

---

## Advanced Features

### Manipulating Attributes

Attributes are custom metadata you can attach to fields:

```dart
JustTextField(
  name: 'email',
  initialAttributes: {
    'touched': false,
    'validating': false,
    'lastValidated': null,
  },
  builder: (context, controller) {
    return TextField(
      onChanged: (value) {
        controller.value = value;
        // Mark field as touched
        controller.setAttribute('touched', true);
      },
      onFocus: (hasFocus) {
        if (hasFocus) {
          controller.setAttribute('validating', true);
        }
      },
      decoration: InputDecoration(
        hintText: 'Enter email',
        errorText: controller.error,
        filled: controller.attributes['touched'] == true,
        fillColor: Colors.blue.withOpacity(0.1),
      ),
    );
  },
)
```

**Access attributes in JustBuilder:**

```dart
JustBuilder(
  fields: ['email'],
  rebuildOnAttributeChanged: true,
  builder: (context, state) {
    final email = state['email'];
    final touched = email?.attributes['touched'] ?? false;
    
    return Column(
      children: [
        if (touched) Text('Field was touched'),
        if (email?.attributes['validating'] == true)
          CircularProgressIndicator(),
      ],
    );
  },
)
```

### Form Control

Access and manipulate the entire form:

```dart
ElevatedButton(
  onPressed: () {
    final formController = context.read<JustFormController>();
    
    // Get all values
    print('Values: ${formController.values}');
    
    // Get all errors
    print('Errors: ${formController.errors}');
    
    // Validate the form
    final isValid = await formController.validate();
    
    // Set field value
    formController.fields()['email']?.value = 'new@email.com';
    
    // Reset form
    formController.reset();
    
    // Get specific field
    final emailField = formController.fields()['email'];
    print('Email value: ${emailField?.value}');
  },
  child: Text('Check Form'),
)
```

### Selective Rebuilds

Use `JustBuilder` to rebuild only when specific fields change:

```dart
JustBuilder(
  fields: ['email', 'password'],
  rebuildOnValueChanged: true,
  rebuildOnErrorChanged: true,
  builder: (context, state) {
    final email = state['email'];
    final password = state['password'];
    
    return Column(
      children: [
        if (email?.error != null)
          Text('Email error: ${email?.error}'),
        if (password?.error != null)
          Text('Password error: ${password?.error}'),
        // Rebuild only when email or password changes
      ],
    );
  },
)
```

---

## Examples

Check the `/example` folder for complete working examples:

- **basic_example.dart** - Complete form with various field types
- **basic_example_nested_form.dart** - Nested forms and complex structures
- **todo.dart** - Dynamic list of fields example

To run the example:

```bash
cd example
flutter run
```

---

## API Reference

### JustFormBuilder

The main widget for building forms.

**Properties:**
- `builder` - Required. Widget builder function
- `controller` - Optional. External form controller
- `initialValues` - Map of initial field values
- `validators` - List of form-level validators
- `onFieldRegistered` - Callback when field registers
- `onValuesChanged` - Callback when any field value changes
- `onErrorsChanged` - Callback when errors change

### JustField<T>

Generic field widget for managing individual form fields.

**Properties:**
- `name` - Required. Unique field identifier
- `builder` - Required. Field widget builder
- `initialValue` - Initial field value
- `validators` - Field-level validators
- `keepValueOnDestroy` - Preserve value on widget removal
- `rebuildOnValueChanged` - Rebuild on value changes
- `rebuildOnErrorChanged` - Rebuild on error changes
- `rebuildOnAttributeChanged` - Rebuild on attribute changes
- `initialAttributes` - Custom metadata

### JustBuilder

Selective field listener and rebuilder.

**Properties:**
- `fields` - List of field names to monitor
- `allFields` - Monitor all fields
- `builder` - Required. Widget builder function
- `rebuildOnValueChanged` - Rebuild on value changes
- `rebuildOnErrorChanged` - Rebuild on error changes
- `rebuildOnAttributeChanged` - Rebuild on attribute changes

### JustFieldController<T>

Controller for individual field management.

**Properties:**
- `value` - Get/set field value
- `error` - Get/set field error
- `attributes` - Get field attributes

**Methods:**
- `setValue(T value)` - Set field value
- `setError(String? error)` - Set field error
- `setAttribute(String key, dynamic value)` - Set attribute
- `getState()` - Get current field state

---

## License

This package is licensed under the MIT License. See LICENSE file for details.

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## Support

For issues, questions, or suggestions, please open an issue on the GitHub repository.
