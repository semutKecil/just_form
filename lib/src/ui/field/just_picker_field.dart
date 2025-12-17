import 'package:flutter/material.dart';
import 'package:just_form/src/debouncer.dart';
import 'package:just_form/src/ui/just_form_builder.dart';

class JustPickerField<T> extends StatefulWidget
    implements JustFieldValidatorAbstract<T> {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "name", "email",
  /// "password").
  @override
  final String name;

  /// The initial value of the field. This value is ignored when the initial value
  /// is already set on the [JustFormController] or [JustForm].
  @override
  final T? initialValue;

  /// A list of validators to check the value of the field against.
  ///
  /// These validators will be run whenever the value of the field changes.
  ///
  /// The validators will be passed the current value of the field and the
  /// entire form values.
  ///
  /// If any of the validators return an error string, the field will be
  /// marked as invalid.
  @override
  final List<FormFieldValidator<T>> validators;

  @override
  final ValueChanged<T?>? onChanged;

  @override
  final bool keepValueOnDestroy;

  @override
  final Map<String, dynamic> initialAttributes;

  final String? Function(T? value) renderValue;
  final T? Function(String valueText) parseValue;

  final Future<T?> Function(BuildContext context, JustFieldController<T> state)?
  pickerBuilder;

  final bool freeText;

  final String invalidErrorText;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration decoration;

  final Widget pickerIcon;
  final Widget? clearIcon;

  final bool enabled;
  final bool? withClearButton;

  const JustPickerField({
    super.key,
    required this.name,
    required this.parseValue,
    required this.renderValue,
    required this.pickerBuilder,
    required this.pickerIcon,
    this.invalidErrorText = "Invalid format",
    this.freeText = false,
    this.initialValue,
    this.validators = const [],
    this.onChanged,
    this.enabled = true,
    this.keepValueOnDestroy = true,
    this.initialAttributes = const {},
    this.withClearButton,
    this.clearIcon,
    this.decoration = const InputDecoration(),
  });

  @override
  State<JustPickerField<T>> createState() => _JustPickerFieldState<T>();
}

class _JustPickerFieldState<T> extends State<JustPickerField<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Debouncer _invalidValueDebouncer = Debouncer(
    delay: Duration(milliseconds: 300),
  );

  late final bool _withClearButton;

  @override
  void initState() {
    if (widget.withClearButton == null) {
      _withClearButton = !widget.freeText;
    } else {
      _withClearButton = widget.withClearButton!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _invalidValueDebouncer.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _showPicker(
    BuildContext context,
    JustFieldController<T> state,
  ) async {
    _focusNode.requestFocus();
    var valueFuture = widget.pickerBuilder!.call(context, state);

    _focusNode.unfocus();

    var value = await valueFuture;

    if (value != null) {
      if (context.mounted) {
        context.justForm
            .field(widget.name)
            ?.setAttribute("valueInvalid", false);
      }
      state.setValue(value);
      _controller.text = widget.renderValue(value) ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return JustField<T>(
      name: widget.name,
      rebuildOnValueChangedInternally: false,
      rebuildOnErrorChanged: true,
      validators: widget.validators,
      onChanged: (value, isInternalUpdate) {
        if (isInternalUpdate == false) {
          if (value != null) {
            _controller.text = widget.renderValue(value) ?? "";
          } else {
            _controller.text = "";
          }
        }
        widget.onChanged?.call(value);
      },
      onRegistered: (state) {
        _controller.text = widget.renderValue(state.value) ?? "";
      },
      builder: (context, state) {
        return TextFormField(
          controller: _controller,
          readOnly: !widget.freeText,
          focusNode: _focusNode,
          enabled: state.getAttribute<bool>('enabled') ?? widget.enabled,
          mouseCursor: widget.freeText ? null : SystemMouseCursors.click,
          onTap: widget.freeText || !widget.enabled
              ? null
              : () async {
                  await _showPicker(context, state);
                },
          onChanged: (value) {
            _invalidValueDebouncer.run(() {
              if (context.mounted) {
                if (value.isEmpty) {
                  state.setValue(null);
                  context.justForm
                      .field(widget.name)
                      ?.setAttribute("dataInvalid", false);
                  return;
                }
                var data = widget.parseValue(
                  value,
                ); // formatter.tryParseStrict(value);
                if (data == null) {
                  state.setValue(null);
                  context.justForm
                      .field(widget.name)
                      ?.setAttribute("dataInvalid", true);
                  return;
                }
                context.justForm
                    .field(widget.name)
                    ?.setAttribute("dataInvalid", false);
                state.setValue(data);
              }
            });
          },
          forceErrorText: state.getAttribute<bool>("dataInvalid") == true
              ? widget.invalidErrorText
              : state.getError(),
          decoration:
              (state.getAttribute<InputDecoration>('decoration') ??
                      widget.decoration)
                  .copyWith(
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _withClearButton
                            ? Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: IconButton(
                                  onPressed: () {
                                    state.setValue(null);
                                    _controller.text = "";
                                  },
                                  icon:
                                      state.getAttribute<Widget>('clearIcon') ??
                                      widget.clearIcon ??
                                      const Icon(Icons.close),
                                ),
                              )
                            : SizedBox.shrink(),
                        IconButton(
                          onPressed: widget.enabled
                              ? () async {
                                  await _showPicker(context, state);
                                }
                              : null,
                          icon:
                              state.getAttribute<Widget>('pickerIcon') ??
                              widget.pickerIcon,
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
