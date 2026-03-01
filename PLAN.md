# Vessel Rename Plan

Rename the design system from "App/Project" to "Vessel".

## Phase 1 — Design system core

Class and file renames:

| Current class | Vessel class | File rename |
|---|---|---|
| `AppFontStyles` | `VesselFonts` | `app_font_styles.dart` → `vessel_fonts.dart` |
| `AppLayout` | `VesselLayout` | `app_layout.dart` → `vessel_layout.dart` |
| `AppThemeData` | `VesselThemeData` | `app_themes.dart` → `vessel_themes.dart` |
| `AppThemes` | `VesselThemes` | (same file as above) |
| `AppThemeDataExtension` | `VesselThemeDataExtension` | (same file as above) |

`AppTheme` enum stays — just an identifier (`theme01`, `theme02`...), not a design system API.

Impact: ~315 references across ~50 files.

Steps:
- [ ] Rename 3 files via `mv`
- [ ] Replace class names inside each renamed file
- [ ] Update all imports across the codebase
- [ ] Update exports in vessel_themes.dart
- [ ] `dart analyze` — 0 errors

## Phase 2 — Controls

### Widgets (file + class renames)

| Current file | Vessel file | Classes renamed |
|---|---|---|
| `project_card.dart` | `vessel_card.dart` | `ProjectCard` → `VesselCard`, `ProjectAttentionCard` → `VesselAttentionCard` |
| `project_gap.dart` | `vessel_gap.dart` | `ProjectGap` → `VesselGap` |
| `project_tile.dart` | `vessel_tile.dart` | `ProjectTile` → `VesselTile` |
| `project_note.dart` | `vessel_note.dart` | `ProjectNote` → `VesselNote` |
| `project_header.dart` | `vessel_header.dart` | `ProjectHeader` → `VesselHeader` |
| `project_divider.dart` | `vessel_divider.dart` | `ProjectDivider` → `VesselDivider` |
| `project_progress_bar.dart` | `vessel_progress_bar.dart` | `ProjectProgressBar` → `VesselProgressBar`, `ProgressBarMode` → `VesselProgressBarMode` |
| `project_snackbar.dart` | `vessel_snackbar.dart` | `ProjectSnackBar` → `VesselSnackBar` |
| `project_text_input.dart` | `vessel_text_input.dart` | `ProjectTextInput` → `VesselTextInput` |
| `project_buttons.dart` | `vessel_buttons.dart` | `BaseButton` → `VesselButton`, `AccentButton` → `VesselAccentButton`, `DangerButton` → `VesselDangerButton`, `ProjectTextButton` → `VesselTextButton`, `AccentTextButton` → `VesselAccentTextButton`, `DangerTextButton` → `VesselDangerTextButton`, `ButtonSize` → `VesselButtonSize`, `LabelPosition` → `VesselLabelPosition` |
| `project_button_group.dart` | `vessel_button_group.dart` | `ProjectButtonGroup` → `VesselButtonGroup`, `ProjectButtonGroupItem` → `VesselButtonGroupItem` |
| `project_button_styles.dart` | `vessel_button_styles.dart` | `ProjectButtonColors` → `VesselButtonColors`, `ProjectButtonStyleResolver` → `VesselButtonStyleResolver` |
| `project_input_styles.dart` | `vessel_input_styles.dart` | `ProjectInputStyles` → `VesselInputStyles` |
| `project_input_row.dart` | `vessel_input_row.dart` | `ProjectInputRow` → `VesselInputRow`, `ProjectInputRowField` → `VesselInputRowField` |
| `project_radio_tile.dart` | `vessel_radio_tile.dart` | `ProjectRadioTile` → `VesselRadioTile` |
| `project_radio_grid.dart` | `vessel_radio_grid.dart` | `ProjectRadioGrid` → `VesselRadioGrid`, `ProjectRadioGridOption` → `VesselRadioGridOption` |
| `project_date_picker.dart` | `vessel_date_picker.dart` | `ProjectDatePicker` → `VesselDatePicker` |
| `project_hour_picker.dart` | `vessel_hour_picker.dart` | `ProjectHourPicker` → `VesselHourPicker` |
| `project_slider_input.dart` | `vessel_slider_input.dart` | `ProjectSliderInput` → `VesselSliderInput`, `SliderInputMode` → `VesselSliderInputMode` |
| `project_time_slider.dart` | `vessel_time_slider.dart` | `ProjectTimeSlider` → `VesselTimeSlider` |
| `project_toggles.dart` | `vessel_toggles.dart` | `ProjectCheckbox` → `VesselCheckbox`, `ProjectCheckboxLabeled` → `VesselCheckboxLabeled`, `ProjectSwitch` → `VesselSwitch`, `ProjectSwitchLabeled` → `VesselSwitchLabeled` |
| `project_lang_button.dart` | `vessel_lang_button.dart` | `ProjectLangButton` → `VesselLangButton` |
| `project_bottom_sheet.dart` | `vessel_bottom_sheet.dart` | `showProjectBottomSheet` → `showVesselBottomSheet` |
| `screen_layout_widget.dart` | `vessel_scaffold.dart` | `ScreenLayoutWidget` → `VesselScaffold` |
| `tag_chip.dart` | `vessel_tag_chip.dart` | `TagChip` → `VesselTagChip`, `TagColorPreview` → `VesselTagColorPreview` |
| `tag_label.dart` | `vessel_tag_label.dart` | `TagLabel` → `VesselTagLabel`, `TagLabelSize` → `VesselTagLabelSize` |

### Navbar internals

| Current file | Vessel file | Classes renamed |
|---|---|---|
| `bottom_navbar_widget.dart` | `vessel_navbar.dart` | `BottomNavBarWidget` → `VesselNavBar` |
| `navbar_icon_button.dart` | `vessel_navbar_icon.dart` | `NavBarIconButton` → `VesselNavBarIcon` |

Steps:
- [ ] Rename all files via `mv`
- [ ] Replace all class/function names inside each file
- [ ] Update all imports across the codebase
- [ ] `dart analyze` — 0 errors

## Phase 3 — CLAUDE.md

Replace the 5 scattered design rules with one **Vessel Design System** section. Same restrictions, explicit and direct — just grouped under one roof.

Structure:

```
### Vessel Design System

All visual code goes through Vessel. Six layers, each with explicit restrictions.

**Theme** (`VesselThemes.of(context)` → `VesselThemeData`)
- NEVER hardcode color values (hex, RGB, `.withOpacity()`, `Color(0x...)`)
- ALWAYS use `VesselThemeData` properties via `VesselThemes.of(context)`
- If a needed color doesn't exist, propose adding it to `VesselThemeData` first
- Definitions: `lib/app/theme/vessel_themes.dart`
- Instances: `lib/app/theme/themes/theme01_theme.dart` etc.

**Fonts** (`VesselFonts`)
- NEVER hardcode font size, weight, family, or letter spacing in widget code
- ALWAYS use `VesselFonts` styles (e.g. `VesselFonts.textBody`, `VesselFonts.textSheetTitle`)
- Only allowed inline modification: `.copyWith(color: ...)` for theming and `.toUpperCase()` on the string itself
- If a needed style doesn't exist, first add it to `VesselFonts`, then use it
- File: `lib/app/theme/vessel_fonts.dart`

**Layout** (`VesselLayout`, `VesselGap`)
- NEVER hardcode heights, widths, paddings, gaps, or spacing values in widget code
- All dimensions live in `VesselLayout`
- All spacing between widgets uses `VesselGap` (not raw `SizedBox`)
- Tiers: xxs(2), xs(4), s(8), m(12), l(16), xl(24), xxl(48). Vertical: `VesselGap.s()`. Horizontal: `VesselGap.hs()`
- Files: `lib/app/layout/vessel_layout.dart`, `lib/shared/ui/gap/vessel_gap.dart`

**Controls** (`Vessel*` widgets in `lib/shared/ui/`)
- NEVER use raw Material/Flutter widgets directly in screens
- ALWAYS use Vessel controls from `lib/shared/ui/`
- If a needed control doesn't exist, first create it as a Vessel control, then use it
- NEVER inline/hardcode a control inside a widget unless explicitly discussed
- NEVER pass ad-hoc overrides (iconSize, padding, margin, etc.) to bypass a control's built-in sizing — add a proper variant to the control itself
- Every Vessel control MUST have a showcase entry on the dev screen (`controls_list_screen.dart`)

When adding a new Vessel control:
1. Add any required sizing/radius/color properties to `VesselThemeData` first, then to all theme files
2. The control uses only `VesselThemeData` properties — zero hardcoded values
3. Add the control to the inventory below
4. Name: `Vessel` prefix + the UI concept (not the Flutter widget name). `VesselProgressBar` not `VesselLinearIndicator`
5. Folder: `lib/shared/ui/<concept>/` matching the control name
6. Add showcase to dev screen

Controls inventory:
- **Buttons**: `VesselButton`, `VesselAccentButton`, `VesselDangerButton`, `VesselTextButton`, `VesselAccentTextButton`, `VesselDangerTextButton`
- **Button groups**: `VesselButtonGroup`
- **Cards**: `VesselCard`, `VesselAttentionCard`
- **Gaps**: `VesselGap`
- **Text input**: `VesselTextInput`
- **Tiles**: `VesselTile`
- **Progress bar**: `VesselProgressBar`
- **Bottom sheets**: `showVesselBottomSheet()`
- **Navigation**: `VesselScaffold`
- **Toggles**: `VesselCheckbox`, `VesselSwitch` (+ labeled variants)
- **Radio**: `VesselRadioTile`, `VesselRadioGrid`
- **Sliders**: `VesselSliderInput`, `VesselTimeSlider`
- **Pickers**: `VesselDatePicker`, `VesselHourPicker`
- **Divider**: `VesselDivider`
- **Header**: `VesselHeader`
- **Note**: `VesselNote`
- **Snackbar**: `VesselSnackBar`
- **Tags**: `VesselTagChip`, `VesselTagLabel`
- **Lang button**: `VesselLangButton`

**Copy** (`AppLocalizations`)
- NEVER hardcode user-facing text — ALWAYS use `AppLocalizations` (accessed as `l10n`)
- If a needed string doesn't exist, first add it to `lib/l10n/app_en.arb`, then use it
- Key naming convention: `section_descriptiveName` (e.g. `session_exitConfirm`, `common_cancel`)
- Parameterized strings use `{placeholder}` syntax with `@key` metadata block
```

Steps:
- [ ] Delete the 5 old sections: "No hardcoded colors", "No hardcoded font styles", "No raw Material controls", "No hardcoded text strings", and implicit layout rules
- [ ] Add the single "Vessel Design System" section with all restrictions preserved
- [ ] Update all class/file references to Vessel names
- [ ] Verify no rule was lost compared to original

## Not renamed (intentional)

- `AppTheme` enum — just an identifier (`theme01`...), not design API
- `AppLocalizations` — Flutter framework, not ours
- `quiz_bottom_sheets.dart` — feature-specific, uses Vessel controls internally
- `ModeSelection`, `Tag`, `TagColor` — domain models, not controls
- Theme instance files (`theme01_theme.dart` etc.) — content inside will use VesselThemeData, filenames are fine

## Execution notes

- Do one phase at a time, `dart analyze` between phases
- File renames via `mv`, then read renamed files, then edit class names
- Use `replace_all` for class renames within files
- Use grep to find all import consumers, update each
- Do NOT use `flutter build` — only `dart analyze` and `flutter gen-l10n` if ARB keys change
