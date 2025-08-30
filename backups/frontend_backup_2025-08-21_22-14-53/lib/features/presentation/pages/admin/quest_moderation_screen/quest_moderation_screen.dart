import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_moderation_screen/cubit/quest_moderation_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/admin_dashboard_screen/admin_dashboard_screen.dart';

class QuestModerationScreen extends StatelessWidget {
  const QuestModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestModerationScreenCubit()..loadModerationData(),
      child:
          BlocBuilder<QuestModerationScreenCubit, QuestModerationScreenState>(
        builder: (context, state) {
          QuestModerationScreenCubit cubit =
              context.read<QuestModerationScreenCubit>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Модерация контента'),
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

  Widget _buildContent(BuildContext context, QuestModerationScreenCubit cubit,
      QuestModerationScreenState state) {
    if (state is QuestModerationScreenLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is QuestModerationScreenError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка загрузки данных модерации: ${state.message}'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => cubit.loadModerationData(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    } else if (state is QuestModerationScreenLoaded) {
      return _buildModerationContent(context, cubit, state.moderationData);
    }

    return const Center(child: Text('Неизвестное состояние'));
  }

  Widget _buildModerationContent(BuildContext context,
      QuestModerationScreenCubit cubit, Map<String, dynamic> moderationData) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Табы для разных типов модерации
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: const [
                Tab(text: 'На проверке'),
                Tab(text: 'Жалобы'),
                Tab(text: 'Отзывы'),
                Tab(text: 'Комментарии'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPendingReviewTab(context, cubit, moderationData),
                _buildComplaintsTab(context, cubit, moderationData),
                _buildReviewsTab(context, cubit, moderationData),
                _buildCommentsTab(context, cubit, moderationData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingReviewTab(BuildContext context,
      QuestModerationScreenCubit cubit, Map<String, dynamic> moderationData) {
    final pendingQuests = moderationData['pending_quests'] as List? ?? [];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: pendingQuests.length,
      itemBuilder: (context, index) {
        final quest = pendingQuests[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(quest['image'] ?? ''),
              onBackgroundImageError: (e, s) => const Icon(Icons.quiz),
            ),
            title: Text(quest['title'] ?? 'Без названия'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Автор: ${quest['author'] ?? 'Неизвестно'}'),
                Text('Дата создания: ${quest['created_at'] ?? 'Неизвестно'}'),
                Text('Статус: ${quest['status'] ?? 'На проверке'}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () =>
                      _showApproveDialog(context, cubit, quest['id']),
                  tooltip: 'Одобрить',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () =>
                      _showRejectDialog(context, cubit, quest['id']),
                  tooltip: 'Отклонить',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintsTab(BuildContext context,
      QuestModerationScreenCubit cubit, Map<String, dynamic> moderationData) {
    final complaints = moderationData['complaints'] as List? ?? [];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: const Icon(Icons.report, color: Colors.red),
            title: Text('Жалоба на: ${complaint['target'] ?? 'Неизвестно'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('От: ${complaint['reporter'] ?? 'Аноним'}'),
                Text('Причина: ${complaint['reason'] ?? 'Не указана'}'),
                Text('Дата: ${complaint['date'] ?? 'Неизвестно'}'),
                Text('Статус: ${complaint['status'] ?? 'Новая'}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'investigate':
                    _showInvestigateDialog(context, cubit, complaint['id']);
                    break;
                  case 'resolve':
                    _showResolveDialog(context, cubit, complaint['id']);
                    break;
                  case 'dismiss':
                    _showDismissDialog(context, cubit, complaint['id']);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'investigate',
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Text('Расследовать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'resolve',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Разрешить'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'dismiss',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Отклонить'),
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

  Widget _buildReviewsTab(BuildContext context,
      QuestModerationScreenCubit cubit, Map<String, dynamic> moderationData) {
    final reviews = moderationData['reviews'] as List? ?? [];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: const Icon(Icons.rate_review, color: Colors.blue),
            title: Text(
                'Отзыв на: ${review['quest_title'] ?? 'Неизвестный квест'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('От: ${review['author'] ?? 'Аноним'}'),
                Text('Рейтинг: ${review['rating'] ?? 'Не указан'}/5'),
                Text('Текст: ${review['text'] ?? 'Без текста'}'),
                Text('Дата: ${review['date'] ?? 'Неизвестно'}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'approve':
                    _showApproveReviewDialog(context, cubit, review['id']);
                    break;
                  case 'edit':
                    _showEditReviewDialog(context, cubit, review);
                    break;
                  case 'delete':
                    _showDeleteReviewDialog(context, cubit, review['id']);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'approve',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Одобрить'),
                    ],
                  ),
                ),
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
                      Text('Удалить'),
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

  Widget _buildCommentsTab(BuildContext context,
      QuestModerationScreenCubit cubit, Map<String, dynamic> moderationData) {
    final comments = moderationData['comments'] as List? ?? [];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            leading: const Icon(Icons.comment, color: Colors.grey),
            title: Text('Комментарий от: ${comment['author'] ?? 'Аноним'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('К квесту: ${comment['quest_title'] ?? 'Неизвестно'}'),
                Text('Текст: ${comment['text'] ?? 'Без текста'}'),
                Text('Дата: ${comment['date'] ?? 'Неизвестно'}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'approve':
                    _showApproveCommentDialog(context, cubit, comment['id']);
                    break;
                  case 'edit':
                    _showEditCommentDialog(context, cubit, comment);
                    break;
                  case 'delete':
                    _showDeleteCommentDialog(context, cubit, comment['id']);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'approve',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Одобрить'),
                    ],
                  ),
                ),
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
                      Text('Удалить'),
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

  // Диалоги для модерации
  void _showApproveDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int questId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Одобрение квеста'),
        content: const Text('Вы уверены, что хотите одобрить этот квест?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика одобрения квеста
              Navigator.pop(context);
            },
            child: const Text('Одобрить'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int questId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отклонение квеста'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Укажите причину отклонения:'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Причина',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              // Здесь будет логика отклонения квеста
              Navigator.pop(context);
            },
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );
  }

  void _showInvestigateDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Расследование жалобы'),
        content: const Text('Жалоба помечена для расследования.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Разрешение жалобы'),
        content: const Text('Жалоба разрешена.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDismissDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отклонение жалобы'),
        content: const Text('Жалоба отклонена.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showApproveReviewDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Одобрение отзыва'),
        content: const Text('Отзыв одобрен.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditReviewDialog(BuildContext context,
      QuestModerationScreenCubit cubit, Map<String, dynamic> review) {
    final textController = TextEditingController(text: review['text'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактирование отзыва'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Текст отзыва',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика редактирования отзыва
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteReviewDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление отзыва'),
        content: const Text('Вы уверены, что хотите удалить этот отзыв?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика удаления отзыва
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showApproveCommentDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Одобрение комментария'),
        content: const Text('Комментарий одобрен.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(BuildContext context,
      QuestModerationScreenCubit cubit, Map<String, dynamic> comment) {
    final textController = TextEditingController(text: comment['text'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактирование комментария'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Текст комментария',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика редактирования комментария
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(
      BuildContext context, QuestModerationScreenCubit cubit, int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление комментария'),
        content: const Text('Вы уверены, что хотите удалить этот комментарий?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика удаления комментария
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
