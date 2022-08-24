import 'package:flutter/cupertino.dart';

import 'generate_job_plans.dart';
import 'parse_template.dart';
import 'pm_name_generator.dart';

class TemplateNotifier extends ChangeNotifier {
  Map<String, Map<int, ParsedTemplate>> parsedTemplates = {};
  Map<String, Map<int, PMName>> nameTemplates = {};
  Map<String, Map<int, PMMaximo>> processedTemplates = {};
  Map<String, Map<int, String>> templateStatus = {};

// check and add file name to map if necessary
  void addTemplate(String file) {
    if (!parsedTemplates.keys.contains(file)) {
      parsedTemplates[file] = {};
      processedTemplates[file] = {};
      templateStatus[file] = {};
      nameTemplates[file] = {};
    }
  }

  void setParsedTemplate(
      String file, int templateNumber, ParsedTemplate template) {
    addTemplate(file);
    parsedTemplates[file]![templateNumber] = template;
  }

  void setNameTemplate(String file, int templateNumber, PMName template) {
    addTemplate(file);
    nameTemplates[file]![templateNumber] = template;
  }

  void setProcessedTemplate(
      String file, int templateNumber, PMMaximo template) {
    addTemplate(file);
    processedTemplates[file]![templateNumber] = template;
    updateStatus(file, templateNumber, 'process-done');
  }

  void updateStatus(String file, int templateNumber, String status) {
    addTemplate(file);
    templateStatus[file]![templateNumber] = status;
  }

  ParsedTemplate? getParsedTemplate(String file, int templateNumber) {
    if (!parsedTemplates.keys.contains(file)) {
      return null;
    }
    if (!parsedTemplates[file]!.keys.contains(templateNumber)) {
      return null;
    }
    return parsedTemplates[file]![templateNumber];
  }

  PMMaximo? getProcessedTemplate(String file, int templateNumber) {
    if (!parsedTemplates.keys.contains(file)) {
      return null;
    }
    if (!parsedTemplates[file]!.keys.contains(templateNumber)) {
      return null;
    }
    return processedTemplates[file]![templateNumber];
  }
}
