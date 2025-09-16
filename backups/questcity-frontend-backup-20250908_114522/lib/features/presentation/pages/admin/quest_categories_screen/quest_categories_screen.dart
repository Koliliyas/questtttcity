import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_categories_screen/cubit/quest_categories_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/admin_dashboard_screen/admin_dashboard_screen.dart';
import 'package:los_angeles_quest/locator_service.dart';

class QuestCategoriesScreen extends StatelessWidget {
  const QuestCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestCategoriesScreenCubit(
        getAllCategoriesUC: sl(),
      )..loadCategories(),
      child:
          BlocBuilder<QuestCategoriesScreenCubit, QuestCategoriesScreenState>(
        builder: (context, state) {
          QuestCategoriesScreenCubit cubit =
              context.read<QuestCategoriesScreenCubit>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Управление категориями'),
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
              onPressed: () => _showAddCategoryDialog(context, cubit),
              child: const Icon(Icons.add),
              tooltip: 'Добавить категорию',
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuestCategoriesScreenCubit cubit,
      QuestCategoriesScreenState state) {
    if (state is QuestCategoriesScreenLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is QuestCategoriesScreenError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка загрузки категорий: ${state.message}'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => cubit.loadCategories(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    } else if (state is QuestCategoriesScreenLoaded) {
      return _buildCategoriesContent(context, cubit, state.categories);
    }

    return const Center(child: Text('Неизвестное состояние'));
  }

  Widget _buildCategoriesContent(BuildContext context,
      QuestCategoriesScreenCubit cubit, List<Map<String, dynamic>> categories) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(category['image'] ?? ''),
              onBackgroundImageError: (e, s) => const Icon(Icons.category),
            ),
            title: Text(category['name'] ?? 'Без названия'),
            subtitle: Text(category['description'] ?? 'Описание отсутствует'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditCategoryDialog(context, cubit, category);
                    break;
                  case 'delete':
                    _showDeleteCategoryDialog(context, cubit, category['id']);
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

  void _showAddCategoryDialog(
      BuildContext context, QuestCategoriesScreenCubit cubit) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить категорию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название категории',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: 'URL изображения',
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
              // Здесь будет логика создания категории
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context,
      QuestCategoriesScreenCubit cubit, Map<String, dynamic> category) {
    final nameController = TextEditingController(text: category['name'] ?? '');
    final descriptionController =
        TextEditingController(text: category['description'] ?? '');
    final imageController =
        TextEditingController(text: category['image'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать категорию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название категории',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: 'URL изображения',
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
              // Здесь будет логика обновления категории
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(
      BuildContext context, QuestCategoriesScreenCubit cubit, int categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление категории'),
        content: const Text('Вы уверены, что хотите удалить эту категорию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Здесь будет логика удаления категории
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
