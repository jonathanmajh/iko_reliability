import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'pdf_link_service.dart';

@RoutePage()
class PdfLinkToolPage extends StatefulWidget {
  const PdfLinkToolPage({super.key});

  @override
  State<PdfLinkToolPage> createState() => _PdfLinkToolPageState();
}

class _PdfLinkToolPageState extends State<PdfLinkToolPage> {
  final PdfLinkToolService _service = PdfLinkToolService();
  final List<File> _selectedFiles = <File>[];
  String _outputFolder = '';
  String _status = 'Ready';
  bool _recursive = false;
  bool _isRunning = false;
  bool _cancelRequested = false;
  PdfLinkReplacementMode _mode = PdfLinkReplacementMode.replaceAll;
  final TextEditingController _findController = TextEditingController();
  final TextEditingController _replacementController = TextEditingController();

  @override
  void dispose() {
    _findController.dispose();
    _replacementController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final files = await _service.pickPdfFiles();
    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(files);
      _status = files.isEmpty
          ? 'No files selected'
          : '${files.length} file(s) selected';
    });
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null || result.isEmpty) {
      return;
    }

    final files =
        await _service.collectPdfFilesFromFolder(result, recursive: _recursive);
    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(files);
      _outputFolder = result;
      _status = '${files.length} file(s) found in folder';
    });
  }

  Future<void> _pickOutputFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null || result.isEmpty) {
      return;
    }
    setState(() {
      _outputFolder = result;
      _status = 'Output folder selected';
    });
  }

  Future<void> _startReplacement() async {
    if (_isRunning) {
      return;
    }

    if (_selectedFiles.isEmpty) {
      setState(() => _status = 'Select at least one PDF file first');
      return;
    }

    if (_outputFolder.isEmpty) {
      setState(() => _status = 'Choose an output folder first');
      return;
    }

    setState(() {
      _isRunning = true;
      _cancelRequested = false;
      _status = 'Replacing URLs...';
    });

    final outputs = <String>[];
    try {
      for (int index = 0; index < _selectedFiles.length; index++) {
        if (!mounted) {
          return;
        }

        if (_cancelRequested) {
          break;
        }

        final file = _selectedFiles[index];
        final outputPath = await _service.processPdfFile(
          file,
          find: _findController.text,
          replacement: _replacementController.text,
          mode: _mode,
          outputFolder: _outputFolder,
        );
        outputs.add(outputPath);

        if (mounted) {
          setState(() => _status =
              'Replaced links in ${index + 1}/${_selectedFiles.length} file(s)');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
          if (_cancelRequested) {
            _status = 'Replacement stopped';
          } else if (outputs.isNotEmpty) {
            _status =
                'Completed replacement for ${outputs.length} file(s): ${outputs.join(', ')}';
          } else {
            _status = 'No replacement files generated';
          }
        });
      }
    }
  }

  Future<void> _exportDiscoveredLinks() async {
    if (_isRunning) {
      return;
    }

    if (_selectedFiles.isEmpty) {
      setState(() => _status = 'Select at least one PDF file first');
      return;
    }

    if (_outputFolder.isEmpty) {
      setState(() => _status = 'Choose an output folder first');
      return;
    }

    setState(() {
      _isRunning = true;
      _cancelRequested = false;
      _status = 'Exporting discovered links...';
    });

    final rows = <Map<String, String>>[];
    try {
      for (int index = 0; index < _selectedFiles.length; index++) {
        if (!mounted) {
          return;
        }

        if (_cancelRequested) {
          break;
        }

        final file = _selectedFiles[index];
        final links = await _service.extractLinksFromPdf(file);
        for (final link in links) {
          rows.add({'fileName': p.basename(file.path), 'link': link});
        }

        if (mounted) {
          setState(() => _status =
              'Scanned ${index + 1}/${_selectedFiles.length} file(s)');
        }
      }

      final outputPath = await _service.exportLinksCsv(rows, _outputFolder);
      if (mounted) {
        setState(
            () => _status = 'Exported ${rows.length} link(s) to $outputPath');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
          if (_cancelRequested) {
            _status = 'Export stopped';
          }
        });
      }
    }
  }

  void _stopProcessing() {
    if (!_isRunning) {
      return;
    }

    setState(() {
      _cancelRequested = true;
      _status = 'Stopping...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Link Tool'),
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? const BackButton()
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Select PDFs'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFolder,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select Folder'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickOutputFolder,
                  icon: const Icon(Icons.output),
                  label: const Text('Output Folder'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include subfolders'),
              value: _recursive,
              onChanged: (value) => setState(() => _recursive = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PdfLinkReplacementMode>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'Replacement mode'),
              items: const [
                DropdownMenuItem(
                  value: PdfLinkReplacementMode.replaceAll,
                  child: Text('Find and replace all'),
                ),
                DropdownMenuItem(
                  value: PdfLinkReplacementMode.prefix,
                  child: Text('Add prefix'),
                ),
                DropdownMenuItem(
                  value: PdfLinkReplacementMode.suffix,
                  child: Text('Add suffix'),
                ),
              ],
              onChanged: (value) => setState(() => _mode = value ?? _mode),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _findController,
              decoration: const InputDecoration(labelText: 'Find text'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _replacementController,
              decoration: const InputDecoration(labelText: 'Replacement text'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _startReplacement,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Replace matching URLs'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _exportDiscoveredLinks,
                  icon: const Icon(Icons.download),
                  label: const Text('Export discovered links'),
                ),
                OutlinedButton.icon(
                  onPressed: _isRunning ? _stopProcessing : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedFiles.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selected files (${_selectedFiles.length})'),
                      const SizedBox(height: 8),
                      ..._selectedFiles
                          .map((file) => Text(p.basename(file.path)))
                          .toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
