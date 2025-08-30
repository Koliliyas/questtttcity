# Техническое задание: Проект Questcity

## Анализ текущих проблем

### 1. Проблемы с запуском
- **PowerShell не может найти `./quick_start.sh`** - это bash скрипт, который не работает в PowerShell
- **Нужно использовать Git Bash или WSL** для запуска bash скриптов

### 2. Проблемы с S3 в Backend
- **S3Repository не зарегистрирован в DI контейнере**
- **API возвращает `INTERNAL_SERVER_ERROR`** из-за отсутствия S3 провайдера
- **Логи показывают**: `Provider for type S3Repository not found`

### 3. Проблемы с данными
- **База данных содержит тестовые данные** (3 квеста, 4 категории)
- **Пользователь admin верифицирован** с правами администратора
- **API не может получить данные** из-за S3 ошибок

### 4. Проблемы с Frontend
- **RangeError в home_screen.dart** - исправлено
- **Черный текст ошибок** - исправлено
- **"Failed" ошибки** - связаны с S3 проблемами в backend

## Техническое задание

### 1. Исправление проблем с S3

#### 1.1 Создание MockS3Repository
```python
# src/core/repositories/mock_s3.py
class MockS3Repository(BaseFileRepository):
    async def upload_file(self, release: str, file_data: str, context: str = "default", filename: str = None) -> str:
        return f"mock://localhost/mock/{release}/{filename or 'mock_file'}"
    
    async def delete_file(self, path: str) -> None:
        pass
```

#### 1.2 Обновление DI модулей
```python
# src/core/di/modules/default.py
def get_s3_repository():
    if os.getenv("ENVIRONMENT", "development") == "production":
        return S3Repository
    else:
        return MockS3Repository

PROVIDERS: Providers = [
    aioinject.Scoped(EmailSenderService),
    aioinject.Scoped(get_s3_repository()),
]
```

#### 1.3 Обновление сервисов квестов
```python
# src/core/quest/services.py
def create_quest_service():
    if os.getenv("ENVIRONMENT", "development") == "production":
        return QuestService
    else:
        return MockQuestService
```

### 2. Исправление проблем с запуском

#### 2.1 Создание PowerShell скрипта
```powershell
# quick_start.ps1
param(
    [string]$Action = "start"
)

switch ($Action) {
    "start" {
        Write-Host "Starting Questcity Backend..."
        cd questcity-backend
        poetry run python -m uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
    }
    "stop" {
        Write-Host "Stopping Questcity Backend..."
        Get-Process | Where-Object {$_.ProcessName -like "*python*" -and $_.CommandLine -like "*uvicorn*"} | Stop-Process
    }
    "status" {
        Write-Host "Checking Questcity Backend status..."
        $processes = Get-Process | Where-Object {$_.ProcessName -like "*python*"}
        if ($processes) {
            Write-Host "Backend is running"
        } else {
            Write-Host "Backend is not running"
        }
    }
}
```

#### 2.2 Обновление quick_start.sh для Windows
```bash
#!/bin/bash
# Добавить проверку ОС
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows с Git Bash
    poetry run python -m uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
else
    # Linux/Mac
    poetry run python -m uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
fi
```

### 3. Исправление Frontend проблем

#### 3.1 Обновление home_screen.dart
```dart
// Улучшенная обработка ошибок
if (cubit!.navigatorStack.isNotEmpty) {
    return List.generate(
        cubit!.navigatorStack.length,
        (index) => BottomNavigationBarTile(
            icon: cubit!.iconsPaths.isNotEmpty 
                ? cubit!.iconsPaths[index] 
                : 'assets/icons/home.svg',
            title: cubit!.iconsNames.isNotEmpty 
                ? cubit!.iconsNames[index] 
                : 'Home',
            // ... остальной код
        ),
    );
}
```

#### 3.2 Обновление quests_screen_cubit.dart
```dart
// Улучшенная обработка ошибок API
Future<void> loadData() async {
    try {
        emit(QuestsScreenLoading());
        
        final categories = await _loadCategories();
        final quests = await _loadQuests();
        
        emit(QuestsScreenLoaded(
            categoriesList: categories,
            questsList: quests,
            fullList: quests,
            selectedIndexes: {},
            countFilters: 0,
        ));
    } catch (e) {
        // Вместо ошибки, показываем пустые данные
        emit(QuestsScreenLoaded(
            categoriesList: [],
            questsList: QuestListModel(items: []),
            fullList: QuestListModel(items: []),
            selectedIndexes: {},
            countFilters: 0,
        ));
    }
}
```

### 4. Создание функций создания и редактирования квестов

#### 4.1 Backend API endpoints
```python
# src/api/modules/quest/routers/quests.py

@router.post("/quests/", response_model=QuestResponse)
async def create_quest(
    quest_data: QuestCreateDTO,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Создание нового квеста"""
    return await quest_service.create_quest(quest_data)

@router.put("/quests/{quest_id}", response_model=QuestResponse)
async def update_quest(
    quest_id: int,
    quest_data: QuestUpdateDTO,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Обновление существующего квеста"""
    return await quest_service.update_quest(quest_id, quest_data)

@router.delete("/quests/{quest_id}")
async def delete_quest(
    quest_id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(require_edit_quests)
):
    """Удаление квеста"""
    return await quest_service.delete_quest(quest_id)
```

#### 4.2 Frontend формы создания/редактирования
```dart
// lib/features/presentation/pages/quests/create_quest_screen.dart
class CreateQuestScreen extends StatefulWidget {
  @override
  _CreateQuestScreenState createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать квест')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Название квеста'),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Введите название квеста';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Описание'),
              maxLines: 3,
            ),
            ElevatedButton(
              onPressed: _createQuest,
              child: Text('Создать квест'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _createQuest() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Вызов API для создания квеста
    }
  }
}
```

### 5. План реализации

#### Этап 1: Исправление S3 проблем (1-2 часа)
1. Создать MockS3Repository
2. Обновить DI модули
3. Протестировать API endpoints

#### Этап 2: Исправление проблем запуска (30 минут)
1. Создать PowerShell скрипт
2. Обновить bash скрипт для Windows
3. Протестировать запуск

#### Этап 3: Улучшение Frontend (2-3 часа)
1. Обновить обработку ошибок
2. Добавить индикаторы загрузки
3. Улучшить UX

#### Этап 4: Создание функций CRUD (4-6 часов)
1. Создать API endpoints
2. Создать Frontend формы
3. Добавить валидацию
4. Протестировать функциональность

### 6. Требования к тестированию

#### 6.1 Backend тесты
- Тестирование API endpoints
- Тестирование MockS3Repository
- Тестирование обработки ошибок

#### 6.2 Frontend тесты
- Тестирование форм создания/редактирования
- Тестирование обработки ошибок
- Тестирование навигации

### 7. Документация

#### 7.1 API документация
- Swagger/OpenAPI документация
- Примеры запросов/ответов
- Коды ошибок

#### 7.2 Пользовательская документация
- Инструкция по запуску
- Руководство пользователя
- Troubleshooting

### 8. Критерии приемки

#### 8.1 Backend
- [ ] API возвращает данные без ошибок S3
- [ ] Все endpoints работают корректно
- [ ] Обработка ошибок реализована
- [ ] Тесты проходят успешно

#### 8.2 Frontend
- [ ] Приложение запускается без ошибок
- [ ] Квесты отображаются корректно
- [ ] Формы создания/редактирования работают
- [ ] UX улучшен

#### 8.3 Интеграция
- [ ] Frontend и Backend работают вместе
- [ ] Данные передаются корректно
- [ ] Ошибки обрабатываются на всех уровнях

### 9. Риски и митигация

#### 9.1 Технические риски
- **Риск**: S3 проблемы могут быть глубже
- **Митигация**: Полное отключение S3 для разработки

#### 9.2 Риски совместимости
- **Риск**: PowerShell vs Bash проблемы
- **Митигация**: Создание кроссплатформенных скриптов

#### 9.3 Риски производительности
- **Риск**: MockS3Repository может быть медленным
- **Митигация**: Оптимизация и кэширование

### 10. Заключение

Это техническое задание покрывает все основные проблемы проекта и предоставляет четкий план их решения. Реализация должна быть выполнена поэтапно с тестированием на каждом этапе.

























