import 'package:flutter/cupertino.dart';

import 'generate_job_plans.dart';
import 'parse_template.dart';
import 'pm_name_generator.dart';

class TemplateStore {
  ParsedTemplate parsedTemplate;
  PMName? nameTemplate;
  PMMaximo? processedTemplate;
  String templateStatus;

  TemplateStore({
    required this.parsedTemplate,
    this.nameTemplate,
    this.processedTemplate,
    required this.templateStatus,
  });
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

// check and add file name to map if necessary
  void addTemplate(String file) {
    if (!allTemplates.keys.contains(file)) {
      allTemplates[file] = {};
    }
  }

  TemplateStore getFullTemplate(String file, int template) {
    return allTemplates[file]![template]!;
  }

  void setSelectedTemplate(String file, int template) {
    selectedTemplate.selectedFile = file;
    selectedTemplate.selectedTemplate = template;
    notifyListeners();
  }

  SelectedTemplate getSelectedTemplate() {
    return selectedTemplate;
  }

  void setParsedTemplate(
      String file, int templateNumber, ParsedTemplate template) {
    addTemplate(file);
    allTemplates[file]![templateNumber] =
        TemplateStore(templateStatus: 'processing', parsedTemplate: template);
    notifyListeners();
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
