# Простой тест API QuestCity Backend

Write-Host "🧪 Тестирование API QuestCity Backend" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# 1. Проверка health endpoint
Write-Host "`n1. Проверка health endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/health/" -Method GET
    Write-Host "✅ Health check: $($health.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Регистрация пользователя
Write-Host "`n2. Регистрация пользователя..." -ForegroundColor Yellow
$userData = @{
    username = "testuser"
    email = "testuser@questcity.com"
    password1 = "TestPass123!"
    password2 = "TestPass123!"
    firstName = "Test"
    lastName = "User"
} | ConvertTo-Json

try {
    $register = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/auth/register" -Method POST -Body $userData -ContentType "application/json"
    Write-Host "✅ Регистрация: $($register.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Регистрация failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Авторизация
Write-Host "`n3. Авторизация..." -ForegroundColor Yellow
$loginBody = "login=testuser@questcity.com&password=TestPass123!"
try {
    $login = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/auth/login" -Method POST -Body $loginBody -ContentType "application/x-www-form-urlencoded"
    $token = ($login.Content | ConvertFrom-Json).accessToken
    Write-Host "✅ Авторизация: $($login.StatusCode)" -ForegroundColor Green
    Write-Host "   Token получен: $($token.Length) символов" -ForegroundColor Green
} catch {
    Write-Host "❌ Авторизация failed: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# 4. Тест защищенного endpoint
Write-Host "`n4. Тест защищенного endpoint..." -ForegroundColor Yellow
try {
    $protected = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/quests/" -Method GET -Headers @{ "Authorization" = "Bearer $token" }
    Write-Host "✅ Защищенный endpoint: $($protected.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Защищенный endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Тестирование завершено!" -ForegroundColor Green 