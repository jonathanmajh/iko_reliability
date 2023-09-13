final personGroups = {
  'O': 'PRODSUP',
  'M': 'MECHSUP',
  'E': 'ELECTSUP',
};

final assetCriticality = {
  1: 'Very Low',
  3: 'Low',
  5: 'Medium',
  7: 'High',
  9: 'Very High',
};

List<String> criticalityStrings = [
  'Very Low',
  'Low',
  'Medium',
  'High',
  'Very High',
];

enum CriticalityEnums {
  percentVL,
  percentL,
  percentM,
  percentH,
  percentVH,
}

final freqUnitToDays = {
  'D': 1,
  'W': 7,
  'M': 30,
  'Y': 365,
};

final productionLines = {
  'C': 'Common',
  'S': 'Shingle',
  'B': 'Insulation',
  'R': 'Granule',
  'T': 'TPO',
  'W': 'Wrapper',
  'G': 'Mortar',
  'M': 'Mod',
};

const workType = {
  'PPM': 'Preventive Maintenance',
  'CAL': 'Calibration',
  'ENV': 'Environmental',
  'HKG': 'Housekeeping',
  'INR': 'Routine Inspection',
  'LIF': 'Life Cycle',
  'LUB': 'Lubrication',
  'PDM': 'Predictive Maintenance',
  'PEM': 'Pre-emptive Maintenance',
  'PRO': 'Process Maintenance',
  'SAF': 'Safety',
};

const assetWorkType = {
  "BDE": AssetWorkType("BDE", "Breakdown - Electrical", 4),
  "BDM": AssetWorkType("BDM", "Breakdown - Mechanical", 4),
  "BDO": AssetWorkType("BDO", "Breakdown - Operational", 4),
  "CORE": AssetWorkType("CORE", "Corrective - Post-Repair - Electrical", 3),
  "CORM": AssetWorkType("CORM", "Corrective - Post-Repair - Mechanical", 3),
  "EPIE":
      AssetWorkType("EPIE", "Equipment/Process Improvement - Electrical", 1),
  "EPIM":
      AssetWorkType("EPIM", "Equipment/Process Improvement - Mechanical", 1),
  "HKGM": AssetWorkType("HKGM", "Housekeeping", 1),
  "INAE": AssetWorkType("INAE", "Inspection - Ad Hoc - Electrical", 3),
  "INAM": AssetWorkType("INAM", "Inspection - Ad Hoc - Mechanical", 3),
  "PEME": AssetWorkType("PEME", "Pre-emptive Maintenance - Electrical", 3),
  "PEMM": AssetWorkType("PEMM", "Pre-emptive Maintenance - Mechanical", 3),
  "RECE": AssetWorkType("RECE", "Recondition - Electrical", 3),
  "RECM": AssetWorkType("RECM", "Recondition - Mechanical", 3),
  "SAFE": AssetWorkType("SAFE", "Safety - Electrical", 3),
  "SAFM": AssetWorkType("SAFM", "Safety - Mechanical", 3),
  "TSHE": AssetWorkType("TSHE", "Troubleshooting - Electrical", 3),
  "TSHM": AssetWorkType("TSHM", "Troubleshooting - Mechanical", 3),
};

const crafts = {
  'E': 'Electrical',
  'M': 'Mechanical',
  'O': 'Production',
};

const craftCode = {
  'E': 'ELECT',
  'M': 'MECH-MW',
  'O': 'PROD',
};

final freqUnitToString = {
  'D': 'Days',
  'W': 'Weeks',
  'M': 'Months',
  'Y': 'Years',
};

final siteIDAndOrgID = {
  'AA': 'IKO-CAD',
  'ANT': 'IKO-EU',
  'BA': 'IKO-CAD',
  'BL': 'IKO-US',
  'CA': 'IKO-US',
  'CAM': 'IKO-UK',
  'COM': 'IKO-EU',
  'GC': 'IKO-US',
  'GE': 'IKO-CAD',
  'GH': 'IKO-CAD',
  'GI': 'IKO-CAD',
  'GJ': 'IKO-CAD',
  'GK': 'IKO-CAD',
  'GM': 'IKO-CAD',
  'GP': 'IKO-CAD',
  'GR': 'IKO-CAD',
  'GS': 'IKO-US',
  'GV': 'IKO-US',
  'GX': 'IKO-CAD',
  'PBM': 'IKO-EU',
  'RAM': 'IKO-UK',
  'KLU': 'IKO-EU',
};

final siteIDAndDescription = {
  'RAM': 'Alconbury',
  'ANT': 'Antwerp',
  'CAM': 'Appley Bridge',
  'GE': 'Ashcroft',
  'GR': 'BramCal',
  'GP': 'CRC Brampton',
  'AA': 'IKO Brampton',
  'GK': 'IG Brampton',
  'BA': 'Calgary',
  'COM': 'Combronde',
  'BL': 'Hagerstown',
  'GH': 'Hawkesbury',
  'GM': 'High River',
  'GV': 'Hillsboro',
  'CA': 'Kankakee',
  'KLU': 'Klundert',
  'GI': 'Madoc',
  'GX': 'MaxiMix',
  'PBM': 'Senica',
  'GC': 'Sumas',
  'GS': 'Sylacauga',
  'GJ': 'CRC Toronto',
};

const tableHeaders = {
  'PM': [
    'SITEID',
    'PMNUM',
    'DESCRIPTION',
    'JPNUM',
    'WOSTATUS',
    'PERSONGROUP',
    'FREQUENCY',
    'FREQUNIT',
    'PMASSETWOGEN',
    'ASSETNUM',
    'ROUTE',
    'LEADTIME',
    'PRIORITY',
    'NEXTDATE',
    'ORGID',
    'TARGSTARTTIME',
    'IKO_PMHISTORYNOTES',
    'IKO_FMECA',
  ],
  'Route': [
    'ORGID',
    'SITEID',
    'ROUTE',
    'ROUTESTOPSBECOME',
    'DESCRIPTION',
  ],
  'Route_Stop': [
    'ORGID',
    'SITEID',
    'ROUTE',
    'ROUTESTOPID',
    'ASSETNUM',
    'JPNUM',
    'STOPSEQUENCE',
    'ASSETLOCORGID',
    'ASSETLOCSITEID',
  ],
  'JobPlan': [
    'ORGID',
    'SITEID',
    'JPNUM',
    'PLUSCREVNUM',
    'DESCRIPTION',
    'DESCRIPTION_LONGDESCRIPTION',
    'STATUS',
    'PERSONGROUP',
    'IKO_CONDITIONS',
    'PRIORITY',
    'IKO_WORKTYPE',
    'TEMPLATETYPE',
    'JPDURATION',
    'DOWNTIME',
    'INTERRUPTIBLE',
    'IKO_PMPACKAGE',
  ],
  'JobMaterial': [
    'JP_ORGID',
    'JP_SITEID',
    'JP_JPNUM',
    'PLUSCREVNUM',
    'ORGID',
    'SITEID',
    'ITEMNUM',
    'ITEMQTY',
    'ITEMSETID',
    'LOCATION',
    'STORELOCSITE',
    'COMPANY',
    'COST'
  ],
  'JobService': [
    'JP_ORGID',
    'JP_SITEID',
    'JP_JPNUM',
    'PLUSCREVNUM',
    'ORGID',
    'SITEID',
    'ITEMNUM',
    'ITEMQTY',
    'ITEMSETID',
    'COMPANY',
    'COST'
  ],
  'JobLabor': [
    'JP_ORGID',
    'JP_SITEID',
    'JP_JPNUM',
    'PLUSCREVNUM',
    'CRAFT',
    'LABORHRS',
    'QUANTITY',
    'ORGID',
    'LABORCODE'
  ],
  'JPASSETLINK': [
    'JP_ORGID',
    'JP_SITEID',
    'JP_JPNUM',
    'PLUSCREVNUM',
    'ASSETNUM',
    'ISDEFAULTASSETSP',
    'ORGID',
    'SITEID',
  ],
  'JobTask': [
    'ORGID',
    'SITEID',
    'JPNUM',
    'PLUSCREVNUM',
    'JPTASK',
    'PLUSCJPREVNUM',
    'METERNAME',
    'DESCRIPTION',
    'DESCRIPTION_LONGDESCRIPTION'
  ],
  'Asset': ['SITEID', 'ASSETNUM', 'IKO_PMPACKAGE'],
  'AssetMeter': ['SITEID', 'ASSETNUM', 'METERNAME'],
  'MeasurePoint': [
    'SITEID',
    'ASSETNUM',
    'METERNAME',
    'POINTNUM',
    'DESCRIPTION'
  ],
  'Meter': ['METERNAME', 'DESCRIPTION', 'METERTYPE', 'DOMAINID'],
  'MeasurePoint2': ['SITEID', 'POINTNUM', 'VALUE', 'JPNUM'],
  'Location': [
    'SITEID',
    'LOCATION',
    'DESCRIPTION',
    'STATUS',
    'SYSTEMID',
    'TYPE',
    'PARENT'
  ],
};

Map<String, String> maximoServerDomains = {
  'MASDEV': 'https://dev.manage.dev.iko.max-it-eam.com/maximo/api/os/',
  'MASTEST': 'https://test.manage.test.iko.max-it-eam.com/maximo/api/os/',
  'MASPROD': 'https://prod.manage.prod.iko.max-it-eam.com/maximo/api/os/'
};

Map<String, String> apiKeys = {
  'MASDEV': '', //'n075qt6edkgf931ike9pegc3vejbbtgalabbrrrf'
  'MASTEST': '', //'n075qt6edkgf931ike9pegc3vejbbtgalabbrrrf'
  'MASPROD': '',
};

Map<int, Map<String, dynamic>> frequencyRating = {
  1: {
    'description': '1 Per 5 Years',
    'likelihood': 'Remote',
    'longdesc':
        'Remote probability of occurrence; unlikely for failure to occur. Personnel are regularly trained and tested on tools and updated proceedures associated.',
    'low': 0.0,
    'high': 0.33,
  },
  2: {
    'description': '1 Per 3 Years',
    'likelihood': 'Very Low',
    'longdesc':
        'Very low failure rate.  Similar to design that has, in the past, had very low failure rates for given volume. Personnel are trained and tested on tools and proceedures associated.',
    'low': 0.33,
    'high': 0.5,
  },
  3: {
    'description': '1 Per 2 Years',
    'likelihood': 'Low',
    'longdesc':
        'Low failure rate. Similar to design that has, in the past, had low failure rates for the given volume. Personnel are trained on tools and proceedures annually.',
    'low': 0.5,
    'high': 1.0,
  },
  4: {
    'description': '1 Per Year',
    'likelihood': 'Occasional',
    'longdesc':
        'Occasional failure rate. Similar to design that has, in the past, had occasional failure rates for the given volume. Personnel are trained on tools and proceedures.',
    'low': 1.0,
    'high': 2.0,
  },
  5: {
    'description': '1 Per 6 Months',
    'likelihood': 'Occasional to Moderate',
    'longdesc':
        'Occasional to moderate failure rate. Similar to design that has, in the past, had occasional to moderate failure rates for the given volume. Personnel have been trained on proceedures but no formal training program.',
    'low': 2.0,
    'high': 3.0,
  },
  6: {
    'description': '1 Per 4 Months',
    'likelihood': 'Moderate',
    'longdesc':
        'Moderate failure rate. Similar to design that has, in the past, had moderate failure rates for the given volume. Personnel have proceedures but do not reference on a regular basis.',
    'low': 3.0,
    'high': 6.0,
  },
  7: {
    'description': '1 Per 2 Months',
    'likelihood': 'Moderate to High',
    'longdesc':
        'Moderate to high failure rate. Similar to design that has, in the past, had moderate to high failure rates for the given volume. Personnel were trained years ago and proceedures do not exist or have not been reviewed.',
    'low': 6.0,
    'high': 12.0,
  },
  8: {
    'description': '1 Per Month',
    'likelihood': 'High',
    'longdesc':
        'High failure rate. Similar to design that has, in the past, had high failure rates that have caused problems. Training is informal by word of mouth.',
    'low': 12.0,
    'high': 52.0,
  },
  9: {
    'description': '1 Per Week',
    'likelihood': 'High to Very High',
    'longdesc':
        'High to very high failure rate. Highly likely to cause problems. Personnel were trained years ago and proceedures do not exist or have not been reviewed.',
    'low': 52.0,
    'high': 104.0,
  },
  10: {
    'description': '2 Per Week',
    'likelihood': 'Very High',
    'longdesc':
        'Very high failure rate. Certain to cause problems. Training, tools and proceedures do not exist or are outdated.',
    'low': 104.0,
    'high': 9999999.0,
  },
};

Map<int, Map<String, dynamic>> impactRating = {
  1: {
    'description': 'No Down Time',
    'likelihood': 'None',
    'longdesc':
        'No reason to expect failure to have any effect on safety, health, environmental or system production. ',
    'low': 0.0,
    'high': 0.0,
  },
  2: {
    'description': '0 to 2 Hours',
    'likelihood': 'Very Low',
    'longdesc':
        'Minor disruption to system function. Repair of failure can be accomplished during trouble call. (25% rate reduction)',
    'low': 0.0,
    'high': 2.0,
  },
  3: {
    'description': '2 to 5 Hours',
    'likelihood': 'Occasional',
    'longdesc':
        'Minor disruption to system function. Repair of failure may be longer than trouble call but does not delay system production. (50% rate reduction)',
    'low': 2.0,
    'high': 5.0,
  },
  4: {
    'description': '5 to 10 Hours',
    'likelihood': 'Occasional to Moderate',
    'longdesc':
        'Moderate disruption to system function. Some portion of system production may need to be reworked or process delayed. (75% rate reduction)',
    'low': 5.0,
    'high': 10.0,
  },
  5: {
    'description': '10 to 20 Hours',
    'likelihood': 'Moderate',
    'longdesc':
        'Moderate disruption to system function. All system production may need to be reworked or process delayed. (Down 12 hours)',
    'low': 10.0,
    'high': 20.0,
  },
  6: {
    'description': '20 to 30 Hours',
    'likelihood': 'Moderate to High',
    'longdesc':
        'Moderate disruption to system function. Some portion of system production is lost. Moderate delay in restoring system function. (Down 1 day)',
    'low': 20.0,
    'high': 30.0,
  },
  7: {
    'description': '1 to 3 Days',
    'likelihood': 'High',
    'longdesc':
        'High disruption to system function. Some portion of system production is lost.  Significant delay in restoring system function. (Down 3 days)',
    'low': 30.0,
    'high': 72.0,
  },
  8: {
    'description': '3 Days to 1 Week',
    'likelihood': 'Very High',
    'longdesc':
        'Very high disruption to System function. All system production is lost. Significant delay in restoring system function. (Down 1 week)',
    'low': 72.0,
    'high': 168.0,
  },
  9: {
    'description': 'HSE (with warning)',
    'likelihood': 'Hazardous(with warning)',
    'longdesc':
        'Potential health, safety, or environmental issue. Failure will occur with warning.',
    'low': 168.0,
    'high': 720.0,
  },
  10: {
    'description': 'HSE (without warning)',
    'likelihood': 'Hazardous(without warning)',
    'longdesc':
        'Potential health, safety, or environmental issue. Failure will occur without warning. ',
    'low': 720.0,
    'high': 9999999.0,
  },
};

List<String> systemSafety = [
  '',
  'No Injury',
  'Near Miss',
  'Unsafe Condition',
  'First Aid',
  'Medical Treatment',
  'Lost Time',
  'Long-Term Disability',
  'Fatality',
  'Multiple Fatalities',
  'Catastrophic Event'
];

List<String> systemRegulatory = [
  '',
  'No Fine',
  '10K in Fines',
  '100K in Fines',
  '1M in Fines',
  '5M+ in Fines',
  'Production Halt',
  'Plant Shutdown',
  'Regulatory Investigation',
  'Criminal Charges',
  'Legal Action',
];

List<String> systemEconomic = [
  '',
  'No Cost',
  '1K in Parts',
  '5K in Parts',
  '10K in Parts',
  '50K in Parts',
  '100K in Parts',
  '150K in Parts',
  '250K in Parts',
  '500K in Parts',
  '500K+ in Parts',
];

List<String> systemThroughput = [
  '',
  'No Impact',
  '25% Reduced Production',
  '50% Reduced Production',
  '1 Hr downtime',
  '4 Hrs downtime',
  '8 Hrs downtime',
  '24 hrs downtime',
  '3 Days downtime',
  '1 Week downtime',
  '1+ Weeks downtime',
];

List<String> systemQuality = [
  '',
  'No Scrap',
  '10 pallets of scrap',
  '30 pallets of scrap',
  '10K in potential claims',
  '40K in potential claims',
  'Potential class action',
];

Map<int, Map<String, dynamic>> usageRating = {
  1: {
    'description': 'Single Occurance',
    'longdesc': '',
    'low': 0.0,
    'high': 1,
  },
  2: {
    'description': '2 Occurances',
    'longdesc': '',
    'low': 1,
    'high': 2,
  },
  3: {
    'description': '3 - 4 Occurances',
    'longdesc': '',
    'low': 2,
    'high': 5,
  },
  4: {
    'description': '5 - 10 Occurances',
    'longdesc': '',
    'low': 5,
    'high': 10,
  },
  5: {
    'description': '11 - 20 Occurances',
    'longdesc': '',
    'low': 10,
    'high': 20,
  },
  6: {
    'description': '21 - 30 Occurances',
    'longdesc': '',
    'low': 20,
    'high': 30,
  },
  7: {
    'description': '31 - 40 Occurances',
    'longdesc': '',
    'low': 30,
    'high': 40,
  },
  8: {
    'description': '41 - 50 Occurances',
    'longdesc': '',
    'low': 40,
    'high': 50,
  },
  9: {
    'description': '51 - 60 Occurances',
    'longdesc': '',
    'low': 50,
    'high': 60,
  },
  10: {
    'description': 'More Than 60 Occurances',
    'longdesc': '',
    'low': 60,
    'high': 9999999.0,
  },
};

Map<int, Map<String, dynamic>> leadTimeRating = {
  1: {
    'description': 'Stock Item',
    'longdesc': 'Items stocked by Vendor',
    'low': 0.0,
    'high': 1.0,
  },
  2: {
    'description': '< 1 Week',
    'longdesc': '1 week lead time',
    'low': 1,
    'high': 7,
  },
  3: {
    'description': '1 to 2 Weeks',
    'longdesc': '2 weeks lead time',
    'low': 7,
    'high': 14,
  },
  4: {
    'description': '2 to 4 Weeks',
    'longdesc': '4 weeks lead time',
    'low': 14,
    'high': 28,
  },
  5: {
    'description': '1 to 2 Months',
    'longdesc': '2 months lead time',
    'low': 28,
    'high': 60,
  },
  6: {
    'description': '2 to 4 Months',
    'longdesc': '4 months lead time',
    'low': 60,
    'high': 120,
  },
  7: {
    'description': '4 to 6 Months',
    'longdesc': '6 months lead time',
    'low': 120,
    'high': 182,
  },
  8: {
    'description': '6 to 8 Months',
    'longdesc': '8 months lead time',
    'low': 180,
    'high': 240,
  },
  9: {
    'description': '8 to 12 Months',
    'longdesc': '1 year lead time',
    'low': 240,
    'high': 365,
  },
  10: {
    'description': '> 1 Year',
    'likelihood': 'Very High',
    'longdesc': 'more than 1 year lead time',
    'low': 365,
    'high': 9999999.0,
  },
};

Map<int, Map<String, dynamic>> costRating = {
  1: {
    'description': '< \$10',
    'longdesc': '',
    'low': 0.0,
    'high': 10,
  },
  2: {
    'description': '\$10 - \$50',
    'longdesc': '',
    'low': 10,
    'high': 50,
  },
  3: {
    'description': '\$50 - \$100',
    'longdesc': '',
    'low': 50,
    'high': 100,
  },
  4: {
    'description': '\$100 - \$250',
    'longdesc': '',
    'low': 100,
    'high': 250,
  },
  5: {
    'description': '\$250 - \$500',
    'longdesc': '',
    'low': 250,
    'high': 500,
  },
  6: {
    'description': '\$500 - \$750',
    'longdesc': '',
    'low': 500,
    'high': 750,
  },
  7: {
    'description': '\$750 - \$1000',
    'longdesc': '',
    'low': 750,
    'high': 1000,
  },
  8: {
    'description': '\$1000 - \$5000',
    'longdesc': '',
    'low': 1000,
    'high': 5000,
  },
  9: {
    'description': '\$5000 - \$10000',
    'longdesc': '',
    'low': 5000,
    'high': 10000,
  },
  10: {
    'description': '> \$10000',
    'longdesc': '',
    'low': 10000,
    'high': 9999999.0,
  },
};

//For application settings (add with new settings)
//keys hold the settings names while values are the datatypes they can be
enum ApplicationSetting {
  ///TRUE FALSE for application theme mode (darkmode, lightmode)
  darkmodeOn(keyString: 'darkmode on', dataType: 'bool', defaultValue: false),

  ///TRUE FALSE for hiding the update availiable prompt
  updateWindowOff(
      keyString: 'update window off', dataType: 'bool', defaultValue: false),

  ///int for asset criticality RPN risk distribution percentage (very low)
  rpnPercentVL(
      keyString: 'RPN percent very low', dataType: 'int', defaultValue: 30),

  ///int for asset criticality RPN distribution percentage (low)
  rpnPercentL(keyString: 'RPN percent low', dataType: 'int', defaultValue: 25),

  ///int for asset criticality RPN distribution percentage (medium)
  rpnPercentM(
      keyString: 'RPN percent medium', dataType: 'int', defaultValue: 20),

  ///int for asset criticality RPN risk distribution percentage (high)
  rpnPercentH(keyString: 'RPN percent high', dataType: 'int', defaultValue: 15),

  ///int for asset criticality RPN risk distribution percentage (very high)
  rpnPercentVH(
      keyString: 'RPN percent very high', dataType: 'int', defaultValue: 10),

  ///set of the ids of the loaded IKO sites
  loadedSites(
    keyString: 'loaded sites',
    dataType: 'Set<String>',
    defaultValue: <String>{},
  );

  const ApplicationSetting(
      {required this.keyString,
      required this.dataType,
      required this.defaultValue});

  final String keyString;
  final String dataType;
  final dynamic defaultValue;

  ///map of the default settings
  static Map<ApplicationSetting, dynamic> get defaultSettings {
    Map<ApplicationSetting, dynamic> map = {};
    for (ApplicationSetting setting in ApplicationSetting.values) {
      map[setting] = setting.defaultValue;
    }
    return map;
  }

  ///gets a list of keyStrings. Listed from the {keyString} of the {ApplicationSetting} with the lowest index to the highest
  static List<String> get keyStrings {
    List<String> list = [];
    for (ApplicationSetting setting in ApplicationSetting.values) {
      list.add(setting.keyString);
    }
    return list;
  }

  ///gets the {ApplicationSetting} with the same {this.keyString} as {keyString}
  static ApplicationSetting getSettingFromKeyString(String keyString) {
    for (ApplicationSetting setting in ApplicationSetting.values) {
      if (setting.keyString == keyString) return setting;
    }
    throw Exception('[$keyString] is not a valid setting.');
  }

  @override
  String toString() {
    return keyString;
  }
}

//add new application processes here
///Various time-consuming processes the application goes through. Used for {ProcessStateNotifier}
enum ProcessStates {
  loginState(),
  loadAssetState(),
  loadPMFilesState(),
  uploadPMFilesState();
}

class AssetWorkType {
  const AssetWorkType(this._title, this._description, this._priority);

  final String _title, _description;
  final int _priority;

  get title => _title;

  get priority => _priority;

  get description => _description;
}
