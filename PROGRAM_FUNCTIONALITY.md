# LinkReplacer-DNATool Functionality

## Overview

LinkReplacer-DNATool is a Windows desktop utility built with C# and Windows Forms. Its purpose is to inspect PDF documents, identify hyperlinks embedded inside them, and perform one of three main tasks:

- replace or modify hyperlink URLs inside PDFs,
- extract asset identifiers from certain PDF links for DNA reporting, or
- export all discovered hyperlinks from selected PDFs to CSV output.

The tool is designed for environments where PDFs contain clickable links to SharePoint or other web resources, and where users need to bulk-edit or audit those links.

---

## What the program does

### 1. Replaces hyperlinks inside PDF files

The main operation of the program is to scan each selected PDF, find hyperlink annotations, and modify their target URLs.

It supports three replacement modes:

1. Find and replace all
   - Replaces every occurrence of a search string with a replacement string.
   - Useful when the same URL fragment appears multiple times in a document.

2. Add to the beginning of matching URLs
   - Prepends a supplied prefix to any URL containing the search string.
   - Useful for adding a base domain or path before an existing value.

3. Add to the end of matching URLs
   - Appends a supplied suffix to any URL containing the search string.
   - Useful for adding additional parameters or path segments.

The program writes the modified PDFs to an output folder, preserving the original source files unless the user explicitly replaces them.

### 2. Extracts asset numbers for DNA reporting

The program can scan PDF links that contain a special asset identifier pattern. In particular, it looks for URLs containing the substring `assetnum` and extracts the following asset number from the URL.

For each matching link, the tool writes a row to a CSV file containing:

- the extracted asset number,
- the SharePoint site address,
- the PDF file name.

This makes it possible to generate a structured inventory of assets referenced by PDFs.

### 3. Exports all discovered hyperlinks to CSV

The program can also export every hyperlink it detects in selected PDFs to a CSV file. Each extracted link is stored with the corresponding file name so the user can review the complete set of links used in a document batch.

---

## Supported input sources

The application allows users to select PDF files from several sources:

### SharePoint source

If a SharePoint site is selected from the configured site list, the program:

- maps the site to a local drive letter (B:),
- reads the available PDF files from that mapped location,
- and processes them as a batch.

This is handled through Windows command-line network mapping using `net use`.

### Individual files

Users can manually select one or more PDF files from disk. The application loads those files into the processing list.

### Folder source

Users can point the program at a folder containing PDFs. The program can process either:

- only files in the top-level folder, or
- all PDF files in nested subfolders if recursive mode is enabled.

---

## User interface behavior

The application is arranged around a main form with several functional areas:

### Source selection

Users choose where the PDFs come from:

- SharePoint site
- individual files
- folder

The active panel changes depending on the selected source type.

### Output folder

Users can define a destination folder for generated files. When processing files, the program creates the output directory if it does not already exist.

### Find and replace options

When the replace-link mode is active, users enter:

- a string to find,
- a replacement string,
- and a modification mode.

### Site selection

For DNA tool and link export workflows, the user selects a configured site from a list loaded from `Sites.csv`. The site selection determines the site address used in exported CSV rows.

### Progress and logging

The tool shows a progress bar and a log window while processing files. Each processed file is logged, and errors are displayed in the log if a PDF cannot be read or processed.

---

## Processing workflow

### Step-by-step operation

1. The user selects one or more PDF files or a source location.
2. The application builds a list of PDF file paths for processing.
3. The user chooses an action:
   - replace links,
   - generate DNA asset CSV,
   - or export hyperlinks.
4. The program iterates through each PDF.
5. It inspects the PDF annotations and identifies hyperlink entries.
6. It performs the selected operation and writes output files.
7. The program updates the log and progress bar while processing continues.

---

## Technical implementation details

### PDF processing engine

The program uses the iTextSharp library to read and modify PDF annotations. It examines PDF annotation dictionaries and detects links by checking for:

- link annotations,
- widget annotations,
- URI actions.

This allows the tool to identify clickable hyperlink targets embedded in the PDF structure.

### CSV output

The application writes CSV output files using UTF-8 encoding. The CSV files are stored in the selected output folder and named according to the selected site or processing mode.

### Error handling

The program includes basic error handling for:

- missing files,
- unreadable PDFs,
- missing site configuration,
- and network mapping issues.

If a file cannot be processed, the log records an error message rather than stopping the entire batch immediately.

---

## Configuration requirements

### Required files

The program expects a file named `Sites.csv` to be present in the same directory as the executable. This file provides the site list used by the SharePoint and DNA tool workflows.

### Required dependency

The project uses the iTextSharp NuGet package for PDF parsing and modification.

---

## Important notes and limitations

- The tool focuses on PDF annotations and URI-based links; it may not detect every possible type of embedded content.
- The SharePoint workflow depends on Windows networking and drive mapping support.
- The program is intended for Windows environments and uses Windows Forms.
- The output files are generated in the selected output directory rather than overwriting the original PDFs.
- Some PDF files may contain malformed or unusual annotation structures, which may cause warnings or processing failures.

---

## Summary

In short, LinkReplacer-DNATool is a batch-processing utility for:

- editing links inside PDF files,
- extracting asset references from PDF links,
- and exporting hyperlink inventories for documentation or auditing.

It is especially useful in document-heavy environments where PDF hyperlinks need to be corrected, audited, or transformed in bulk.
