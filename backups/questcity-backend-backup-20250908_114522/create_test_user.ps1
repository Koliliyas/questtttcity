# Создание тестового пользователя для QuestCity

Write-Host "🔧 Создание тестового пользователя..." -ForegroundColor Cyan

# Данные тестового пользователя
$userData = @{
    username = "testuser"
    email = "testuser@questcity.com"
    password1 = "TestPass123!"
    password2 = "TestPass123!"
    firstName = "Test"
    lastName = "User"
} | ConvertTo-Json

Write-Host "📝 Данные пользователя:" -ForegroundColor Yellow
Write-Host "   Username: testuser" -ForegroundColor Green
Write-Host "   Email: testuser@questcity.com" -ForegroundColor Green
Write-Host "   Password: TestPass123!" -ForegroundColor Green

# Регистрация пользователя
try {
    Write-Host "`n📤 Регистрация пользователя..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/auth/register" -Method POST -Body $userData -ContentType "application/json"
    Write-Host "✅ Пользователь создан успешно! (Статус: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка создания пользователя: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Тест авторизации
try {
    Write-Host "`n🔐 Тест авторизации..." -ForegroundColor Yellow
    $loginBody = "login=testuser@questcity.com&password=TestPass123!"
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/auth/login" -Method POST -Body $loginBody -ContentType "application/x-www-form-urlencoded"
    Write-Host "✅ Авторизация успешна! (Статус: $($loginResponse.StatusCode))" -ForegroundColor Green
    
    # Получаем токен
    $token = ($loginResponse.Content | ConvertFrom-Json).accessToken
    Write-Host "   Token получен: $($token.Length) символов" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка авторизации: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Тестовый пользователь готов!" -ForegroundColor Green
Write-Host "📱 Используйте эти данные для входа в приложение:" -ForegroundColor Yellow
Write-Host "   Email: testuser@questcity.com" -ForegroundColor Cyan
Write-Host "   Password: TestPass123!" -ForegroundColor Cyan 