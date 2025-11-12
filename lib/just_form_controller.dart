part of 'just_form.dart';

const String justReservedFieldName = "_self";

class JustFormController extends Cubit<Map<String, JustFieldState>> {
  late Map<String, dynamic> _pendingValues = {};
  JustFormController({Map<String, dynamic>? initialValues}) : super({}) {
    if (initialValues != null && initialValues.isNotEmpty) {
      values = initialValues;
      _pendingValues = values;
    }
  }

  final Map<String, Debouncer<bool>> _fieldsDebounce = {};
  final Set<String> _registeredFields = {};

  void _update(Map<String, JustFieldState> fields) {
    _pendingValues = fields;
    emit(fields);
  }

  // void _transaction(Function() transaction) {
  //   _delayEmit = true;
  //   print("transaction start");
  //   try {
  //     transaction();
  //     _delayEmit = false;
  //     _update(Map.from(state));
  //   } catch (e, s) {
  //     debugPrint(e.toString());
  //     debugPrintStack(stackTrace: s);
  //   }
  //   print("transaction end");
  //   _delayEmit = false;
  // }

  void _add(String name, JustFieldState field) {
    _update(
      Map<String, JustFieldState>.from(state).map((key, value) {
        return MapEntry(key, value._clean());
      })..[name] = field,
    );
  }

  void _patch(String name, JustFieldState? field) {
    if (field == null) return;
    _update(
      Map<String, JustFieldState>.from(state).map((key, value) {
        return MapEntry(key, value._clean());
      })..[name] = field,
    );
  }

  void _unReg(String name) {
    var fieldController = field(name);
    fieldController.field?._unReg();
    _registeredFields.remove(name);
  }

  void _registerField<T>(
    String name,
    T? initialValue,
    List<JustValidator<T>> validators,
    bool Function(T a, T b)? isEqual,
    FocusNode? focusnode,
  ) {
    if (_registeredFields.contains(name)) {
      throw Exception("Field $name already registered");
    }

    if (name == justReservedFieldName) {
      throw Exception(
        "Reserved Field name. Field name cannot be $justReservedFieldName",
      );
    }
    _registeredFields.add(name);
    var fieldController = field(name);
    var fieldState = fieldController.field;

    if (!_fieldsDebounce.containsKey(name)) {
      _fieldsDebounce[name] = Debouncer(delay: Duration(milliseconds: 200));
    }

    if (fieldState != null) {
      _patch(
        name,
        JustFieldState<T>(
          name: name,
          mode: [JustFieldStateMode.update],
          initialValue: fieldState.initialValue as T?,
          validators: validators,
          isEqual: isEqual,
          attributes: fieldState.attributes,
          value: fieldState.value as T?,
          focusNode: focusnode,
        ),
      );
    } else {
      _add(
        name,
        JustFieldState<T>(
          name: name,
          validators: validators,
          isEqual: isEqual,
          mode: [JustFieldStateMode.update],
          value: initialValue,
          initialValue: initialValue,
          focusNode: focusnode,
        ),
      );
    }
  }

  JustFieldController<T> field<T>(String name) =>
      JustFieldController<T>(controller: this, name: name, internal: false);

  JustFieldController<T> _internalField<T>(String name) =>
      JustFieldController<T>(controller: this, name: name, internal: true);

  Map<String, dynamic> get values => {
    for (var element in state.values) element.name: element.value,
  };

  set values(Map<String, dynamic> values) {
    for (var entry in values.entries) {
      field(entry.key).value = entry.value;
    }
  }

  Map<String, String?> get errors {
    return Map.fromEntries(state.values.map((e) => MapEntry(e.name, e.error)));
  }

  bool get isValid => state.values.every((element) => element.error == null);

  Future<bool> validate({exitOnFirstError = false}) async {
    if (exitOnFirstError) {
      for (var fieldState in state.values) {
        if (!await field(fieldState.name).validate()) {
          return false;
        }
      }
      return true;
    } else {
      var error = await Future.wait(
        state.values.map((e) async => await field(e.name).validate()),
      );

      return !error.contains(false);
    }
  }

  @override
  Future<void> close() {
    for (var element in _fieldsDebounce.values) {
      element.cancel();
    }
    return super.close();
  }

  void dispose() => close();
}
