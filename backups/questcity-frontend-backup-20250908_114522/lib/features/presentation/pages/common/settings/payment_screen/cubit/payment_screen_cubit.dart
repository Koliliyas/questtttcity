import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'payment_screen_state.dart';

class PaymentScreenCubit extends Cubit<PaymentScreenState> {
  PaymentScreenCubit() : super(PaymentScreenInitial());

  int selectedCardIndex = 0;

  changeCard(int index) {
    selectedCardIndex = 0;
    emit(PaymentScreenUpdating());
    emit(PaymentScreenInitial());
  }
}
