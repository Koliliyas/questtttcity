import 'package:los_angeles_quest/features/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  bool _isQuestPurchased = false;

  @override
  Future<void> purchaseQuest() async {
    // Логика покупки
    _isQuestPurchased = true;
  }

  @override
  Future<bool> isQuestPurchased() async {
    // Проверка состояния покупки
    return _isQuestPurchased;
  }
}
