# 🔧 ОТЧЕТ: НЕОБХОДИМЫЕ ИЗМЕНЕНИЯ В API

## 📋 ПРОБЛЕМА
**Mentor Preferences** не работает корректно при редактировании квеста:
- ✅ **Создание:** Boolean переключатель работает
- ❌ **Редактирование:** Всегда отображается "No" 
- ❌ **Причина:** `mentor_preference` не возвращается из API

## 🔍 АНАЛИЗ ТЕКУЩЕГО СОСТОЯНИЯ

### 1. **База данных** ✅
```sql
-- Поле существует в модели Quest
mentor_preference: Mapped[str] = mapped_column(String(1024))
```

### 2. **DTO (Data Transfer Objects)** ✅
```python
# QuestCreateDTO
mentor_preference: str

# QuestUpdateDTO  
mentor_preference: Optional[str]
```

### 3. **Схемы создания** ✅
```python
# QuestCreteSchema
mentor_preference: str = Field(default="")
```

### 4. **Схемы чтения** ❌
```python
# QuestReadSchema - ОТСУТСТВУЕТ mentor_preference!
class QuestReadSchema(BaseSchema):
    id: int
    title: str
    # ... другие поля
    # mentor_preference: str  # ❌ НЕТ!
```

### 5. **API Endpoints** ❌
```python
# GET /quests/{quest_id} - возвращает QuestReadSchema
# QuestReadSchema не содержит mentor_preference
```

## 🛠️ НЕОБХОДИМЫЕ ИЗМЕНЕНИЯ

### **1. Обновить QuestReadSchema**
**Файл:** `src/api/modules/quest/schemas/quest.py`

```python
class QuestReadSchema(BaseSchema):
    # ... существующие поля ...
    
    # ДОБАВИТЬ:
    mentor_preference: Optional[str] = Field(default="", description="Mentor preference setting")
```

### **2. Обновить API Endpoints**
**Файл:** `src/api/modules/quest/routers/quests.py`

#### **A. GET /quests/{quest_id}**
```python
@router.get("/{quest_id}", response_model=QuestReadSchema)
async def get_quest(quest_id: int, ...) -> QuestReadSchema:
    # ... существующий код ...
    
    return QuestReadSchema(
        # ... существующие поля ...
        mentor_preference=quest.mentor_preference,  # ДОБАВИТЬ
    )
```

#### **B. GET /quests/working/{quest_id}**
```python
@router.get("/working/{quest_id}")
async def get_quest_working(quest_id: int, ...):
    # ... существующий код ...
    
    return {
        # ... существующие поля ...
        "mentor_preference": quest.mentor_preference,  # ДОБАВИТЬ
    }
```

#### **C. GET /quests/get-quest/{quest_id}**
```python
@router.get("/get-quest/{quest_id}")
async def get_quest_simple(quest_id: int, ...):
    # ... существующий код ...
    
    return {
        # ... существующие поля ...
        "mentor_preference": quest.mentor_preference,  # ДОБАВИТЬ
    }
```

#### **D. GET /quests/admin/{quest_id}**
```python
@router.get("/admin/{quest_id}", response_model=QuestReadSchema)
async def get_admin_quest_detail(quest_id: int, ...) -> QuestReadSchema:
    # ... существующий код ...
    
    return QuestReadSchema(
        # ... существующие поля ...
        mentor_preference=quest.mentor_preference,  # ДОБАВИТЬ
    )
```

### **3. Обновить Frontend Model**
**Файл:** `questcity-frontend/lib/features/data/models/quests/quest_model.dart`

```dart
class QuestModel extends Equatable {
  // ... существующие поля ...
  
  // ДОБАВИТЬ:
  final String? mentorPreference;
  
  const QuestModel({
    // ... существующие параметры ...
    this.mentorPreference,
  });
  
  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      // ... существующие поля ...
      mentorPreference: json['mentor_preference'],  // ДОБАВИТЬ
    );
  }
}
```

### **4. Обновить Frontend Cubit**
**Файл:** `questcity-frontend/lib/features/presentation/pages/common/quest_edit/cubit/edit_quest_screen_cubit.dart`

```dart
// В методе loadQuestData()
bool hasMentor = quest.mentorPreference == 'mentor_required';  // ИСПРАВИТЬ
```

## 📊 ПРИОРИТЕТ ИЗМЕНЕНИЙ

### **🔥 ВЫСОКИЙ ПРИОРИТЕТ**
1. ✅ **QuestReadSchema** - добавить `mentor_preference`
2. ✅ **API Endpoints** - включить `mentor_preference` в ответы
3. ✅ **Frontend Model** - добавить поле в `QuestModel`

### **⚡ СРЕДНИЙ ПРИОРИТЕТ**
4. ✅ **Frontend Cubit** - использовать реальное значение

### **📝 НИЗКИЙ ПРИОРИТЕТ**
5. ✅ **Документация** - обновить API docs
6. ✅ **Тесты** - добавить тесты для нового поля

## 🎯 ОЖИДАЕМЫЙ РЕЗУЛЬТАТ

После внесения изменений:
- ✅ **Создание:** Boolean переключатель работает
- ✅ **Редактирование:** Правильно отображается сохраненное значение
- ✅ **API:** Возвращает `mentor_preference` в ответах
- ✅ **Frontend:** Загружает и отображает правильное значение

## 🚀 ПЛАН ВНЕДРЕНИЯ

1. **Backend изменения** (5 минут)
   - Обновить `QuestReadSchema`
   - Обновить API endpoints

2. **Frontend изменения** (5 минут)
   - Обновить `QuestModel`
   - Обновить `loadQuestData()`

3. **Тестирование** (10 минут)
   - Создать квест с mentor_preference
   - Отредактировать квест
   - Проверить отображение

**Общее время:** ~20 минут

















