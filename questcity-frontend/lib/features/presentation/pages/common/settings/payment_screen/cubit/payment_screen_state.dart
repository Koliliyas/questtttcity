part of 'payment_screen_cubit.dart';

abstract class PaymentScreenState extends Equatable {
  const PaymentScreenState();

  @override
  List<Object> get props => [];
}

class PaymentScreenInitial extends PaymentScreenState {}

class PaymentScreenUpdating extends PaymentScreenState {}
