# ERRORS_LOG.md: Bug & Fix Registry

> Record every non-trivial bug here immediately after fixing it. Include root cause and solution to prevent regressions.

---

## E-001: BoxConstraints negative width in CategoryGridSection

- **Date:** 2026-11-10
- **Symptoms:** Red screen of death: `BoxConstraints has a negative minimum width. BoxConstraints(w=-21.0, 0.0<=h<=Infinity; NOT NORMALIZED)`.
- **Root Cause:** In `CategoryGridSection`, the item width was calculated using global `MediaQuery.of(context).size.width` with hardcoded subtraction offsets rather than the actual parent widget constraints, resulting in invalid/negative layout dimensions during render passes on specific device pixel ratios/padding.
- **Solution:** Replaced `MediaQuery` sizing with `LayoutBuilder`, deriving item width dynamically from `constraints.maxWidth` with a non-negative guard (`itemWidth > 0 ? itemWidth : 120`).
- **Files Touched:** `lib/features/home/presentation/widgets/category_grid_section.dart`
- **Verified:** Passes `flutter analyze` and `flutter test`.
