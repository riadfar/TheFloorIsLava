import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/scenario/assumption_status.dart';
import '../../domain/entities/scenario/scenario_fields.dart';
import '../l10n/model_labels.dart';
import 'formatting_scope.dart';
import 'status_badge.dart';

/// One editable assumption.
///
/// The field commits a value only when what has been typed parses to a number,
/// so a half-typed "3." never reaches the model. Because the committed value
/// lives in the scenario rather than in this widget, nothing is lost when the
/// screen is rebuilt - including on a rotation.
class AssumptionField extends StatefulWidget {
  const AssumptionField({
    required this.field,
    required this.value,
    required this.onChanged,
    this.status,
    this.onStatusChanged,
    this.errorText,
    this.helpText,
    this.currencyPrefix,
    super.key,
  });

  final ScenarioField field;
  final num value;
  final ValueChanged<num> onChanged;

  /// How much the value can be trusted. Hidden when null.
  final AssumptionStatus? status;
  final ValueChanged<AssumptionStatus>? onStatusChanged;

  final String? errorText;
  final String? helpText;

  /// Currency symbol shown inside money fields.
  final String? currencyPrefix;

  @override
  State<AssumptionField> createState() => _AssumptionFieldState();
}

class _AssumptionFieldState extends State<AssumptionField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _localError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.text.isEmpty) _controller.text = _formatted;
  }

  @override
  void didUpdateWidget(AssumptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only rewrite the text when the model has moved somewhere the field is not
    // already showing; otherwise the caret would jump while typing.
    final typed = context.formatter.parseNumber(_controller.text);
    if (typed == null || (typed - widget.value).abs() > 1e-9) {
      if (!_focusNode.hasFocus || typed == null) {
        _controller.text = _formatted;
      }
    }
  }

  String get _formatted => context.formatter.forEditing(
    widget.value,
    maxDecimals: widget.field.decimals,
  );

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    // On leaving, tidy the text back to the committed value.
    setState(() {
      _localError = null;
      _controller.text = _formatted;
    });
  }

  void _onChanged(String text) {
    if (text.trim().isEmpty) {
      // An empty box is a value in transit, not a zero.
      setState(() => _localError = null);
      return;
    }

    final parsed = context.formatter.parseNumber(text);
    if (parsed == null) {
      setState(
        () => _localError = AppLocalizations.of(context).validationNotANumber,
      );
      return;
    }

    if (_localError != null) setState(() => _localError = null);
    widget.onChanged(widget.field.isInteger ? parsed.round() : parsed);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final label = l10n.assumptionLabel(widget.field.key);
    final unit = l10n.unitLabel(widget.field.unit);
    final error = widget.errorText ?? _localError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.status != null) ...[
              const SizedBox(width: AppSpacing.sm),
              _StatusControl(
                status: widget.status!,
                onChanged: widget.onStatusChanged,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.numberWithOptions(
            decimal: !widget.field.isInteger,
            signed: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              widget.field.isInteger ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
            ),
          ],
          style: AppTheme.tabular(theme.textTheme.bodyLarge!),
          decoration: InputDecoration(
            prefixText: widget.field.unit == FieldUnit.money
                ? widget.currencyPrefix
                : null,
            suffixText: unit,
            errorText: error,
            helperText: error == null ? widget.helpText : null,
            helperMaxLines: 3,
            errorMaxLines: 3,
          ),
        ),
      ],
    );
  }
}

/// Lets the user record how firm an assumption is.
class _StatusControl extends StatelessWidget {
  const _StatusControl({required this.status, this.onChanged});

  final AssumptionStatus status;
  final ValueChanged<AssumptionStatus>? onChanged;

  @override
  Widget build(BuildContext context) {
    final badge = StatusBadge(status: status, dense: true);
    if (onChanged == null) return badge;

    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<AssumptionStatus>(
      tooltip: l10n.statusSectionTitle,
      onSelected: onChanged,
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        for (final value in AssumptionStatus.values)
          PopupMenuItem(
            value: value,
            child: Row(
              children: [
                StatusBadge(status: value, dense: true),
                const SizedBox(width: AppSpacing.sm),
                if (value == status)
                  const Icon(Icons.check, size: 16)
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
      ],
      child: badge,
    );
  }
}
