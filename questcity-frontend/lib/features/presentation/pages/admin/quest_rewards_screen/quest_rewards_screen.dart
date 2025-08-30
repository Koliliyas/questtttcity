import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_rewards_screen/cubit/quest_rewards_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/admin_dashboard_screen/admin_dashboard_screen.dart';

class QuestRewardsScreen extends StatelessWidget {
  const QuestRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestRewardsScreenCubit()..loadRewards(),
      child: BlocBuilder<QuestRewardsScreenCubit, QuestRewardsScreenState>(
        builder: (context, state) {
          QuestRewardsScreenCubit cubit =
              context.read<QuestRewardsScreenCubit>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Управление наградами'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                // Кнопка возврата к админской панели
                IconButton(
                  icon: const Icon(Icons.dashboard),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  ),
                  tooltip: 'Админ панель',
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
              child: _buildContent(context, cubit, state),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddRewardDialog(context, cubit),
              child: const Icon(Icons.add),
              tooltip: 'Добавить награду',
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuestRewardsScreenCubit cubit,
      QuestRewardsScreenState state) {
    if (state is QuestRewardsScreenLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is QuestRewardsScreenError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка загрузки наград: ${state.message}'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => cubit.loadRewards(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    } else if (state is QuestRewardsScreenLoaded) {
      return _buildRewardsContent(context, cubit, state.rewards);
    }

    return const Center(child: Text('Неизвестное состояние'));
  }

  Widget _buildRewardsContent(BuildContext context,
      QuestRewardsScreenCubit cubit, List<Map<String, dynamic>> rewards) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Табы для разных типов наград
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Кредиты'),
                Tab(text: 'Достижения'),
                Tab(text: 'Бонусы'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCreditsTab(context, cubit, rewards),
                _buildAchievementsTab(context, cubit, rewards),
                _buildBonusesTab(context, cubit, rewards),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsTab(BuildContext context, QuestRewardsScreenCubit cubit,
      List<Map<String, dynamic>> rewards) {
    final creditsRewards =
        rewards.where((r) => r['type'] == 'credits').toList();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: creditsRewards.length,
      itemBuilder: (context, index) {
        final reward = creditsRewards[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.green),
            title: Text('${reward['name'] ?? 'Без названия'}'),
            subtitle: Text(
                'Стоимость: ${reward['cost'] ?? 0}, Награда: ${reward['reward'] ?? 0}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditRewardDialog(context, cubit, reward);
                    break;
                  case 'delete':
                    _showDeleteRewardDialog(context, cubit, reward['id']);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementsTab(BuildContext context,
      QuestRewardsScreenCubit cubit, List<Map<String, dynamic>> rewards) {
    final achievementRewards =
        rewards.where((r) => r['type'] == 'achievement').toList();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: achievementRewards.length,
      itemBuilder: (context, index) {
        final reward = achievementRewards[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: Text('${reward['name'] ?? 'Без названия'}'),
            subtitle: Text(
                'Уровень: ${reward['level'] ?? 1}, Бейдж: ${reward['badge'] ?? 'Нет'}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditRewardDialog(context, cubit, reward);
                    break;
                  case 'delete':
                    _showDeleteRewardDialog(context, cubit, reward['id']);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBonusesTab(BuildContext context, QuestRewardsScreenCubit cubit,
      List<Map<String, dynamic>> rewards) {
    final bonusRewards = rewards.where((r) => r['type'] == 'bonus').toList();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: bonusRewards.length,
      itemBuilder: (context, index) {
        final reward = bonusRewards[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.orange),
            title: Text('${reward['name'] ?? 'Без названия'}'),
            subtitle: Text(
                'Тип: ${reward['bonus_type'] ?? 'Неизвестно'}, Условие: ${reward['condition'] ?? 'Нет'}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditRewardDialog(context, cubit, reward);
                    break;
                  case 'delete':
                    _showDeleteRewardDialog(context, cubit, reward['id']);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddRewardDialog(
      BuildContext context, QuestRewardsScreenCubit cubit) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить награду'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название награды',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: typeController.text.isEmpty ? null : typeController.text,
              decoration: const InputDecoration(
                labelText: 'Тип награды',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'credits', child: Text('Кредиты')),
                DropdownMenuItem(
                    value: 'achievement', child: Text('Достижение')),
                DropdownMenuItem(value: 'bonus', child: Text('Бонус')),
              ],
              onChanged: (value) {
                if (value != null) {
                  typeController.text = value;
                }
              },
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Значение',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика создания награды
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showEditRewardDialog(BuildContext context,
      QuestRewardsScreenCubit cubit, Map<String, dynamic> reward) {
    final nameController = TextEditingController(text: reward['name'] ?? '');
    final typeController = TextEditingController(text: reward['type'] ?? '');
    final valueController =
        TextEditingController(text: '${reward['value'] ?? ''}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать награду'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название награды',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Тип награды',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Значение',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика обновления награды
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRewardDialog(
      BuildContext context, QuestRewardsScreenCubit cubit, int rewardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление награды'),
        content: const Text('Вы уверены, что хотите удалить эту награду?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Здесь будет логика удаления награды
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
