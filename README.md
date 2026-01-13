# Just Form

[![pub package](https://img.shields.io/pub/v/just_form.svg)](https://pub.dev/packages/just_form) ![Platform](https://img.shields.io/badge/platform-flutter-blue) [![Donate on Saweria](https://img.shields.io/badge/Donate-Saweria-orange)](https://saweria.co/hrlns) [![Donate on Ko-fi](https://img.shields.io/badge/Donate-Ko--fi-ff5f5f?logo=ko-fi&logoColor=white&style=flat)](https://ko-fi.com/M4M81N5IYI)

A powerful and flexible Flutter form management package that provides automatic field registration, validation, state management using BLoC pattern, and built-in field widgets.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M81N5IYI)

## Table of Contents

- [Just Form](#just-form)
  - [Table of Contents](#table-of-contents)
  - [ScreenShots](#screenshots)
  - [Basic Usage](#basic-usage)
    - [1. Wrap your form with JustFormBuilder](#1-wrap-your-form-with-justformbuilder)
    - [2. Add form fields](#2-add-form-fields)
    - [3. Validate and get form values](#3-validate-and-get-form-values)
  - [Validation](#validation)
    - [1. Field-Level Validation](#1-field-level-validation)
    - [2. Form-Level Validation](#2-form-level-validation)
    - [3. Custom/Async Validation](#3-customasync-validation)
  - [Initial Values](#initial-values)
    - [Priority (Highest to Lowest):](#priority-highest-to-lowest)
    - [How it Works:](#how-it-works)
    - [Example:](#example)


---

## ScreenShots

| Basic Usage | Todo |
|----------|-----|
| ![Fix Height](screenshots/basic-example.gif) | ![Fix Height](screenshots/todo-example.gif) |

---

## Basic Usage

### 1. Wrap your form with JustFormBuilder

```dart
JustFormBuilder(
  initialValues: {
    "username": "John_Doe",
    "birth-date": DateTime.now(),
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
          message: (error) => "The password doesn't match",
        ),
      ],
    ),
  ],
  builder: (context) {
    // Your form fields here
    return Column(children: [
      // Form fields
    ]);
  },
)
```

### 2. Add form fields

Use built-in Just Form field widgets:

```dart
JustTextField(
  name: "username",
  decoration: InputDecoration(labelText: "Username"),
  validators: [
    Validatorless.required("Field is required"),
    Validatorless.min(6, 'Min length 6'),
    Validatorless.max(20, 'Max length 20'),
  ],
),
JustTextField(
  name: "password",
  obscureText: true,
  decoration: InputDecoration(labelText: "Password"),
  validators: [
    Validatorless.required("Field is required"),
    Validatorless.min(6, 'Min length 6'),
  ],
),
JustDateField(
  name: "birth-date",
  firstDate: DateTime(1800),
  lastDate: DateTime.now(),
  decoration: InputDecoration(labelText: "Birth Date"),
),
JustCheckbox(
  name: "agree",
  initialValue: false,
),
JustSwitchListTile(
  name: "notifications",
  title: Text("Enable Notifications"),
),
```

### 3. Validate and get form values

```dart
ElevatedButton(
  onPressed: () {
    var formController = context.justForm;
    formController.validate();
    
    if (formController.isValid()) {
      var formData = formController.getValues();
      print(formData); // Use the form data
    } else {
      var errors = formController.getErrors();
      print(errors); // Handle validation errors
    }
  },
  child: Text("Submit"),
)
```

---

## Validation

Just Form supports three types of validation:

### 1. Field-Level Validation

Validate individual fields using the `validators` parameter. Field validators only check their own value:

```dart
JustTextField(
  name: "username",
  decoration: InputDecoration(labelText: "Username"),
  validators: [
    Validatorless.required("Field is required"),
    Validatorless.min(6, 'Min length 6'),
    Validatorless.max(20, 'Max length 20'),
  ],
),
JustTextField(
  name: "email",
  decoration: InputDecoration(labelText: "Email"),
  validators: [
    Validatorless.required("Field is required"),
    Validatorless.email("Invalid email"),
  ],
),
```

### 2. Form-Level Validation

Validate across multiple fields using `JustValidator` in the `JustFormBuilder`. This allows you to combine multiple field values and target errors to specific fields:

```dart
JustFormBuilder(
  validators: [
    JustValidator(
      triggers: ["password", "re-password"],  // Fields that trigger this validator
      validator: (value) {
        if (value?["password"] != value?["re-password"]) {
          return "not_match";
        }
        return null;
      },
      targets: [
        JustTargetError(
          field: "re-password",  // Target field to show the error
          message: (error) => "The password doesn't match",
        ),
      ],
    ),
  ],
  builder: (context) {
    // Form fields
  },
)
```

**How it works:**
- `triggers`: List of field names that trigger this validator when they change
- `validator`: Function that receives all form values and returns an error or null
- `targets`: List of fields where errors should be displayed (supports multiple fields)

### 3. Custom/Async Validation

Set custom errors programmatically using the `setError()` function. This is useful for async validation like checking if an email already exists:

```dart
ElevatedButton(
  onPressed: () async {
    var emailField = context.justForm.field('email');
    
    // Show loading state
    emailField.setError("Checking...");
    
    // Simulate async validation
    await Future.delayed(Duration(seconds: 2));
    
    // Check if email exists (example)
    bool emailExists = await checkEmailExists(emailField.getValue());
    
    if (emailExists) {
      emailField.setError("Email already exists");
    } else {
      emailField.setError(null); // Clear error
    }
  },
  child: Text("Check Email"),
)
```

**Getting form data with validation:**

```dart
var formController = context.justForm;
formController.validate();

if (formController.isValid()) {
  var formData = formController.getValues();
  print(formData); // Process valid form data
} else {
  var errors = formController.getErrors();
  print(errors); // Handle validation errors
}
```

---

## Initial Values

Just Form supports setting initial values at three levels with a clear priority order:

### Priority (Highest to Lowest):
1. **Controller Level** (Highest) - `JustFormController.initialValues`
2. **Form Level** - `JustFormBuilder.initialValues` (only used if controller has no initialValues)
3. **Field Level** (Lowest) - Individual field's `initialValue` parameter

### How it Works:

- If the **controller** has `initialValues` set, it completely **replaces** the form's initialValues
- For each field without an initial value in the controller, the **form initial value** is used
- If neither controller nor form have an initial value, the **field initial value** is used
- If none are specified, the field defaults to null

### Example:

```dart
// 1. Controller Level (Strongest) - Replaces form initialValues entirely
var controller = JustFormController(
  initialValues: {
    "username": "admin",
    "email": "admin@example.com",
  },
);

// 2. Form Level (Medium) - Only used if controller has no initialValues
JustFormBuilder(
  initialValues: { // Completely ignored because controller has initialValues
    "username": "user",  
    "phone": "+1234567890",
  },
  builder: (context) {
    return Column(
      children: [
        // 3. Field Level (Lowest)
        JustTextField(
          name: "username",
          initialValue: "guest",  // Ignored - controller takes precedence
        ),
        JustTextField(
          name: "phone",
          initialValue: "+0000000000",  // Used - no controller value
        ),
        JustTextField(
          name: "address",
          initialValue: "123 Main St",  // Used - no controller value
        ),
      ],
    );
  },
)
```

**Result:**
- `username`: `"admin"` (from controller)
- `email`: `"admin@example.com"` (from controller)
- `phone`: `"+0000000000"` (from field)
- `address`: `"123 Main St"` (from field)

---
