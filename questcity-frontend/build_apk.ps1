# Скрипт для сборки APK QuestCity с продакшен конфигурацией
Write-Host "🚀 Сборка APK QuestCity для продакшена" -ForegroundColor Cyan

# Переключаемся на продакшен
Write-Host "🔄 Переключение на продакшен конфигурацию..." -ForegroundColor Yellow
& "$PSScriptRoot\switch_env.ps1" -Environment production

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка переключения окружения!" -ForegroundColor Red
    exit 1
}

# Очищаем и получаем зависимости
Write-Host "🧹 Очистка проекта..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Получение зависимостей..." -ForegroundColor Yellow
flutter pub get

# Собираем APK
Write-Host "🔨 Сборка APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK успешно собран!" -ForegroundColor Green
    Write-Host "📱 Файл: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Cyan
    Write-Host "🌐 API URL: http://questcity.ru/api/v1.0/" -ForegroundColor Cyan
} else {
    Write-Host "❌ Ошибка сборки APK!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Для возврата к разработке выполните:" -ForegroundColor Cyan
Write-Host "   .\switch_env.ps1 -Environment development" -ForegroundColor White

