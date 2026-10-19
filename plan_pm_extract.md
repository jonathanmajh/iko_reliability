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
