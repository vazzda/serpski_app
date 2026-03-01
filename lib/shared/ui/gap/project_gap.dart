import 'package:flutter/widgets.dart';

import '../../../app/layout/app_layout.dart';

/// Standardised spacing widget replacing raw [SizedBox] gaps.
///
/// Vertical (default): use in [Column], [ListView], etc.
/// Horizontal: prefixed with `h` — use in [Row].
class ProjectGap extends StatelessWidget {
  final double _size;
  final bool _horizontal;

  // ── Vertical ──────────────────────────────────────────────────────────────
  const ProjectGap.xxs({super.key})
      : _size = AppLayout.gapXxs,
        _horizontal = false;
  const ProjectGap.xs({super.key})
      : _size = AppLayout.gapXs,
        _horizontal = false;
  const ProjectGap.s({super.key})
      : _size = AppLayout.gapS,
        _horizontal = false;
  const ProjectGap.m({super.key})
      : _size = AppLayout.gapM,
        _horizontal = false;
  const ProjectGap.l({super.key})
      : _size = AppLayout.gapL,
        _horizontal = false;
  const ProjectGap.xl({super.key})
      : _size = AppLayout.gapXl,
        _horizontal = false;
  const ProjectGap.xxl({super.key})
      : _size = AppLayout.gapXxl,
        _horizontal = false;

  // ── Horizontal ────────────────────────────────────────────────────────────
  const ProjectGap.hxxs({super.key})
      : _size = AppLayout.gapXxs,
        _horizontal = true;
  const ProjectGap.hxs({super.key})
      : _size = AppLayout.gapXs,
        _horizontal = true;
  const ProjectGap.hs({super.key})
      : _size = AppLayout.gapS,
        _horizontal = true;
  const ProjectGap.hm({super.key})
      : _size = AppLayout.gapM,
        _horizontal = true;
  const ProjectGap.hl({super.key})
      : _size = AppLayout.gapL,
        _horizontal = true;
  const ProjectGap.hxl({super.key})
      : _size = AppLayout.gapXl,
        _horizontal = true;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: _horizontal ? 0 : _size,
        width: _horizontal ? _size : 0,
      );
}
