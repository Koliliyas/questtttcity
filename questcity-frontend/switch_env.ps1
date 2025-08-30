# Скрипт для переключения между окружениями QuestCity Frontend
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("development", "production")]
    [string]$Environment
)

Write-Host "🔄 Переключение окружения QuestCity Frontend на: $Environment" -ForegroundColor Cyan

# Определяем файлы
$devFile = "env.development"
$prodFile = "env.production"
$targetFile = ".env"

# Проверяем существование файлов
if (!(Test-Path $devFile)) {
    Write-Host "❌ Файл $devFile не найден!" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $prodFile)) {
    Write-Host "❌ Файл $prodFile не найден!" -ForegroundColor Red
    exit 1
}

# Создаем резервную копию текущего .env
if (Test-Path $targetFile) {
    $backupFile = ".env.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $targetFile $backupFile
    Write-Host "📦 Создана резервная копия: $backupFile" -ForegroundColor Yellow
}

# Копируем нужную конфигурацию
if ($Environment -eq "development") {
    Copy-Item $devFile $targetFile
    Write-Host "✅ Переключено на DEVELOPMENT (localhost:8000)" -ForegroundColor Green
    Write-Host "   📍 API URL: http://localhost:8000/api/v1/" -ForegroundColor Gray
} else {
    Copy-Item $prodFile $targetFile
    Write-Host "✅ Переключено на PRODUCTION (questcity.ru)" -ForegroundColor Green
    Write-Host "   📍 API URL: http://questcity.ru/api/v1.0/" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔧 Следующие шаги:" -ForegroundColor Cyan
Write-Host "   1. Перезапустите Flutter: flutter clean && flutter pub get" -ForegroundColor White
Write-Host "   2. Запустите приложение: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "📋 Текущая конфигурация:" -ForegroundColor Cyan
Get-Content $targetFile | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }

