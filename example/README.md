# 📦 just_form

**Declarative form state management for Flutter—without the boilerplate.**  
`just_form` handles everything: field values, validation, and dynamic attributes.  
You focus on building forms. It handles the state.

---

## 🤝 How to Contribute

Before diving into the docs, here’s how you can support the plugin:

- 🐞 **Found a bug or have an idea?**  
  Open an issue on [GitHub](https://github.com/semutKecil/multi_data_picker/issues)

- 🔧 **Got time to fix it?**  
  Fork the repo and submit a pull request—we’ll review it fast

- 💖 **Want to support the project?**  
  If this plugin makes your life easier, a small donation helps us keep building and improving it for everyone 
  
  [![Donate on Saweria](https://img.shields.io/badge/Donate-Saweria-orange)](https://saweria.co/hrlns) [![Donate on Ko-fi](https://img.shields.io/badge/Donate-Ko--fi-ff5f5f?logo=ko-fi&logoColor=white&style=flat)](https://ko-fi.com/M4M81N5IYI)

- 👍 **Like what you see?**  
  Smash the thumbs-up on pub.dev—it helps more devs discover us!

---

## 📘 Table of Contents

- [📦 just\_form](#-just_form)
  - [🤝 How to Contribute](#-how-to-contribute)
  - [📘 Table of Contents](#-table-of-contents)
  - [✨ Why just\_form?](#-why-just_form)
  - [📖 Documentation](#-documentation)
    - [1. 🔹 Managing Values](#1--managing-values)
    - [2. 🧪 Validating Fields](#2--validating-fields)
    - [3. 🛠️ Managing Attributes](#3-️-managing-attributes)

---

## ✨ Why just_form?

- ✅ **No manual state management**  
  Values, validation, and attributes are fully managed behind the scenes.
- 🧠 **Scoped control**  
  Update fields individually or in bulk—values, errors, attributes.
- 🧩 **Composable API**  
  Clean, idiomatic Dart interfaces for form and field control.
- 🚀 **Fluent updater**  
  Chain updates like `.withValue()`, `.withError()`, `.withAttributes()`.

---

## 📖 Documentation

### 1. 🔹 Managing Values

```dart
final form = JustFormController();

// Set multiple values
form.setValues({
  'email': 'bos@example.com',
  'age': 28,
});

// Get all values
final values = form.getValues();

// Set a single field value
form.field('email').setValue('new@example.com');

// Get a single field value
final email = form.field('email').getValue();
```

---

### 2. 🧪 Validating Fields

```dart
// Validate all fields
final isFormValid = form.validate();

// Validate a single field
final isEmailValid = form.field('email').validate();

// Manual error override
form.field('email').setError('Invalid email format');

// Get current error
final error = form.field('email').getError();
```

---

### 3. 🛠️ Managing Attributes

```dart
// Set field attributes (e.g., enabled, visible, label)
form.field('email').setAttribute('enabled', false);
form.field('email').setAttribute('label', 'Your Email');

// Get attribute
final label = form.field('email').getAttribute('label');

// Batch update with fluent API
form.field('email').updater
  .withValue('bos@herla.dev')
  .withAttributes({'enabled': true, 'label': 'Email'})
  .withError(null)
  .update();
```

---
