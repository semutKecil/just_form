import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_form/just_form_builder.dart';
import 'package:just_form/just_validator.dart';

/// A text input field widget integrated with the just_form system.
///
/// [JustTextField] is a convenience widget that wraps Flutter's [TextFormField]
/// and integrates it with the just_form form management system. It automatically
/// handles field registration, validation, state management, and value synchronization.
///
/// The widget manages its own [TextEditingController] and optionally its own [FocusNode]
/// if none are provided. It supports all the standard [TextFormField] properties while
/// adding form-specific features like validators and automatic state tracking.
///
/// Key features:
/// - Automatic form field registration via [JustField]
/// - Integrated validation with [JustValidator]
/// - Automatic value synchronization with form controller
/// - Support for dynamic property overrides via field attributes
/// - Full [TextFormField] customization options
///
/// Example - Basic text input:
/// ```dart
/// JustTextField(
///   name: 'username',
///   decoration: InputDecoration(
///     labelText: 'Username',
///     hintText: 'Enter your username',
///   ),
///   validators: [
///     JustValidator(
///       validate: (value, formValues) =>
///         value?.isEmpty ?? true ? 'Username is required' : null,
///     ),
///   ],
///   onChanged: (value) => print('User typed: $value'),
/// )
/// ```
class JustTextField extends StatefulWidget {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "name", "email",
  /// "password").
  final String name;

  /// The initial value of the field. This value is ignored when the initial value
  /// is already set on the [JustFormController] or [JustForm].
  final String? initialValue;

  /// A list of validators to check the value of the field against.
  ///
  /// These validators will be run whenever the value of the field changes.
  ///
  /// The validators will be passed the current value of the field and the
  /// entire form values.
  ///
  /// If any of the validators return an error string, the field will be
  /// marked as invalid.
  final List<FormFieldValidator<String>> validators;

  /// The configuration for the magnifier of this text field.
  ///
  /// By default, builds a [CupertinoTextMagnifier] on iOS and [TextMagnifier]
  /// on Android, and builds nothing on all other platforms. To suppress the
  /// magnifier, consider passing [TextMagnifierConfiguration.disabled].
  ///
  /// {@macro flutter.widgets.magnifier.intro}
  ///
  /// {@tool dartpad}
  /// This sample demonstrates how to customize the magnifier that this text field uses.
  ///
  /// ** See code in examples/api/lib/widgets/text_magnifier/text_magnifier.0.dart **
  /// {@end-tool}
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// {@macro flutter.widgets.editableText.groupId}
  final Object groupId;

  /// Defines the keyboard focus for this widget.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// myFocusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  ///
  /// ## Keyboard
  ///
  /// Requesting the focus will typically cause the keyboard to be shown
  /// if it's not showing already.
  ///
  /// On Android, the user can hide the keyboard - without changing the focus -
  /// with the system back button. They can restore the keyboard's visibility
  /// by tapping on a text field. The user might hide the keyboard and
  /// switch to a physical keyboard, or they might just need to get it
  /// out of the way for a moment, to expose something it's
  /// obscuring. In this case requesting the focus again will not
  /// cause the focus to change, and will not make the keyboard visible.
  ///
  /// This widget builds an [EditableText] and will ensure that the keyboard is
  /// showing when it is tapped by calling [EditableTextState.requestKeyboard()].
  final FocusNode? focusNode;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration? decoration;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType? keyboardType;

  /// {@template flutter.widgets.TextField.textInputAction}
  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  /// {@endtemplate}
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  ///
  /// This text style is also used as the base style for the [decoration].
  ///
  /// If null, [TextTheme.bodyLarge] will be used. When the text field is disabled,
  /// [TextTheme.bodyLarge] with an opacity of 0.38 will be used instead.
  ///
  /// If null and [ThemeData.useMaterial3] is false, [TextTheme.titleMedium] will
  /// be used. When the text field is disabled, [TextTheme.titleMedium] with
  /// [ThemeData.disabledColor] will be used instead.
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// {@macro flutter.material.InputDecorator.textAlignVertical}
  final TextAlignVertical? textAlignVertical;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.obscuringCharacter}
  final String obscuringCharacter;

  /// {@macro flutter.widgets.editableText.obscureText}
  final bool obscureText;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool autocorrect;

  /// {@macro flutter.services.TextInputConfiguration.smartDashesType}
  final SmartDashesType? smartDashesType;

  /// {@macro flutter.services.TextInputConfiguration.smartQuotesType}
  final SmartQuotesType? smartQuotesType;

  /// {@macro flutter.services.TextInputConfiguration.enableSuggestions}
  final bool enableSuggestions;

  /// {@macro flutter.widgets.editableText.maxLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// If [maxLength] is set to this value, only the "current input length"
  /// part of the character counter is shown.
  static const int noMaxLength = -1;

  /// The maximum number of characters (Unicode grapheme clusters) to allow in
  /// the text field.
  ///
  /// If set, a character counter will be displayed below the
  /// field showing how many characters have been entered. If set to a number
  /// greater than 0, it will also display the maximum number allowed. If set
  /// to [TextField.noMaxLength] then only the current character count is displayed.
  ///
  /// After [maxLength] characters have been input, additional input
  /// is ignored, unless [maxLengthEnforcement] is set to
  /// [MaxLengthEnforcement.none].
  ///
  /// The text field enforces the length with a [LengthLimitingTextInputFormatter],
  /// which is evaluated after the supplied [inputFormatters], if any.
  ///
  /// This value must be either null, [TextField.noMaxLength], or greater than 0.
  /// If null (the default) then there is no limit to the number of characters
  /// that can be entered. If set to [TextField.noMaxLength], then no limit will
  /// be enforced, but the number of characters entered will still be displayed.
  ///
  /// Whitespace characters (e.g. newline, space, tab) are included in the
  /// character count.
  ///
  /// If [maxLengthEnforcement] is [MaxLengthEnforcement.none], then more than
  /// [maxLength] characters may be entered, but the error counter and divider
  /// will switch to the [decoration]'s [InputDecoration.errorStyle] when the
  /// limit is exceeded.
  ///
  /// {@macro flutter.services.lengthLimitingTextInputFormatter.maxLength}
  final int? maxLength;

  /// Determines how the [maxLength] limit should be enforced.
  ///
  /// {@macro flutter.services.textFormatter.effectiveMaxLengthEnforcement}
  ///
  /// {@macro flutter.services.textFormatter.maxLengthEnforcement}
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// {@macro flutter.widgets.editableText.onChanged}
  ///
  /// See also:
  ///
  ///  * [inputFormatters], which are called before [onChanged]
  ///    runs and can validate and change ("format") the input value.
  ///  * [onEditingComplete], [onSubmitted]:
  ///    which are more specialized input change notifications.
  final ValueChanged<String>? onChanged;

  final bool saveValueOnDestroy;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onAppPrivateCommand}
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// If false the text field is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// If non-null this property overrides the [decoration]'s
  /// [InputDecoration.enabled] property.
  ///
  /// When a text field is disabled, all of its children widgets are also
  /// disabled, including the [InputDecoration.suffixIcon]. If you need to keep
  /// the suffix icon interactive while disabling the text field, consider using
  /// [readOnly] and [enableInteractiveSelection] instead:
  ///
  /// ```dart
  /// TextField(
  ///   enabled: true,
  ///   readOnly: true,
  ///   enableInteractiveSelection: false,
  ///   decoration: InputDecoration(
  ///     suffixIcon: IconButton(
  ///       onPressed: () {
  ///         // This will work because the TextField is enabled
  ///       },
  ///       icon: const Icon(Icons.edit_outlined),
  ///     ),
  ///   ),
  /// )
  /// ```
  final bool? enabled;

  /// Determines whether this widget ignores pointer events.
  ///
  /// Defaults to null, and when null, does nothing.
  final bool? ignorePointers;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.cursorOpacityAnimates}
  final bool? cursorOpacityAnimates;

  /// The color of the cursor.
  ///
  /// The cursor indicates the current location of text insertion point in
  /// the field.
  ///
  /// If this is null it will default to the ambient
  /// [DefaultSelectionStyle.cursorColor]. If that is null, and the
  /// [ThemeData.platform] is [TargetPlatform.iOS] or [TargetPlatform.macOS]
  /// it will use [CupertinoThemeData.primaryColor]. Otherwise it will use
  /// the value of [ColorScheme.primary] of [ThemeData.colorScheme].
  final Color? cursorColor;

  /// The color of the cursor when the [InputDecorator] is showing an error.
  ///
  /// If this is null it will default to [TextStyle.color] of
  /// [InputDecoration.errorStyle]. If that is null, it will use
  /// [ColorScheme.error] of [ThemeData.colorScheme].
  final Color? cursorErrorColor;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  final ui.BoxHeightStyle? selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  final ui.BoxWidthStyle? selectionWidthStyle;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If unset, defaults to [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool? enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.selectAllOnFocus}
  final bool? selectAllOnFocus;

  /// {@macro flutter.widgets.editableText.selectionControls}
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@template flutter.material.textfield.onTap}
  /// Called for the first tap in a series of taps.
  ///
  /// The text field builds a [GestureDetector] to handle input events like tap,
  /// to trigger focus requests, to move the caret, adjust the selection, etc.
  /// Handling some of those events by wrapping the text field with a competing
  /// GestureDetector is problematic.
  ///
  /// To unconditionally handle taps, without interfering with the text field's
  /// internal gesture detector, provide this callback.
  ///
  /// If the text field is created with [enabled] false, taps will not be
  /// recognized.
  ///
  /// To be notified when the text field gains or loses the focus, provide a
  /// [focusNode] and add a listener to that.
  ///
  /// To listen to arbitrary pointer events without competing with the
  /// text field's internal gesture detector, use a [Listener].
  /// {@endtemplate}
  ///
  /// If [onTapAlwaysCalled] is enabled, this will also be called for consecutive
  /// taps.
  final GestureTapCallback? onTap;

  /// Whether [onTap] should be called for every tap.
  ///
  /// Defaults to false, so [onTap] is only called for each distinct tap. When
  /// enabled, [onTap] is called for every tap including consecutive taps.
  final bool onTapAlwaysCalled;

  /// {@macro flutter.widgets.editableText.onTapOutside}
  ///
  /// {@tool dartpad}
  /// This example shows how to use a `TextFieldTapRegion` to wrap a set of
  /// "spinner" buttons that increment and decrement a value in the [TextField]
  /// without causing the text field to lose keyboard focus.
  ///
  /// This example includes a generic `SpinnerField<T>` class that you can copy
  /// into your own project and customize.
  ///
  /// ** See code in examples/api/lib/widgets/tap_region/text_field_tap_region.0.dart **
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [TapRegion] for how the region group is determined.
  final TapRegionCallback? onTapOutside;

  /// {@macro flutter.widgets.editableText.onTapUpOutside}
  final TapRegionUpCallback? onTapUpOutside;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.error].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If this property is null, [WidgetStateMouseCursor.textable] will be used.
  ///
  /// The [mouseCursor] is the only property of [TextField] that controls the
  /// appearance of the mouse pointer. All other properties related to "cursor"
  /// stand for the text cursor, which is usually a blinking vertical line at
  /// the editing position.
  final MouseCursor? mouseCursor;

  /// Callback that generates a custom [InputDecoration.counter] widget.
  ///
  /// See [InputCounterWidgetBuilder] for an explanation of the passed in
  /// arguments. The returned widget will be placed below the line in place of
  /// the default widget built when [InputDecoration.counterText] is specified.
  ///
  /// The returned widget will be wrapped in a [Semantics] widget for
  /// accessibility, but it also needs to be accessible itself. For example,
  /// if returning a Text widget, set the [Text.semanticsLabel] property.
  ///
  /// {@tool snippet}
  /// ```dart
  /// Widget counter(
  ///   BuildContext context,
  ///   {
  ///     required int currentLength,
  ///     required int? maxLength,
  ///     required bool isFocused,
  ///   }
  /// ) {
  ///   return Text(
  ///     '$currentLength of $maxLength characters',
  ///     semanticsLabel: 'character count',
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// If buildCounter returns null, then no counter and no Semantics widget will
  /// be created at all.
  final InputCounterWidgetBuilder? buildCounter;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String>? autofillHints;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@template flutter.material.textfield.restorationId}
  /// Restoration ID to save and restore the state of the text field.
  ///
  /// If non-null, the text field will persist and restore its current scroll
  /// offset and - if no [controller] has been provided - the content of the
  /// text field. If a [controller] has been provided, it is the responsibility
  /// of the owner of that controller to persist and restore it, e.g. by using
  /// a [RestorableTextEditingController].
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  /// {@endtemplate}
  final String? restorationId;

  /// {@macro flutter.widgets.editableText.stylusHandwritingEnabled}
  final bool stylusHandwritingEnabled;

  /// {@macro flutter.services.TextInputConfiguration.enableIMEPersonalizedLearning}
  final bool enableIMEPersonalizedLearning;

  /// {@macro flutter.widgets.editableText.contentInsertionConfiguration}
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, will build a default menu based on the platform.
  ///
  /// See also:
  ///
  ///  * [AdaptiveTextSelectionToolbar], which is built by default.
  ///  * [BrowserContextMenu], which allows the browser's context menu on web to
  ///    be disabled and Flutter-rendered context menus to appear.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Determine whether this text field can request the primary focus.
  ///
  /// Defaults to true. If false, the text field will not request focus
  /// when tapped, or when its context menu is displayed. If false it will not
  /// be possible to move the focus to the text field with tab key.
  final bool canRequestFocus;

  /// {@macro flutter.services.TextInputConfiguration.hintLocales}
  final List<Locale>? hintLocales;

  /// {@macro flutter.widgets.editableText.spellCheckConfiguration}
  ///
  /// If [SpellCheckConfiguration.misspelledTextStyle] is not specified in this
  /// configuration, then [materialMisspelledTextStyle] is used by default.
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// Builds a default context menu for text editing (iOS uses system menu).
  ///
  /// This is a static helper that creates the appropriate context menu based on platform.
  /// On iOS with system context menu support, it uses [SystemContextMenu].
  /// Otherwise, it uses [AdaptiveTextSelectionToolbar].
  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        SystemContextMenu.isSupported(context)) {
      return SystemContextMenu.editableText(
        editableTextState: editableTextState,
      );
    }
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  /// Creates a [JustTextField] widget.
  ///
  /// Most parameters match their [TextFormField] equivalents. The [name] and
  /// [validators] parameters are form-specific and required for integration with
  /// the just_form system.
  ///
  /// The widget automatically manages a [TextEditingController] internally. You cannot
  /// provide a custom controller, but you can access the value through the form controller.
  const JustTextField({
    super.key,
    this.initialValue,
    required this.name,
    this.saveValueOnDestroy = true,
    this.validators = const [],
    this.groupId = EditableText,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.cursorErrorColor,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectAllOnFocus,
    this.selectionControls,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.hintLocales,
  });

  /// Creates the state for this widget.
  @override
  State<JustTextField> createState() => _JustTextFieldState();
}

/// The state implementation for [JustTextField].
///
/// This class manages:
/// - The text field's focus node (created internally if not provided)
/// - The text editing controller for the input
/// - Synchronization between the controller's value and the form state
/// - Lifecycle management (initialization and disposal)
class _JustTextFieldState extends State<JustTextField> {
  /// The focus node for this text field, either provided or created internally.
  late final FocusNode _focusNode;

  /// Whether this widget created its own focus node (and thus owns disposal responsibility).
  late final bool _ownFocusNode;

  /// The text editing controller that manages the text input.
  ///
  /// Always created internally by this widget and disposed when the widget is removed.
  final TextEditingController _controller = TextEditingController();

  /// Initializes the focus node.
  ///
  /// If the widget wasn't provided a focus node, this creates one internally
  /// and sets [_ownFocusNode] to true so it will be disposed later.
  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
      _ownFocusNode = false;
    }
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    // });
  }

  /// Cleans up resources when the widget is removed.
  ///
  /// This method:
  /// 1. Disposes the text editing controller
  /// 2. Disposes the focus node if it was created internally
  @override
  void dispose() {
    _controller.dispose();
    if (_ownFocusNode) _focusNode.dispose();
    super.dispose();
  }

  /// Builds the text field widget integrated with the form system.
  ///
  /// This method wraps the text input with a [JustField] widget to integrate
  /// with the form controller. It:
  /// 1. Sets up value synchronization between the text controller and form state
  /// 2. Handles validation error display
  /// 3. Allows dynamic property overrides via field attributes
  /// 4. Builds a [TextFormField] with all standard properties
  ///
  /// Dynamic properties can be changed at runtime via [controller.setAttribute()]:
  /// ```dart
  /// controller.setAttribute('fieldName', 'decoration', newDecoration);
  /// ```
  @override
  Widget build(BuildContext context) {
    return JustField<String>(
      name: widget.name,
      initialValue: widget.initialValue,
      notifyError: true,
      notifyInternalUpdate: false,
      validators: widget.validators,
      focusNode: _focusNode,
      saveValueOnDestroy: widget.saveValueOnDestroy,
      onChanged: (value, isInternalUpdate) {
        widget.onChanged?.call(value ?? "");
        if (!isInternalUpdate) {
          _controller.text = value ?? "";
        }
      },
      onInitialized: () {
        _controller.text = context.justForm.field(widget.name)?.value ?? '';
      },
      builder: (context, state) {
        return TextFormField(
          controller: _controller,
          onChanged: (value) {
            state.setValue(value);
          },
          forceErrorText: state.error,
          groupId: widget.groupId,
          focusNode: _focusNode,
          decoration: state.getAttribute('decoration') ?? widget.decoration,
          keyboardType:
              state.getAttribute('keyboardType') ?? widget.keyboardType,
          textInputAction:
              state.getAttribute('textInputAction') ?? widget.textInputAction,
          textCapitalization:
              state.getAttribute('textCapitalization') ??
              widget.textCapitalization,
          style: state.getAttribute('style') ?? widget.style,
          strutStyle: state.getAttribute('strutStyle') ?? widget.strutStyle,
          textAlign: state.getAttribute('textAlign') ?? widget.textAlign,
          textAlignVertical:
              state.getAttribute('textAlignVertical') ??
              widget.textAlignVertical,
          textDirection:
              state.getAttribute('textDirection') ?? widget.textDirection,
          readOnly: state.getAttribute('readOnly') ?? widget.readOnly,
          showCursor: state.getAttribute('showCursor') ?? widget.showCursor,
          autofocus: state.getAttribute('autofocus') ?? widget.autofocus,
          obscuringCharacter:
              state.getAttribute('obscuringCharacter') ??
              widget.obscuringCharacter,
          obscureText: state.getAttribute('obscureText') ?? widget.obscureText,
          autocorrect: state.getAttribute('autocorrect') ?? widget.autocorrect,
          smartDashesType:
              state.getAttribute('smartDashesType') ?? widget.smartDashesType,
          smartQuotesType:
              state.getAttribute('smartQuotesType') ?? widget.smartQuotesType,
          enableSuggestions:
              state.getAttribute('enableSuggestions') ??
              widget.enableSuggestions,
          maxLines: state.getAttribute('maxLines') ?? widget.maxLines,
          minLines: state.getAttribute('minLines') ?? widget.minLines,
          expands: state.getAttribute('expands') ?? widget.expands,
          maxLength: state.getAttribute('maxLength') ?? widget.maxLength,
          maxLengthEnforcement:
              state.getAttribute('maxLengthEnforcement') ??
              widget.maxLengthEnforcement,
          onEditingComplete:
              state.getAttribute('onEditingComplete') ??
              widget.onEditingComplete,
          onAppPrivateCommand:
              state.getAttribute('onAppPrivateCommand') ??
              widget.onAppPrivateCommand,
          inputFormatters:
              state.getAttribute('inputFormatters') ?? widget.inputFormatters,
          enabled: state.getAttribute('enabled') ?? widget.enabled,
          ignorePointers:
              state.getAttribute('ignorePointers') ?? widget.ignorePointers,
          cursorWidth: state.getAttribute('cursorWidth') ?? widget.cursorWidth,
          cursorHeight:
              state.getAttribute('cursorHeight') ?? widget.cursorHeight,
          cursorRadius:
              state.getAttribute('cursorRadius') ?? widget.cursorRadius,
          cursorOpacityAnimates:
              state.getAttribute('cursorOpacityAnimates') ??
              widget.cursorOpacityAnimates,
          cursorColor: state.getAttribute('cursorColor') ?? widget.cursorColor,
          cursorErrorColor:
              state.getAttribute('cursorErrorColor') ?? widget.cursorErrorColor,
          selectionHeightStyle:
              state.getAttribute('selectionHeightStyle') ??
              widget.selectionHeightStyle,
          selectionWidthStyle:
              state.getAttribute('selectionWidthStyle') ??
              widget.selectionWidthStyle,
          keyboardAppearance:
              state.getAttribute('keyboardAppearance') ??
              widget.keyboardAppearance,
          scrollPadding:
              state.getAttribute('scrollPadding') ?? widget.scrollPadding,
          dragStartBehavior:
              state.getAttribute('dragStartBehavior') ??
              widget.dragStartBehavior,
          enableInteractiveSelection:
              state.getAttribute('enableInteractiveSelection') ??
              widget.enableInteractiveSelection,
          selectAllOnFocus:
              state.getAttribute('selectAllOnFocus') ?? widget.selectAllOnFocus,
          selectionControls:
              state.getAttribute('selectionControls') ??
              widget.selectionControls,
          onTap: widget.onTap,
          onTapAlwaysCalled: widget.onTapAlwaysCalled,
          onTapOutside: widget.onTapOutside,
          onTapUpOutside: widget.onTapUpOutside,
          mouseCursor: state.getAttribute('mouseCursor') ?? widget.mouseCursor,
          buildCounter:
              state.getAttribute('buildCounter') ?? widget.buildCounter,
          scrollController: widget.scrollController,
          scrollPhysics:
              state.getAttribute('scrollPhysics') ?? widget.scrollPhysics,
          autofillHints:
              state.getAttribute('autofillHints') ?? widget.autofillHints,
          contentInsertionConfiguration:
              state.getAttribute('contentInsertionConfiguration') ??
              widget.contentInsertionConfiguration,
          clipBehavior:
              state.getAttribute('clipBehavior') ?? widget.clipBehavior,
          restorationId:
              state.getAttribute('restorationId') ?? widget.restorationId,
          stylusHandwritingEnabled:
              state.getAttribute('stylusHandwritingEnabled') ??
              widget.stylusHandwritingEnabled,
          enableIMEPersonalizedLearning:
              state.getAttribute('enableIMEPersonalizedLearning') ??
              widget.enableIMEPersonalizedLearning,
          contextMenuBuilder:
              state.getAttribute('contextMenuBuilder') ??
              widget.contextMenuBuilder,
          canRequestFocus:
              state.getAttribute('canRequestFocus') ?? widget.canRequestFocus,
          spellCheckConfiguration:
              state.getAttribute('spellCheckConfiguration') ??
              widget.spellCheckConfiguration,
          magnifierConfiguration:
              state.getAttribute('magnifierConfiguration') ??
              widget.magnifierConfiguration,
          hintLocales: state.getAttribute('hintLocales') ?? widget.hintLocales,
        );
      },
    );
  }
}
