import 'package:flutter/cupertino.dart';

import 'generate_job_plans.dart';
import 'parse_template.dart';
import 'pm_name_generator.dart';

class TemplateStore {
  ParsedTemplate parsedTemplate;
  PMName? nameTemplate;
  PMMaximo? processedTemplate;
  String templateStatus;
  Map<String, List<List<String>>> uploadDetails;

  TemplateStore(
      {required this.parsedTemplate,
      this.nameTemplate,
      this.processedTemplate,
      required this.templateStatus,
      Map<String, List<List<String>>>? uploadDetails})
      : uploadDetails = uploadDetails ?? {};
}

class SelectedTemplate {
  String? selectedFile;
  int? selectedTemplate;

  SelectedTemplate({
    this.selectedFile,
    this.selectedTemplate,
  });
}

class TemplateNotifier extends ChangeNotifier {
  Map<String, Map<int, TemplateStore>> allTemplates = {};
  SelectedTemplate selectedTemplate = SelectedTemplate();
// for set functions consider just assuming selected item
// check and add file name to map if necessary
  void addTemplate(String file) {
    if (!allTemplates.keys.contains(file)) {
      allTemplates[file] = {};
    }
  }

  TemplateStore getFullTemplate(String file, int template) {
    return allTemplates[file]![template]!;
  }

  void clearTemplates() {
    allTemplates = {};
    selectedTemplate = SelectedTemplate();
    notifyListeners();
  }

  void setSelectedTemplate(String file, int template) {
    selectedTemplate.selectedFile = file;
    selectedTemplate.selectedTemplate = template;
    notifyListeners();
  }

  SelectedTemplate getSelectedTemplate() {
    return selectedTemplate;
  }

  void setPMPackage(String packageName, String file, int template) {
    final processedTemplate = allTemplates[file]![template]!.processedTemplate!;
    if (packageName.isEmpty) {
      processedTemplate.fmecaPM = false;
      processedTemplate.jobplan.ikoPmpackage = null;
    } else {
      processedTemplate.fmecaPM = true;
      processedTemplate.jobplan.ikoPmpackage = packageName;
    }
    notifyListeners();
  }

  void setPMName(String name, String file, int template) {
    final processedTemplate = allTemplates[file]![template]!.processedTemplate!;
    processedTemplate.description = name;
    processedTemplate.jobplan.description = name;
    if (processedTemplate.route != null) {
      processedTemplate.route!.description = name;
    }
    notifyListeners();
  }

  void setParsedTemplate(
      String file, int templateNumber, ParsedTemplate template) {
    addTemplate(file);
    allTemplates[file]![templateNumber] =
        TemplateStore(templateStatus: 'processing', parsedTemplate: template);
    notifyListeners();
  }

  void setUploadDetails(String file, int template,
      Map<String, List<List<String>>> uploadDetails) {
    addTemplate(file);
    allTemplates[file]![template]!.uploadDetails = uploadDetails;
    notifyListeners();
  }

  Map<String, List<List<String>>> getUploadDetails() {
    /// Return details for selected template
    return allTemplates[selectedTemplate.selectedFile]![
            selectedTemplate.selectedTemplate]!
        .uploadDetails;
  }

  void setNameTemplate(String file, int templateNumber, PMName template) {
    addTemplate(file);
    allTemplates[file]![templateNumber]!.nameTemplate = template;
    notifyListeners();
  }

  void setProcessedTemplate(
      String file, int templateNumber, PMMaximo template) {
    addTemplate(file);
    allTemplates[file]![templateNumber]!.processedTemplate = template;
    setStatus(file, templateNumber, 'processing-done');
    notifyListeners();
  }

  void setStatus(String file, int templateNumber, String status) {
    addTemplate(file);
    allTemplates[file]![templateNumber]!.templateStatus = status;
    notifyListeners();
  }

  String getStatus() {
    /// Get Status of currently selected template.
    return allTemplates[selectedTemplate.selectedFile]![
            selectedTemplate.selectedTemplate]!
        .templateStatus;
  }

  ParsedTemplate getParsedTemplate(String file, int templateNumber) {
    if (!allTemplates.keys.contains(file)) {
      throw Exception('Expected Parsed Template (1)');
    }
    if (!allTemplates[file]!.keys.contains(templateNumber)) {
      throw Exception('Expected Parsed Template (2)');
    }
    return allTemplates[file]![templateNumber]!.parsedTemplate;
  }

  PMName getPMName(String file, int templateNumber) {
    if (!allTemplates.keys.contains(file)) {
      throw Exception('Expected PM Name Template (1)');
    }
    if (!allTemplates[file]!.keys.contains(templateNumber)) {
      throw Exception('Expected PM Name Template (2)');
    }
    return allTemplates[file]![templateNumber]!.nameTemplate!;
  }

  PMMaximo? getProcessedTemplate(String file, int templateNumber) {
    if (!allTemplates.keys.contains(file)) {
      return null;
    }
    if (!allTemplates[file]!.keys.contains(templateNumber)) {
      return null;
    }
    return allTemplates[file]![templateNumber]!.processedTemplate;
  }

  List<String> getFiles() {
    return allTemplates.keys.toList();
  }

  List<int> getTemplates(String filename) {
    if (!allTemplates.keys.contains(filename)) {
      return [];
    }
    return allTemplates[filename]!.keys.toList();
  }
}
