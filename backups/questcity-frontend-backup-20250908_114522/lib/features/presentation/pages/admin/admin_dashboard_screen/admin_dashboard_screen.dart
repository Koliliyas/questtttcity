import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_list_screen/quests_list_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_analytics_screen/quests_analytics_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_categories_screen/quest_categories_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_rewards_screen/quest_rewards_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_moderation_screen/quest_moderation_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админская панель'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Paths.backgroundGradient1Path),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: _buildDashboardContent(context),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'Управление системой квестов',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Выберите раздел для управления',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 32.h),

          // Основные функции
          _buildSectionTitle('Основные функции'),
          SizedBox(height: 16.h),
          _buildFunctionGrid(context, [
            {
              'title': 'Управление квестами',
              'description': 'Создание, редактирование, удаление квестов',
              'icon': Icons.quiz,
              'color': Colors.blue,
              'onTap': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestsListScreen()),
                  ),
            },
            {
              'title': 'Аналитика',
              'description': 'Статистика и аналитика по квестам',
              'icon': Icons.analytics,
              'color': Colors.green,
              'onTap': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestsAnalyticsScreen()),
                  ),
            },
            {
              'title': 'Категории',
              'description': 'Управление категориями квестов',
              'icon': Icons.category,
              'color': Colors.orange,
              'onTap': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestCategoriesScreen()),
                  ),
            },
            {
              'title': 'Награды',
              'description': 'Система наград и достижений',
              'icon': Icons.emoji_events,
              'color': Colors.amber,
              'onTap': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestRewardsScreen()),
                  ),
            },
          ]),

          SizedBox(height: 32.h),

          // Модерация и безопасность
          _buildSectionTitle('Модерация и безопасность'),
          SizedBox(height: 16.h),
          _buildFunctionGrid(context, [
            {
              'title': 'Модерация контента',
              'description':
                  'Проверка и модерация квестов, отзывов, комментариев',
              'icon': Icons.security,
              'color': Colors.red,
              'onTap': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestModerationScreen()),
                  ),
            },
            {
              'title': 'Жалобы',
              'description': 'Обработка жалоб пользователей',
              'icon': Icons.report,
              'color': Colors.purple,
              'onTap': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestModerationScreen()),
                  ),
            },
          ]),

          SizedBox(height: 32.h),

          // Дополнительные функции
          _buildSectionTitle('Дополнительные функции'),
          SizedBox(height: 16.h),
          _buildFunctionGrid(context, [
            {
              'title': 'Массовые операции',
              'description': 'Массовое управление квестами',
              'icon': Icons.select_all,
              'color': Colors.indigo,
              'onTap': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestsListScreen()),
                  ),
            },
            {
              'title': 'Экспорт данных',
              'description': 'Экспорт статистики и отчетов',
              'icon': Icons.download,
              'color': Colors.teal,
              'onTap': () {
                // Пока заглушка
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Функция экспорта в разработке')),
                );
              },
            },
          ]),

          SizedBox(height: 32.h),

          // Статистика
          _buildSectionTitle('Быстрая статистика'),
          SizedBox(height: 16.h),
          _buildQuickStats(context),

          SizedBox(height: 32.h),

          // Последние действия
          _buildSectionTitle('Последние действия'),
          SizedBox(height: 16.h),
          _buildRecentActions(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFunctionGrid(
      BuildContext context, List<Map<String, dynamic>> functions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: functions.length,
      itemBuilder: (context, index) {
        final function = functions[index];
        return _buildFunctionCard(function);
      },
    );
  }

  Widget _buildFunctionCard(Map<String, dynamic> function) {
    return Card(
      elevation: 8,
      child: InkWell(
        onTap: function['onTap'],
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                function['color'].withOpacity(0.1),
                function['color'].withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                function['icon'],
                size: 48.w,
                color: function['color'],
              ),
              SizedBox(height: 16.h),
              Text(
                function['title'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                function['description'],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Всего квестов',
            '156',
            Icons.quiz,
            Colors.blue,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            'Активных',
            '142',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            'На проверке',
            '8',
            Icons.pending,
            Colors.orange,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            'Жалоб',
            '3',
            Icons.report,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.w),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActions(BuildContext context) {
    final recentActions = <Map<String, dynamic>>[
      {
        'action': 'Создан новый квест',
        'details': 'Квест "Приключения в городе"',
        'time': '2 минуты назад',
        'icon': Icons.add,
        'color': Colors.green,
      },
      {
        'action': 'Одобрен квест',
        'details': 'Квест "Детективная история"',
        'time': '15 минут назад',
        'icon': Icons.check,
        'color': Colors.blue,
      },
      {
        'action': 'Получена жалоба',
        'details': 'На комментарий пользователя',
        'time': '1 час назад',
        'icon': Icons.report,
        'color': Colors.red,
      },
      {
        'action': 'Обновлена категория',
        'details': 'Категория "Приключения"',
        'time': '2 часа назад',
        'icon': Icons.edit,
        'color': Colors.orange,
      },
    ];

    return Column(
      children: recentActions
          .map((action) => Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (action['color'] as Color).withOpacity(0.1),
                    child: Icon(action['icon'] as IconData,
                        color: action['color'] as Color),
                  ),
                  title: Text(action['action'] as String),
                  subtitle: Text(action['details'] as String),
                  trailing: Text(
                    action['time'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
