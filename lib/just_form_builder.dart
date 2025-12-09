import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/debouncer.dart';
import 'package:just_form/just_field_state.dart';
import 'package:just_form/just_validator.dart';
part 'just_form_controller.dart';
part 'just_field.dart';
part 'just_field_controller.dart';
part 'field/just_nested_builder.dart';
part 'just_field_data.dart';

class JustFormBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final JustFormController? controller;
  final Map<String, dynamic>? initialValues;
  final List<JustValidator> validators;
  final ValueChanged<Map<String, dynamic>>? onFieldRegistered;
  final ValueChanged<Map<String, dynamic>>? onValuesChanged;
  final ValueChanged<Map<String, String?>>? onErrorsChanged;

  const JustFormBuilder({
    super.key,
    required this.builder,
    this.controller,
    this.initialValues,
    this.onValuesChanged,
    this.onErrorsChanged,
    this.onFieldRegistered,
    this.validators = const [],
  });

  @override
  State<JustFormBuilder> createState() => _JustFormBuilderState();
}

class _JustFormBuilderState extends State<JustFormBuilder> {
  late JustFormController _controller;
  bool _ownController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = true;
      _controller = JustFormController(
        initialValues: widget.initialValues ?? {},
        validators: widget.validators,
        onFieldRegistered: widget.onFieldRegistered,
      );
    } else {
      _controller = widget.controller!;
    }

    if (widget.onValuesChanged != null) {
      _controller.addValuesChangedListener(widget.onValuesChanged!);
    }

    if (widget.onErrorsChanged != null) {
      _controller.addErrorsChangedListener(widget.onErrorsChanged!);
    }
  }

  @override
  void dispose() {
    if (widget.onValuesChanged != null) {
      _controller.removeValuesChangedListener(widget.onValuesChanged!);
    }

    if (widget.onErrorsChanged != null) {
      _controller.removeErrorsChangedListener(widget.onErrorsChanged!);
    }

    if (_ownController) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JustFormController>(
      create: (context) {
        return _controller;
      },
      child: Builder(
        builder: (context) {
          return widget.builder(context);
        },
      ),
    );
  }
}
