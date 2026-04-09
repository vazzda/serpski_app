import 'package:flutter/widgets.dart';

import '../../../app/layout/vessel_layout.dart';

/// Standardised spacing widget replacing raw [SizedBox] gaps.
///
/// Vertical (default): use in [Column], [ListView], etc.
/// Horizontal: prefixed with `h` — use in [Row].
class VesselGap extends StatelessWidget {
  final double _size;
  final bool _horizontal;

  // ── Vertical ──────────────────────────────────────────────────────────────
  const VesselGap.xxs({super.key})
      : _size = VesselLayout.gapXxs,
        _horizontal = false;
  const VesselGap.xs({super.key})
      : _size = VesselLayout.gapXs,
        _horizontal = false;
  const VesselGap.s({super.key})
      : _size = VesselLayout.gapS,
        _horizontal = false;
  const VesselGap.m({super.key})
      : _size = VesselLayout.gapM,
        _horizontal = false;
  const VesselGap.l({super.key})
      : _size = VesselLayout.gapL,
        _horizontal = false;
  const VesselGap.xl({super.key})
      : _size = VesselLayout.gapXl,
        _horizontal = false;
  const VesselGap.xxl({super.key})
      : _size = VesselLayout.gapXxl,
        _horizontal = false;

  // ── Horizontal ────────────────────────────────────────────────────────────
  const VesselGap.hxxs({super.key})
      : _size = VesselLayout.gapXxs,
        _horizontal = true;
  const VesselGap.hxs({super.key})
      : _size = VesselLayout.gapXs,
        _horizontal = true;
  const VesselGap.hs({super.key})
      : _size = VesselLayout.gapS,
        _horizontal = true;
  const VesselGap.hm({super.key})
      : _size = VesselLayout.gapM,
        _horizontal = true;
  const VesselGap.hl({super.key})
      : _size = VesselLayout.gapL,
        _horizontal = true;
  const VesselGap.hxl({super.key})
      : _size = VesselLayout.gapXl,
        _horizontal = true;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: _horizontal ? 0 : _size,
        width: _horizontal ? _size : 0,
      );
}
