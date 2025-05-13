import 'package:system_pvc/data/model/prescription_management_model.dart';

// الحالة المحتملة لـ Cubit
abstract class PrescriptionState {}

class PrescriptionInitialState extends PrescriptionState {}

class PrescriptionLoadingState extends PrescriptionState {}

class PrescriptionLoadedState extends PrescriptionState {
  final List<PrescriptionManagementModel> prescriptions;
  PrescriptionLoadedState(this.prescriptions);
}

class PrescriptionErrorState extends PrescriptionState {
  final String errorMessage;
  PrescriptionErrorState(this.errorMessage);
}
