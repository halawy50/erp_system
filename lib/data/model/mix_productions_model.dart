class MixProductionModel {
  final int mixProductionsId;
  final int quantityMixProductions;
  final String employeeName;
  final int fkEmployee;
  final String nameMixProductions;
  final int fkPrescription;
  final String dateTimeProduction;
  final DateTime createdAt;

  MixProductionModel({
    required this.mixProductionsId,
    required this.quantityMixProductions,
    required this.employeeName,
    required this.fkEmployee,
    required this.nameMixProductions,
    required this.fkPrescription,
    required this.dateTimeProduction,
    required this.createdAt,
  });

}
