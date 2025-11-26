import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/debouncer.dart';
import 'package:just_form/just_validator.dart';
part 'just_form_controller.dart';
part 'just_field_state.dart';
part 'just_field.dart';
part 'just_field_controller.dart';

class JustFormBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final JustFormController? controller;
  final Map<String, dynamic>? initialValues;
  final List<JustValidator> validators;
  final ValueChanged<Map<String, dynamic>>? onValuesChanged;
  final ValueChanged<Map<String, String?>>? onErrorsChanged;

  const JustFormBuilder({
    super.key,
    required this.builder,
    this.controller,
    this.initialValues,
    this.onValuesChanged,
    this.onErrorsChanged,
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
    if (widget.controller == null) {
      _ownController = true;
      _controller = JustFormController(
        initialValues: widget.initialValues ?? {},
      );
    } else {
      _controller = widget.controller!;
    }

    _controller.validators.addAll(widget.validators);

    if (widget.onValuesChanged != null) {
      _controller.addValuesChangedListener(widget.onValuesChanged!);
    }

    if (widget.onErrorsChanged != null) {
      _controller.addErrorChangedListener(widget.onErrorsChanged!);
    }

    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   print("form are rendered");
    // });
  }

  @override
  void dispose() {
    if (widget.onValuesChanged != null) {
      _controller.removeValuesChangedListener(widget.onValuesChanged!);
    }

    if (widget.onErrorsChanged != null) {
      _controller.removeErrorChangedListener(widget.onErrorsChanged!);
    }

    if (_ownController) _controller.dispose();
    super.dispose();
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
