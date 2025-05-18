import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:system_pvc/data/model/mix_productions_model.dart';
import 'package:system_pvc/repo/mix_production_repo.dart';

part 'mix_production_state.dart';

class MixProductionCubit extends Cubit<MixProductionState> {
  MixProductionRepo mixProductionRepo;
  MixProductionCubit(this.mixProductionRepo) : super(MixProductionInitial());

  // Future<void> getAllMixProductions({int page = 1 , int itemsPerPage = 10}) async{
  //   emit(MixProductionLoading());
  //
  //   final totalPage = await mixProductionRepo.getTotalPages(); // للحصول على عدد العناصر الإجمالي
  //   List<MixProductionModel> mixProductionList = await mixProductionRepo.getMixProductions(page: page , limit:  itemsPerPage);
  //
  //    if(mixProductionList.isNotEmpty){
  //      print("TotalPage : ${totalPage}");
  //      emit(MixProductionLoaded(page, totalPage, mixProductionList));
  //    }else{
  //      emit(MixProductionError("حدث خطأ في تحميل البيانات"));
  //    }
  // }

  Future<void> getAllCountMixProductionsUserFilter(
      String startDateSend,
      String endDateSend,
      List<int> fkPrescription,
      List<int> fkEmployee,
      {
        int page = 1,
        int limit = 10,
      }) async {
    emit(MixProductionLoading());

    final totalPage = await mixProductionRepo.getTotalPages(); // للحصول على عدد العناصر الإجمالي
    List<MixProductionModel> mixProductionList = await mixProductionRepo.getAllCountMixProductionsUserFilter(
      startDateSend,
      endDateSend,
      fkPrescription,
      fkEmployee,
      page: page,
      limit: limit,
    );
    if(mixProductionList.isNotEmpty){
      print("TotalPage : ${totalPage}");
      int totalMixProductions = await mixProductionRepo.getTotalMixProduction(
        startDateSend,
        endDateSend,
        fkPrescription,
        fkEmployee,
      );

      emit(MixProductionLoaded(page, totalPage, mixProductionList , totalMixProductions));
    }else{
      emit(MixProductionError("حدث خطأ في تحميل البيانات"));
    }
  }


}

