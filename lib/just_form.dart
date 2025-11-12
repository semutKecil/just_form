import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/debouncer.dart';
import 'package:just_form/just_validator.dart';
part 'just_form_controller.dart';
part 'just_field_state.dart';
part 'just_field.dart';
part 'just_field_controller.dart';
part 'just_field_updater.dart';

class JustForm extends StatefulWidget {
  final Widget child;
  final JustFormController? controller;
  final Map<String, dynamic>? initialValues;
  const JustForm({
    super.key,
    required this.child,
    this.controller,
    this.initialValues,
  });

  @override
  State<JustForm> createState() => _JustFormState();
}

class _JustFormState extends State<JustForm> {
  late JustFormController _controller;
  bool _ownController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = true;
      _controller = JustFormController(initialValues: widget.initialValues);
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_ownController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JustFormController>(
      create: (context) {
        return _controller;
      },
      child: widget.child,
    );
  }
}
