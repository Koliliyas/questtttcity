import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_analytics_screen/cubit/quests_analytics_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/admin_dashboard_screen/admin_dashboard_screen.dart';
import 'package:los_angeles_quest/locator_service.dart';

class QuestsAnalyticsScreen extends StatelessWidget {
  const QuestsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestsAnalyticsScreenCubit(
        getQuestAnalyticsUC: sl(),
      )..loadAnalytics(),
      child:
          BlocBuilder<QuestsAnalyticsScreenCubit, QuestsAnalyticsScreenState>(
        builder: (context, state) {
          QuestsAnalyticsScreenCubit cubit =
              context.read<QuestsAnalyticsScreenCubit>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Аналитика квестов'),
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
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuestsAnalyticsScreenCubit cubit,
      QuestsAnalyticsScreenState state) {
    if (state is QuestsAnalyticsScreenLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is QuestsAnalyticsScreenError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка загрузки аналитики: ${state.message}'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => cubit.loadAnalytics(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    } else if (state is QuestsAnalyticsScreenLoaded) {
      return _buildAnalyticsContent(context, state.analytics);
    }

    return const Center(child: Text('Неизвестное состояние'));
  }

  Widget _buildAnalyticsContent(
      BuildContext context, Map<String, dynamic> analytics) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Основные метрики
          _buildMetricsCards(analytics),
          SizedBox(height: 24.h),

          // Статистика по категориям
          _buildCategoryStats(analytics),
          SizedBox(height: 24.h),

          // Статистика по сложности
          _buildDifficultyStats(analytics),
          SizedBox(height: 24.h),

          // Недавняя активность
          _buildRecentActivity(analytics),
          SizedBox(height: 24.h),

          // Популярные квесты
          _buildPopularQuests(analytics),
          SizedBox(height: 24.h),

          // Вовлеченность пользователей
          _buildUserEngagement(analytics),
        ],
      ),
    );
  }

  Widget _buildMetricsCards(Map<String, dynamic> analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Всего квестов',
            '${analytics['total_quests'] ?? 0}',
            Icons.quiz,
            Colors.blue,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Активных',
            '${analytics['active_quests'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Черновиков',
            '${analytics['draft_quests'] ?? 0}',
            Icons.edit_note,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
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

  Widget _buildCategoryStats(Map<String, dynamic> analytics) {
    final categoriesStats =
        analytics['categories_stats'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика по категориям',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (categoriesStats.isEmpty)
              const Text('Нет данных по категориям')
            else
              ...categoriesStats.entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyStats(Map<String, dynamic> analytics) {
    final difficultyStats =
        analytics['difficulty_stats'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика по сложности',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (difficultyStats.isEmpty)
              const Text('Нет данных по сложности')
            else
              ...difficultyStats.entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(Map<String, dynamic> analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Недавняя активность',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(analytics['recent_activity'] ?? 'Нет данных'),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularQuests(Map<String, dynamic> analytics) {
    final popularQuests = analytics['popular_quests'] as List? ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Популярные квесты',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (popularQuests.isEmpty)
              const Text('Нет данных о популярных квестах')
            else
              ...popularQuests.map((quest) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text('• $quest'),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEngagement(Map<String, dynamic> analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вовлеченность пользователей',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(analytics['user_engagement'] ?? 'Нет данных'),
          ],
        ),
      ),
    );
  }
}
