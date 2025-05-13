import 'package:equatable/equatable.dart';
import 'package:system_pvc/data/model/material_model.dart';

abstract class MaterialsState {
  const MaterialsState();

  @override
  List<Object?> get props => [];
}

class MaterialInitial extends MaterialsState {}

class MaterialLoading extends MaterialsState {}

class MaterialLoaded extends MaterialsState {
  final List<MaterialModel> materials;
  final int currentPage;
  final int totalPages;

  const MaterialLoaded({
    required this.materials,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [materials, currentPage, totalPages];
}



class MaterialError extends MaterialsState {
  final String message;

  const MaterialError(this.message);

  @override
  List<Object?> get props => [message];
}
