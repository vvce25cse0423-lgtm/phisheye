import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

// ─── PhishEye Logo Widget ────────────────────────────────────────────────────

class PhishEyeLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const PhishEyeLogo({super.key, this.size = 48, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.bgElevated,
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(color: AppTheme.accentCyan, width: 1.5),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  color: AppTheme.accentCyan,
                  size: size * 0.55,
                ),
                Positioned(
                  bottom: size * 0.12,
                  child: Container(
                    width: size * 0.25,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PHISH',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentCyan,
                  letterSpacing: 2,
                  height: 1.1,
                ),
              ),
              Text(
                'EYE',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Risk Score Gauge ────────────────────────────────────────────────────────

class RiskGauge extends StatelessWidget {
  final int score;
  final double size;

  const RiskGauge({super.key, required this.score, this.size = 160});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(score);
    final label = AppTheme.riskLabel(score);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: AppTheme.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          // Inner content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms);
  }
}

// ─── Cyber Card ──────────────────────────────────────────────────────────────

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? AppTheme.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (borderColor ?? AppTheme.accentCyan).withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.accentCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Loading Overlay ─────────────────────────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: CyberCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                  strokeWidth: 2,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Scan Type Badge ─────────────────────────────────────────────────────────

class ScanTypeBadge extends StatelessWidget {
  final String type;

  const ScanTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isUrl = type == 'url';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isUrl
            ? AppTheme.accentCyan.withOpacity(0.12)
            : AppTheme.accentPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isUrl
              ? AppTheme.accentCyan.withOpacity(0.4)
              : AppTheme.accentPurple.withOpacity(0.4),
        ),
      ),
      child: Text(
        isUrl ? 'URL' : 'EMAIL',
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color:
              isUrl ? AppTheme.accentCyan : AppTheme.accentPurple,
        ),
      ),
    );
  }
}

// ─── Risk Badge ──────────────────────────────────────────────────────────────

class RiskBadge extends StatelessWidget {
  final int score;

  const RiskBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(score);
    final label = AppTheme.riskLabel(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: color,
        ),
      ),
    );
  }
}

// ─── Error Message ───────────────────────────────────────────────────────────

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      borderColor: AppTheme.accentRed.withOpacity(0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.accentRed, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.accentRed),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('RETRY'),
            ),
          ],
        ],
      ),
    );
  }
}
