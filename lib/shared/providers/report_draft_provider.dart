import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportSignaturePointDraft {
  const ReportSignaturePointDraft({
    required this.dx,
    required this.dy,
    this.isBreak = false,
  });

  final double dx;
  final double dy;
  final bool isBreak;
}

class ReportTimeLogDraft {
  const ReportTimeLogDraft({
    this.heureDebut = '',
    this.heureFin = '',
    this.codeTache = '',
    this.holeNo = '',
    this.fromDe = '',
    this.toA = '',
    this.total = '',
    this.commentaire = '',
    this.distance = '',
    this.duree = '',
    this.selectedTaskOdooId,
  });

  final String heureDebut;
  final String heureFin;
  final String codeTache;
  final String holeNo;
  final String fromDe;
  final String toA;
  final String total;
  final String commentaire;
  final String distance;
  final String duree;
  final int? selectedTaskOdooId;
}

class ReportStaffLogDraft {
  const ReportStaffLogDraft({
    this.employeNom = '',
    this.employeeOdooId,
    this.fonction = '',
    this.hDebut = '00:00',
    this.hFin = '',
    this.total = '',
    this.obs = '',
    this.isAbsent = false,
  });

  final String employeNom;
  final int? employeeOdooId;
  final String fonction;
  final String hDebut;
  final String hFin;
  final String total;
  final String obs;
  final bool isAbsent;
}

class ReportMaterielDraft {
  const ReportMaterielDraft({
    this.materialOdooId,
    this.description = '',
    this.serie = '',
    this.quantite = '0',
    this.observation = '',
    this.status = '',
  });

  final int? materialOdooId;
  final String description;
  final String serie;
  final String quantite;
  final String observation;
  final String status;
}

class ReportFuelLogDraft {
  const ReportFuelLogDraft({
    this.equipmentOdooId,
    this.equipement = '',
    this.qtyFuel = '0',
    this.hDebut = '',
    this.hFin = '',
    this.hDebutRavi = '',
    this.hFinRavi = '',
  });

  final int? equipmentOdooId;
  final String equipement;
  final String qtyFuel;
  final String hDebut;
  final String hFin;
  final String hDebutRavi;
  final String hFinRavi;
}

class ReportDraft {
  const ReportDraft({
    this.quart,
    this.foreuseOdooId,
    this.locationOdooId,
    this.dateText,
    this.projectOdooId,
    this.projectDateDJ,
    this.projectDateDN,
    this.hourMeter = '',
    this.fuelMeter = '',
    this.timeLogs = const [],
    this.staffLogs = const [],
    this.materielLogs = const [],
    this.fuelLogs = const [],
    this.clientSignature = const [],
    this.companySignature = const [],
  });

  final String? quart;
  final int? foreuseOdooId;
  final int? locationOdooId;
  final String? dateText;
  final int? projectOdooId;
  final double? projectDateDJ;
  final double? projectDateDN;
  final String hourMeter;
  final String fuelMeter;
  final List<ReportTimeLogDraft> timeLogs;
  final List<ReportStaffLogDraft> staffLogs;
  final List<ReportMaterielDraft> materielLogs;
  final List<ReportFuelLogDraft> fuelLogs;
  final List<ReportSignaturePointDraft> clientSignature;
  final List<ReportSignaturePointDraft> companySignature;

  ReportDraft copyWith({
    String? quart,
    int? foreuseOdooId,
    int? locationOdooId,
    String? dateText,
    int? projectOdooId,
    double? projectDateDJ,
    double? projectDateDN,
    String? hourMeter,
    String? fuelMeter,
    List<ReportTimeLogDraft>? timeLogs,
    List<ReportStaffLogDraft>? staffLogs,
    List<ReportMaterielDraft>? materielLogs,
    List<ReportFuelLogDraft>? fuelLogs,
    List<ReportSignaturePointDraft>? clientSignature,
    List<ReportSignaturePointDraft>? companySignature,
  }) {
    return ReportDraft(
      quart: quart ?? this.quart,
      foreuseOdooId: foreuseOdooId ?? this.foreuseOdooId,
      locationOdooId: locationOdooId ?? this.locationOdooId,
      dateText: dateText ?? this.dateText,
      projectOdooId: projectOdooId ?? this.projectOdooId,
      projectDateDJ: projectDateDJ ?? this.projectDateDJ,
      projectDateDN: projectDateDN ?? this.projectDateDN,
      hourMeter: hourMeter ?? this.hourMeter,
      fuelMeter: fuelMeter ?? this.fuelMeter,
      timeLogs: timeLogs ?? this.timeLogs,
      staffLogs: staffLogs ?? this.staffLogs,
      materielLogs: materielLogs ?? this.materielLogs,
      fuelLogs: fuelLogs ?? this.fuelLogs,
      clientSignature: clientSignature ?? this.clientSignature,
      companySignature: companySignature ?? this.companySignature,
    );
  }
}

class ReportDraftNotifier extends StateNotifier<ReportDraft> {
  ReportDraftNotifier() : super(const ReportDraft());

  void setQuart(String? quart) {
    state = state.copyWith(quart: quart);
  }

  void setForeuseOdooId(int? foreuseOdooId) {
    state = state.copyWith(foreuseOdooId: foreuseOdooId);
  }

  void setLocationOdooId(int? locationOdooId) {
    state = state.copyWith(locationOdooId: locationOdooId);
  }

  void setDateText(String dateText) {
    state = state.copyWith(dateText: dateText);
  }

  void setProjectData({
    required int projectOdooId,
    double? projectDateDJ,
    double? projectDateDN,
  }) {
    state = state.copyWith(
      projectOdooId: projectOdooId,
      projectDateDJ: projectDateDJ,
      projectDateDN: projectDateDN,
    );
  }

  void setHourMeter(String hourMeter) {
    state = state.copyWith(hourMeter: hourMeter);
  }

  void setFuelMeter(String fuelMeter) {
    state = state.copyWith(fuelMeter: fuelMeter);
  }

  void setTimeLogs(List<ReportTimeLogDraft> timeLogs) {
    state = state.copyWith(timeLogs: List.unmodifiable(timeLogs));
  }

  void setStaffLogs(List<ReportStaffLogDraft> staffLogs) {
    state = state.copyWith(staffLogs: List.unmodifiable(staffLogs));
  }

  void setMaterielLogs(List<ReportMaterielDraft> materielLogs) {
    state = state.copyWith(materielLogs: List.unmodifiable(materielLogs));
  }

  void setFuelLogs(List<ReportFuelLogDraft> fuelLogs) {
    state = state.copyWith(fuelLogs: List.unmodifiable(fuelLogs));
  }

  void setClientSignature(List<ReportSignaturePointDraft> signature) {
    state = state.copyWith(clientSignature: List.unmodifiable(signature));
  }

  void setCompanySignature(List<ReportSignaturePointDraft> signature) {
    state = state.copyWith(companySignature: List.unmodifiable(signature));
  }

  void reset() {
    state = const ReportDraft();
  }
}

final reportDraftProvider = StateNotifierProvider<ReportDraftNotifier, ReportDraft>((ref) {
  return ReportDraftNotifier();
});
