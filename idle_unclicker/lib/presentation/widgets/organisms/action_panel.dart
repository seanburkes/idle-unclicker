import 'package:flutter/material.dart';
import '../atoms/game_button.dart';

class ActionPanel extends StatelessWidget {
  final List<ActionButton> actions;
  final Axis direction;
  final double spacing;

  const ActionPanel({
    super.key,
    required this.actions,
    this.direction = Axis.horizontal,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      spacing: spacing,
      runSpacing: spacing,
      children: actions
          .map((action) => _ActionButtonWidget(action: action))
          .toList(),
    );
  }
}

class ActionButton {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GameButtonVariant variant;
  final bool isEnabled;

  const ActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GameButtonVariant.primary,
    this.isEnabled = true,
  });
}

class _ActionButtonWidget extends StatelessWidget {
  final ActionButton action;

  const _ActionButtonWidget({required this.action});

  @override
  Widget build(BuildContext context) {
    if (action.icon != null) {
      return GameButton.icon(
        icon: action.icon!,
        onPressed: action.isEnabled ? action.onPressed ?? () {} : () {},
      );
    }

    return GameButton(
      label: action.label,
      variant: action.variant,
      onPressed: action.isEnabled ? action.onPressed ?? () {} : () {},
    );
  }
}
