# Скрипт для сборки простого APK QuestCity
Write-Host "🚀 Сборка простого APK QuestCity" -ForegroundColor Cyan

# Переключаемся на продакшен
Write-Host "🔄 Переключение на продакшен конфигурацию..." -ForegroundColor Yellow
Copy-Item env.production .env

# Очищаем проект
Write-Host "🧹 Очистка проекта..." -ForegroundColor Yellow
flutter clean

# Получаем зависимости
Write-Host "📦 Получение зависимостей..." -ForegroundColor Yellow
flutter pub get

# Собираем debug APK (легче установить)
Write-Host "🔨 Сборка debug APK..." -ForegroundColor Yellow
flutter build apk --debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Debug APK успешно собран!" -ForegroundColor Green
    Write-Host "📱 Файл: build/app/outputs/flutter-apk/app-debug.apk" -ForegroundColor Cyan
    Write-Host "🌐 API URL: http://questcity.ru/api/v1/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔧 Для установки:" -ForegroundColor Yellow
    Write-Host "   1. Скопируйте файл на телефон" -ForegroundColor White
    Write-Host "   2. Включите 'Установка из неизвестных источников'" -ForegroundColor White
    Write-Host "   3. Установите APK" -ForegroundColor White
} else {
    Write-Host "❌ Ошибка сборки APK!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Для возврата к разработке выполните:" -ForegroundColor Cyan
Write-Host "   Copy-Item env.development .env" -ForegroundColor White

