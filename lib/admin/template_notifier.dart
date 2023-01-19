import 'package:flutter/cupertino.dart';

import 'generate_job_plans.dart';
import 'parse_template.dart';
import 'pm_name_generator.dart';

class TemplateStore {
  ParsedTemplate parsedTemplate;
  PMName? nameTemplate;
  PMMaximo? processedTemplate;
  String templateStatus;
  List<String> statusMessages = [];

  TemplateStore({
    required this.parsedTemplate,
    this.nameTemplate,
    this.processedTemplate,
    required this.templateStatus,
  });
}

class UploadStore {
  Map<String, List<List<String>>> uploadDetails;
  int uploadedLines;
  UploadStore({
    Map<String, List<List<String>>>? uploadDetails,
    int? uploadedLines,
  })  : uploadDetails = uploadDetails ?? {},
        uploadedLines = uploadedLines ?? 0;
}

class SelectedTemplate {
  String? selectedFile;
  int? selectedTemplate;

  SelectedTemplate({
    this.selectedFile,
    this.selectedTemplate,
  });
}

class UploadNotifier extends ChangeNotifier {
  Map<String, Map<int, UploadStore>> templateUpload = {};
  void addTemplate(String file) {
    if (!templateUpload.keys.contains(file)) {
      templateUpload[file] = {};
    }
  }

  void clearTemplates() {
    templateUpload = {};
    notifyListeners();
  }

  void setUploadDetails(String file, int template,
      Map<String, List<List<String>>> uploadDetails) {
    addTemplate(file);
    if (!templateUpload[file]!.containsKey(template)) {
      templateUpload[file]![template] = UploadStore();
    }
    templateUpload[file]![template]!.uploadDetails = uploadDetails;
    notifyListeners();
  }

  Map<String, List<List<String>>> getUploadDetails(
      String file, int templateNumber) {
    /// Return details for selected template
    return templateUpload[file]?[templateNumber]?.uploadDetails ?? {};
  }
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

  void clearTemplates() {
    allTemplates = {};
    selectedTemplate = SelectedTemplate();
    notifyListeners();
  }

  void addStatusMessage(String file, int template, String msg) {
    allTemplates[file]![template]!.statusMessages.add(msg);
    allTemplates[file]![template]!.templateStatus = 'error';
    notifyListeners();
  }

  String getTemplateNumber(String file, int template) {
    return allTemplates[file]![template]!.nameTemplate?.pmNumber ??
        allTemplates[file]![template]!.parsedTemplate.pmNumber;
  }

  String getTemplateName(String file, int template) {
    return allTemplates[file]![template]!.nameTemplate?.pmName ??
        allTemplates[file]![template]!.parsedTemplate.pmName;
  }

  List<String> getStatusMessages(String file, int template) {
    return allTemplates[file]![template]!.statusMessages;
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
    notifyListeners();
  }

  void setRouteName(String name, String file, int template) {
    final processedTemplate = allTemplates[file]![template]!.processedTemplate!;
    if (processedTemplate.route != null) {
      processedTemplate.route!.description = name;
    }
    notifyListeners();
  }

  void setRouteInfo(String code, String description, String file, int template,
      String maximoServerSelected) async {
    final parsedTemplate = allTemplates[file]![template]!.parsedTemplate;
    parsedTemplate.routeCode = code;
    parsedTemplate.routeName = description;
    try {
      setParsedTemplate(file, template, parsedTemplate);
      final value = await generateName(
        parsedTemplate,
        maximoServerSelected,
      );
      setNameTemplate(file, template, value);
      final value2 = await generatePM(
        parsedTemplate,
        getPMName(file, template),
        maximoServerSelected,
      );
      setProcessedTemplate(file, template, value2);
    } catch (e) {
      debugPrint(e.toString());
      addStatusMessage(file, template, '$e');
    }
    notifyListeners();
  }

  void setPMNumber(String number, String file, int template) {
    final processedTemplate = allTemplates[file]![template]!.processedTemplate!;
    processedTemplate.pmNumber = number;
    processedTemplate.jobplan.jpnum = '${processedTemplate.siteID}$number';
    notifyListeners();
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

  String getStatus(String file, int templateNumber) {
    /// Get Status of currently selected template.
    return allTemplates[file]![templateNumber]!.templateStatus;
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
