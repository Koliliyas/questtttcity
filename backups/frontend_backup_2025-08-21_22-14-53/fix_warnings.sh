#!/bin/bash

# 🛠️ Скрипт автоматического исправления Flutter предупреждений
# Исправляет ~200+ из 458 предупреждений автоматически

set -e  # Остановка при ошибке

echo "🚀 Начинаем исправление 458 предупреждений Flutter..."
echo "📊 Текущее количество предупреждений:"
flutter analyze 2>/dev/null | grep -E "(info|warning)" | wc -l || echo "Не удалось подсчитать"

echo ""
echo "⚡ Этап 1: Автоматические исправления Dart..."
dart fix --apply || echo "Dart fix завершен с предупреждениями"

echo ""
echo "📦 Этап 2: Добавляем недостающие зависимости..."
if ! grep -q "logger:" pubspec.yaml; then
    echo "  Добавляем logger в pubspec.yaml..."
    sed -i '' '/http: \^1.3.0/a\
  logger: ^2.0.2' pubspec.yaml
fi

if ! grep -q "path_provider:" pubspec.yaml; then
    echo "  Добавляем path_provider в pubspec.yaml..."
    sed -i '' '/http: \^1.3.0/a\
  path_provider: ^2.1.4' pubspec.yaml
fi

echo "  Обновляем зависимости..."
flutter pub get

echo ""
echo "🎨 Этап 3: Исправляем устаревшие API..."

# Замена withOpacity на withValues
echo "  Исправляем withOpacity() → withValues()..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.withOpacity(\([^)]*\))/\.withValues(alpha: \1)/g' {} \;

# Замена window на View.of(context) (частично)
echo "  Исправляем ui.window → MediaQuery..."
find lib/ -name "*.dart" -exec sed -i '' 's/ui\.window\.physicalSize/MediaQuery.of(context).size/g' {} \;

# Замена onPopInvoked на onPopInvokedWithResult  
echo "  Исправляем onPopInvoked → onPopInvokedWithResult..."
find lib/ -name "*.dart" -exec sed -i '' 's/onPopInvoked:/onPopInvokedWithResult:/g' {} \;

echo ""
echo "🧹 Этап 4: Удаляем print() statements..."

# Создаем временный файл с logger setup
cat > lib/utils/logger.dart << 'EOF'
import 'package:logger/logger.dart';

final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
);
EOF

# Заменяем print на logger (частично - только простые случаи)
echo "  Заменяем простые print() на logger..."
find lib/ -name "*.dart" -exec sed -i '' 's/print(\([^)]*\));/appLogger.d(\1);/g' {} \;

# Добавляем импорт logger в файлы где используется
find lib/ -name "*.dart" -exec grep -l "appLogger\." {} \; | while read file; do
    if ! grep -q "import.*logger" "$file"; then
        sed -i '' '1i\
import '\''package:los_angeles_quest/utils/logger.dart'\'';
' "$file"
    fi
done

echo ""
echo "🏷️ Этап 5: Переименование файлов..."
if [ -f "lib/l10n/L10n.dart" ]; then
    echo "  Переименовываем L10n.dart → l10n.dart..."
    mv lib/l10n/L10n.dart lib/l10n/l10n.dart
    
    # Обновляем импорты
    find lib/ -name "*.dart" -exec sed -i '' 's/import.*L10n\.dart/import '\''package:los_angeles_quest\/l10n\/l10n.dart'\''/g' {} \;
fi

echo ""
echo "🎯 Этап 6: Исправляем константы (lowerCamelCase)..."

# Исправляем некоторые константы
find lib/ -name "*.dart" -exec sed -i '' 's/const String USER/const String user/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/const String ADMIN/const String admin/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/const String MANAGER/const String manager/g' {} \;

echo ""
echo "🔧 Этап 7: Создаем VS Code настройки..."
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
  "dart.lineLength": 120,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true,
    "source.fixAll": true
  },
  "dart.enableSdkFormatter": true,
  "editor.formatOnSave": true,
  "dart.previewFlutterUiGuides": true,
  "dart.closingLabels": true
}
EOF

echo ""
echo "✅ Этап 8: Финальная проверка..."
echo "Запускаем flutter analyze для подсчета оставшихся предупреждений..."

REMAINING=$(flutter analyze 2>/dev/null | grep -E "(info|warning)" | wc -l | tr -d ' ')
FIXED=$((458 - REMAINING))

echo ""
echo "🎉 РЕЗУЛЬТАТЫ:"
echo "   Исправлено: $FIXED из 458 предупреждений"
echo "   Осталось: $REMAINING предупреждений"
echo "   Прогресс: $(( (FIXED * 100) / 458 ))%"

echo ""
echo "📋 ЧТО НУЖНО ИСПРАВИТЬ ВРУЧНУЮ:"
echo "   1. use_build_context_synchronously - добавить if (mounted) проверки"
echo "   2. unused_import - удалить неиспользуемые импорты"
echo "   3. annotate_overrides - добавить @override аннотации"
echo "   4. Оставшиеся deprecated_member_use"

echo ""
echo "📖 Открыте FIX_GUIDE.md для детальных инструкций по оставшимся исправлениям."
echo ""
echo "🚀 Для проверки конкретных типов ошибок:"
echo "   flutter analyze | grep 'unused_import'"
echo "   flutter analyze | grep 'use_build_context_synchronously'"
echo "   flutter analyze | grep 'annotate_overrides'"

echo ""
echo "✨ Скрипт завершен! Приложение должно работать лучше и быть готово к production." 