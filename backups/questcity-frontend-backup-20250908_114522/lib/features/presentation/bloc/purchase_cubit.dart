import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/domain/usecases/purchase_use_case.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseUseCase purchaseUseCase;

  PurchaseCubit(this.purchaseUseCase) : super(PurchaseInitial());

  void purchaseQuest() async {
    emit(PurchaseLoading());
    await purchaseUseCase.purchaseQuest();
    emit(const PurchaseLoaded(isQuestPurchased: true));
  }

  void checkIfPurchased() async {
    final isPurchased = await purchaseUseCase.isQuestPurchased();
    emit(PurchaseLoaded(isQuestPurchased: isPurchased));
  }
}

abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object> get props => [];
}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseLoaded extends PurchaseState {
  final bool isQuestPurchased;

  const PurchaseLoaded({required this.isQuestPurchased});

  @override
  List<Object> get props => [isQuestPurchased];
}
