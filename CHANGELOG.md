## 0.0.6 - Fix Checkbox
- Fix on JustCheckbox and JustCheckboxListTile cant set null value on tristate true

## 0.0.5 - Moving To Src
- Move source to src

## 0.0.4 - Update ReadME
- Fix Bug on justBuilder with multiple field monitoring

## 0.0.3 - Update ReadME
- Add more documentation in readMe

## 0.0.2 - Documentation & minor fixes

### Fix 
- Fix bug on form listener debouncer.
- Fix bug on internal validation
- Add warning on readme

---

## 0.0.1 - Initial Release

### Features
- ✨ **Automatic Field Registration** - Fields automatically register and unregister with the form controller
- ✨ **Generic Type Support** - Full generic type support for any value type (String, int, DateTime, custom types, etc.)
- ✨ **Form-Level Validation** - Cross-field validation with `JustValidator` and `JustTargetError`
- ✨ **Field-Level Validation** - Support for any `FormFieldValidator<T>` from Flutter
- ✨ **Real-Time State Tracking** - Automatic tracking of field values, errors, and custom attributes
- ✨ **BLoC-Powered State Management** - Uses Flutter BLoC pattern for predictable state management
- ✨ **Selective Rebuilds** - Control rebuild triggers at both field and form level (value, error, attributes)
- ✨ **Field Attributes** - Store and manipulate custom metadata alongside field values
- ✨ **External Controller Support** - Use external controller for form management or let the widget create one
- ✨ **Callback System** - Callbacks for field registration, value changes, error changes, and attribute updates

### Built-In Field Widgets
- `JustTextField` - Text input field with validation display
- `JustDateField` - Date picker field
- `JustTimeField` - Time picker field
- `JustDropDownButton` - Dropdown selection field
- `JustCheckbox` - Boolean checkbox field
- `JustSwitch` - Toggle switch field
- `JustSlider` - Numeric slider field
- `JustRangeSlider` - Range slider for min/max values
- `JustRadioGroup` - Radio button group field
- `JustCheckboxListTile` - Checkbox list tile field
- `JustSwitchListTile` - Switch list tile field
- `JustFieldList` - Dynamic list of fields
- `JustPickerField` - Generic picker field for custom selection
- `JustNestedBuilder` - Nested form fields with hierarchy support

### Core Components
- `JustFormBuilder` - Main form widget with builder pattern
- `JustField<T>` - Generic field widget for custom implementations
- `JustBuilder` - Selective field listener for multi-field updates
- `JustFormController` - Form controller for external form management
- `JustFieldController<T>` - Individual field controller
- `JustValidator` - Cross-field validator with error targeting
- `JustTargetError` - Error targeting system for validation

### Performance Features
- Debouncing support for validation
- Selective rebuild triggers to prevent unnecessary rebuilds
- Attribute-based rebuild filtering
- Efficient field change tracking

### Developer Experience
- Comprehensive inline documentation with examples
- Type-safe generic implementation
- Flexible builder patterns for custom UI
- Full control over rebuild conditions
- Easy-to-use callback system

### Documentation
- Complete README with table of contents
- Basic usage examples
- Validation guide (built-in, custom, cross-field)
- Field creation and customization guide
- Attribute manipulation examples
- API reference for all public classes
- Example projects included

### Initial Release Notes
This is the first release of Just Form, a complete form management solution for Flutter. The package provides everything needed to build complex, validated forms with ease. All core features are stable and ready for production use.
