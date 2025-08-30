import 'package:los_angeles_quest/features/repositories/purchase_repository.dart';

class PurchaseUseCase {
  final PurchaseRepository repository;

  PurchaseUseCase(this.repository);

  Future<void> purchaseQuest() async {
    await repository.purchaseQuest();
  }

  Future<bool> isQuestPurchased() async {
    return await repository.isQuestPurchased();
  }
}
