## Plan: Add PDF link-processing workflow to the Flutter app

The goal is to bring the PDF hyperlink workflow from the C# tool into the Flutter desktop app as an admin-facing feature, starting with Windows desktop support and a practical implementation path that uses the proposed PDF package as the core engine.

### Approach
1. Verify package feasibility first. Confirm that the selected PDF package can read PDFs, detect/edit hyperlink annotations or URI actions, and write modified files on Windows. If it cannot support the needed operations reliably, switch to a fallback strategy such as a separate desktop worker or a different package.
2. Add a new admin module for PDF processing. Create a dedicated screen under the admin section with controls for source selection, output folder, action type, and progress/logging.
3. Build a service layer for the workflow. Keep PDF parsing, link replacement, asset extraction, and CSV export in separate helpers so the UI stays thin and the logic is testable.
4. Implement the first milestone: local file/folder processing with three actions: replace links, extract DNA asset references, and export all discovered links.
5. Add Windows-friendly file handling and user feedback. Support selecting files/folders, showing progress, handling errors, and writing outputs to a chosen folder.
6. Verify with sample PDFs and add regression coverage for URL transformation and CSV output.

### Proposed implementation steps
1. Dependency and feasibility check
   - Add the PDF editing dependency to [pubspec.yaml](pubspec.yaml).
   - Validate that it supports the required operations on Windows desktop builds.
   - If the package is insufficient, document the fallback plan before implementation begins.

2. App integration
   - Add a new admin entry in [lib/bin/drawer.dart](lib/bin/drawer.dart) for a “PDF Link Tool” screen.
   - Create a new screen under [lib/admin](lib/admin) that follows the existing admin-page pattern used by the current app.
   - Wire the route into the app navigation structure used by [lib/home_page.dart](lib/home_page.dart) and [lib/routes/route.dart](lib/routes/route.dart).

3. Processing architecture
   - Add a dedicated service class for PDF processing with methods for:
     - collecting PDFs from user-selected files or folders,
     - scanning links/annotations,
     - replacing strings in matching URLs,
     - extracting asset numbers from URLs containing assetnum,
     - exporting discovered links to CSV.
   - Keep this logic separate from the UI so it can be reused and tested.

4. UI workflow
   - Add source selection controls: file picker, folder picker, and optional recursive folder mode.
   - Add output folder selection and action selection: replace links, DNA asset CSV, or export links.
   - Add a progress indicator and log area for each processed file.
   - Keep the screen admin-only, consistent with the existing access model.

5. CSV and output handling
   - Write CSV output using UTF-8 and a predictable file name.
   - Preserve original PDFs unless the user explicitly chooses overwrite mode.
   - Write all generated files into the selected output folder.

6. Validation and testing
   - Use sample PDFs with different hyperlink structures to verify that the package detects and edits links correctly.
   - Add unit tests for URL replacement rules and asset-number extraction logic.
   - Add widget tests for the new screen’s basic interaction and status states.

### Scope for first release
- Windows desktop support first.
- Local file and folder sources only.
- Three actions: replace links, extract DNA asset references, and export links.
- Admin-only access and clear progress/error reporting.

### Out of scope for the first release
- SharePoint drive mapping and network-based batch processing.
- Full support for every exotic PDF annotation type.
- Automatic cloud/site integration beyond the current app’s existing patterns.

### Verification plan
1. Run the app on Windows and confirm the new screen opens from the navigation menu.
2. Process a sample PDF set and verify that the output files are created correctly.
3. Confirm that the CSV contains the expected asset numbers and link inventory.
4. Check that the app handles malformed or unreadable PDFs without crashing.
