import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

class OrderInventoryBody extends StatelessWidget {
  final MerchItem merchItem;
  const OrderInventoryBody({super.key, required this.onButtonTap, required this.merchItem});

  final Function() onButtonTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Text(
            merchItem.description,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Image.network(merchItem.image,
                width: MediaQuery.of(context).size.width, height: 192.h, fit: BoxFit.cover),
          ),
          SizedBox(height: 22.h),
          CustomButton(title: 'Order \$${merchItem.price}', onTap: onButtonTap),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
