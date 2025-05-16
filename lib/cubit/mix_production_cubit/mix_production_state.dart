part of 'mix_production_cubit.dart';

@immutable
sealed class MixProductionState {}

final class MixProductionInitial extends MixProductionState {}

final class MixProductionLoading extends MixProductionState {}

final class MixProductionLoaded extends MixProductionState {
  int page;
  int totalPage;
  List<MixProductionModel> mixProductionList;
  final int totalCount;

  MixProductionLoaded(this.page , this.totalPage , this.mixProductionList , this.totalCount);
}

final class MixProductionError extends MixProductionState {
  String errorMessage;
  MixProductionError(this.errorMessage);
}
