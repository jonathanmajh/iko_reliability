# Plan: PM Extract — reverse of PM Check (Maximo → app)

## Goal
Reverse the flow of the PM Verify and Upload page (`lib/admin/pm_check.dart`).
Instead of loading PM templates from Excel and uploading them to Maximo, the user
enters a list of **PM numbers + site IDs** and the app **extracts the existing
PMs from Maximo**, displays them in full detail, exports them to Excel, and can
best-effort populate the existing template editor.

## Verified Maximo API (TEST2 8.11, apikey auth, `lean=1`)
Base: `https://test2.manage.test2.iko.max-it-eam.com/maximo/api/os/`

- PM header: `iko_pm?oslc.select=<fields>&oslc.where=pmnum="X"%20and%20siteid="S"` → 200
  - Fields seen: `pmnum, siteid, description, jpnum, wostatus, persongroup,
    frequency, frequnit, pmassetwogen, assetnum, route, leadtime, priority,
    nextdate, orgid, targstarttime, iko_pmhistorynotes, iko_fmeca, status, usefrequency, <weekday flags>`
- Job plan: `iko_jobplan?oslc.select=*&oslc.where=jpnum="JP"` → header incl.
  `iko_conditions, iko_worktype, templatetype, jpduration, priority, persongroup, orgid, status, pluscrevnum`
- JP children: `iko_jobtask` / `iko_joblabor` / `iko_jobmaterial` / `iko_jobservice`
  queried by `jpnum="JP"` → returns the JP record with the **nested collection**
  (`jobtask` array with `description_longdescription`, `joblabor` array with craft/qty/hours)
- Route: `iko_route` and `iko_route_stop` by `route="R"%20and%20siteid="S"`
  → `iko_route_stop` returns nested `route_stop` array
- **Batched query works**: `(pmnum="A" and siteid="S1") or (pmnum="B" and siteid="S2")`
  returns both in one request. `in {...}` syntax is NOT supported (BMXAA8744E).
- Auth: `maximoRequest()` in `lib/admin/upload_maximo.dart` already handles the
  `apikey` header from stored login settings (`<env>-APIKEY`). No code change
  needed; the API key is entered in the app login settings for the env.

## Decisions (confirmed with user)
1. **Input**: Both — lines may carry their own site ID (`AA A0001D1INRE`), and a
   site dropdown is the fallback for lines with only a PM number.
2. **Output**: View + export to Excel first; best-effort populate the existing
   template editor afterwards (some manual edits in Maximo are not compatible
   with the template format).
3. **Fetch depth**: Full detail — PM header + JP (tasks, labor, materials,
   services) + route + stops.
4. **Placement**: New admin page "PM Extract" at `/pm/extract`.

## Files
| Action | File | Contents |
|---|---|---|
| Create | `lib/admin/pm_extract.dart` | Page UI: input section, pair list + detail panes, FABs (Fetch / Export / Clear) |
| Create | `lib/admin/extract_maximo.dart` | Input parsing, batched Maximo GETs, JSON→model mapping, Excel export |
| Create | `lib/admin/extract_notifier.dart` | `ExtractNotifier` state (mirrors `TemplateNotifier` pattern) |
| Modify | `lib/routes/route.dart` | Add `AutoRoute(path: "/pm/extract", ...)` + build_runner regen |
| Modify | `lib/bin/drawer.dart` | "PM Extract" entry under Maximo Admin |

## Implementation steps
1. **Input ("Both" mode)**
   - Multi-line text field; per line, tokens split on whitespace/comma/semicolon.
   - A token matching a key of `siteIDAndOrgID` = site; the other token = PM number.
   - Lines without a site use the selected site dropdown.
   - Optional drag-drop of `.txt`/`.csv` with the same line format (DropRegion).
   - Invalid lines (unknown site, missing PM) reported, not silently dropped.
2. **Fetch**
   - Batch pairs ~20/request into grouped-OR OSLC queries on `iko_pm`.
   - Pairs not returned are marked "Not Found".
   - Per found PM: fetch JP + nested children, and route/route_stop when set.
   - All GETs via existing `maximoRequest()`; results stream into the notifier
     so the list populates progressively.
3. **Display**
   - Left pane: one row per entered pair — status (fetching/extracted/not
     found/error) + PM description once loaded (reuse `pm_widgets.dart` styling).
   - Right pane: tabs — *PM* (header fields mirroring `tableHeaders['PM']`),
     *Job Plan* (header + tasks incl. long descriptions + labor/materials/services),
     *Route* (+ stops) when present.
4. **Export to Excel**
   - `getSaveLocation()` (file_selector, same as `criticality_db_export_import.dart`).
   - Workbook sheets: `PM`, `JobPlan`, `Tasks`, `Labor`, `Materials`, `Services`,
     `Route`, `Route Stops` — one row per record.
5. **Best-effort template round-trip**
   - Map fetched data → `ParsedTemplate` (frequency/freqUnit,
     iko_worktype→workOrderType, iko_conditions→processCondition, labor crafts,
     tasks/materials/services, assetnum→pmAsset, route code/name,
     description→pmName) and insert via `TemplateNotifier.setParsedTemplate()`.
   - Non-reversible bits (HTML long-description formatting, generated name
     fields) produce a warning status message on the template.
6. **Verification**
   - Each GET exercised against TEST2 with the provided test API key before
     wiring into the UI.

## Out of scope
- Uploading anything back to Maximo from the new page (existing PM Check page
  remains the upload path).
- Editing of fetched records.

## Addendum - feedback round 1 (PM Extract)
1. **Stop job plans are now extracted.** Route stops hold jpnum links to child
   job plans; these are fetched in batches and kept in
   ExtractStore.stopJobPlans (FetchedJobPlan with nested jobtask /
   joblabor / jobmaterial / jobservice arrays). OSLC grouped-OR batching on
   jobplan objects requires one pair of parentheses per value
   \(jpnum=\"A\") or (jpnum=\"B\")\ - bare \jpnum=\"A\" or jpnum=\"B\"\ and shared
   parens fail with BMXAA8744E on iko_jobplan (grouped pairs with \nd\
   inside parens remain valid on iko_pm). Stops are sorted by stopsequence.
2. **Stop sheets in the Excel export:** 'Stop JobPlan', 'Stop Tasks',
   'Stop Labor', 'Stop Materials', 'Stop Services' (deduped across PMs).
3. **New 'Import' button** exports all extracted PMs to a 'Main' sheet in the
   same layout as the PM import template, so the file can be re-loaded by the
   PM Check page. Layout constraints discovered (parse_template.fromExcel):
   PM header row -> detail row -> number row, then 'Craft @ (Optional)
   Labour Code' row (this row is what enables BOTH task and craft reading;
   tasks must appear after it), craft rows, task rows (col 4 asset, 5 meter,
   6 jptask, 7 description, 8 longdescription; null cells required for
   'no asset' main-JP tasks), optional 'Route Assets (one per cell):' rows
   for stops without a job plan, 'Materials (Mapics Number)' rows
   (item/qty/cost) and 'Services (Mapics Number)' rows (item/cost/vendor).
   Round-trip validated against TEST2 data through the real
   ParsedTemplate.fromExcel.
4. **Meter names:** Maximo stores generated meter numbers (e.g. LNWK01);
   the template stores the meter 'inspect' value. Meter names are mapped
   back via the local meter DB (strip trailing digits -> code -> inspect).
5. **Route tab** now shows each stop's linked job plan description.

## Addendum 2 — feedback round 2 (blank request template as base)

User feedback after trying the import-template export:
1. Base the export on the blank request template saved at repo root
   (`PM Request Template.xlsm`): keep the 'Main' sheet formatting and row
   layout, VBA not needed.
2. The template's 'Route:' dropdown (None / Task / Child) was missed.
3. `GS C8025LUBM001` has child job plans with MULTIPLE tasks but only one
   task row was written.
4. The viewer does not show the job plans linked to route stops.

Template layout facts (verified against the .xlsm):
- `Main` rows 0-5 = 'DON'T REMOVE THIS LINE' (once, at the top). The first
  PM block lives in rows 6-21: label row 6, data row 7, number row 8, blank
  9, section labels 10, craft header 11, content 12-21. Every further PM
  block repeats the same 16-row form (the template's `Template Copy` sheet,
  without the DON'T REMOVE rows), starting past row 21.
- Data row (7): col 0 asset, **col 1 route type** ('None'/'Task'/'Child' -
  Option List col 5-6 dropdown), col 2 next due date, col 3 site, col 4
  frequency word ('Days'...), col 5 frequency, col 6 work type option
  ('INR (Routine Inspection)'), col 7 condition option ('CR01 (Running)'),
  col 8 PM name, col 9 route NAME (or 'Select Route (Optional)').
- Number row (8): col 8 PM number, col 9 route CODE (template has an
  XLOOKUP formula there; the export overwrites it with the literal code
  because the parser reads the cell value, not the formula result).
- Craft header (11) 'Craft @ (Optional) Labour Code' enables task/craft
  reading. Content rows: labour = col 0 'ELECT: E' style option (or
  'ELECT@code'), col 1 qty, col 2 hours (Hours cell must be non-null -
  parser's parseTime throws on null); tasks = col 4 asset, col 5 meter
  inspect value, col 6 jptask, col 7 desc, col 8 longdesc; first task row
  carries the 'Task Route Assets (one per cell):' marker in col 3 (PM1:
  the template's own marker on row 12 is reused); plain stops get asset
  rows in col 3. Parser checks: task check runs BEFORE the materials
  header check; marker check has no `continue`; parse throws on any row
  error, so cells must never hold short/empty strings where the parser
  calls substring (fallbacks write the template's own unfilled dropdown
  texts, e.g. 'Select Work Order').
- Dropdown values are matched against the template's 'Option List' sheet
  ('INR (Routine Inspection)', 'PROD: O', 'CR01 (Running)', route names)
  so the workbook lookups stay valid.

Implementation:
- Template bundled as asset `assets/PM Request Template.xlsm` (pubspec).
- New pure-Dart module `lib/admin/extract_import_template.dart`:
  `buildImportTemplateWorkbook(stores, templateBytes, resolveMeter)` -
  loads the template via excel_plus, writes PM1 into the template block
  and later PMs as repeated form blocks, clones cell styles from
  'Template Copy' for appended rows, overwrites the J9 formula with the
  route code, and CLEARS (style-preserving) any default template cells in
  rows 12-21 that PM data did not overwrite (per-cell tracking - leftover
  default text mid-block would corrupt the parse).
  Route type: Maximo `ROUTESTOPSBECOME` ('CHILD'/'TASK') -> 'Child'/'Task',
  computed from stop jpnums as fallback, 'None' without route.
- ALL tasks of each stop's child job plan are written (multi-task fix,
  feedback 3) - also in `populateTemplateFromExtract` for the editor
  round trip (generatePM groups tasks per stop asset into one child JP).
- `lib/admin/extract_store.dart` (pure Dart) now holds ExtractStore +
  FetchedJobPlan; extract_notifier re-exports it; fieldOf/rowValue/
  stripHtml moved to `lib/bin/consts.dart` so the builder module stays
  Flutter-free.

## Addendum 3 - generate the request workbook from scratch (corrupt fix)
User feedback round 3 (2026-10-19): Excel reported the exported file as
corrupt. The excel_plus decode -> edit -> re-encode round trip of the heavy
.xlsm template produced a package Excel refuses to open (25k-row sheets,
validations, VBA relationships get re-written by the lib).

Fix:
- The import-template export now generates a BRAND-NEW workbook via
  `Excel.createExcel()` (single 'Main' sheet) that reproduces the template's
  layout and look: rows 0-5 'DON'T REMOVE THIS LINE', identical row numbers
  (first block 6-21, drafting errors keep them for later blocks), gray
  bold label rows (D9D9D9), pale green dropdown cells (EBF1DE), pale yellow
  route cells (FFEB9C with brown font 9C6500), thin borders, and the
  template's right-side notes (PM Options, Safety Device (Y/N),
  Urgency Level (1-4), IKO PM History Notes).
- Option strings (work types, crafts, conditions) are hardcoded in
  `templateOptions()` (previously read from the template's Option List).
- `assets/PM Request Template.xlsm` is no longer bundled (removed from
  pubspec and disk); the repo-root template remains the user's reference.
- The route-asset marker is now written on the first task row of each PM
  (the template no longer supplies one); cleanup of template defaults is
  gone since there are no defaults.
- Test no longer reads the template: it builds + parses purely from scratch
  and also asserts the styling.

## Addendum 4 - round trip feedback (PM number at K8, fixed marker slot)
User feedback round 4 (2026-10-19, export PM_Request_20261019_153321.xlsx):
1. Importing the export into PM Check errored. Cause: the route CODE was
   written below the route name (J9) - generateName treats that cell as a
   NEW route's base code and does `int.parse(number.substring(3))` on
   'C8000INRM001' + counter -> FormatException per PM. The parser's PM
   number itself is never used downstream.
   Fix: the PM number is now written ONLY as a reference beside the PM
   name (K8 = data row col 10, with a 'PM Number' label at K7). The number
   row below (I9/J9) is left empty so no route code reaches the parser
   (routeCode null -> generateName takes the no-route-code branch and
   pm_check generates cleanly). parse_template reads the number from K8
   (guarded index) with the old I9 number row as fallback for manually
   filled templates.
2. The 'Task Route Assets (one per cell):' header now sits in its fixed
   form slot on the FIRST content row of every block (D13 of the first
   template, base+6) instead of riding on whichever row the content
   reached it. Written whenever the PM has route stops; asset rows get
   ingested correctly (the marker row itself is never ingested - the asset
   check runs before the flag is set on the same row).
- Import-template export output renamed `PM_Request_yyyyMMdd_HHmmss.xlsx`.
- Route tab rebuilt: one expandable card per stop showing the stop's job
  plan (jpnum/description) with its tasks, labour, materials and services
  (feedback 4).
- Round-trip test `test/extract_import_template_test.dart` (pure dart run)
  drives the real builder with the bundled template and parses the result
  with the real `ParsedTemplate.fromExcel`: sheet inventory intact, PM1/Pm2
  block layout, option strings, all stop tasks present, no leftover
  template defaults, full data round trip. ALL CHECKS PASSED.
- NOTE: the TEST2 API key started returning 403 BMXAA7901E (login
  restricted) mid-session, so the `GS C8025LUBM001` structure could not be
  verified live; the multi-task child-JP shape is covered by the test.
