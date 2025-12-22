# PowerShell скрипт для удаления Issue #4 с доски Projects
# Issue #4 закрыта как дубликат #9

$username = "Hampfree-hub"
$projectNumber = 1  # HampfreeHub — General (Projects V2)
$itemId = 145756496  # ID элемента на доске из URL

$token = Read-Host "Введите GitHub Personal Access Token" -AsSecureString
$tokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))

$headers = @{
    "Authorization" = "Bearer $tokenPlain"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# Шаг 1: Получить информацию о проекте
Write-Host "`n📋 Получаю информацию о проекте..." -ForegroundColor Cyan
$projectUri = "https://api.github.com/users/$username/projectsV2/$projectNumber"
try {
    $project = Invoke-RestMethod -Uri $projectUri -Method Get -Headers $headers
    Write-Host "✅ Проект найден: $($project.title)" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка при получении проекта: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Попробую альтернативный метод..." -ForegroundColor Yellow
    
    # Альтернатива: через GraphQL
    $graphqlQuery = @{
        query = "query { user(login: `"$username`") { projectV2(number: $projectNumber) { id title } } }"
    } | ConvertTo-Json
    
    try {
        $graphqlResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $graphqlQuery -ContentType "application/json"
        Write-Host "✅ Проект найден через GraphQL: $($graphqlResponse.data.user.projectV2.title)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Не удалось получить проект" -ForegroundColor Red
        exit 1
    }
}

# Шаг 2: Удалить элемент с доски (Projects V2 API)
Write-Host "`n🗑️ Удаляю Issue #4 с доски..." -ForegroundColor Cyan
$deleteUri = "https://api.github.com/users/$username/projectsV2/$projectNumber/items/$itemId"
try {
    Invoke-RestMethod -Uri $deleteUri -Method Delete -Headers $headers
    Write-Host "✅ Issue #4 успешно удалена с доски!" -ForegroundColor Green
    Write-Host "`n📋 Issue остаётся закрытой в репозитории, но больше не отображается на доске." -ForegroundColor Yellow
} catch {
    Write-Host "❌ Ошибка при удалении: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n💡 Попробуй удалить вручную через GitHub UI:" -ForegroundColor Yellow
    Write-Host "https://github.com/users/Hampfree-hub/projects/1/views/1" -ForegroundColor White
    Write-Host "`nИли просто перетащи Issue #4 в колонку 'Закрыто' или удали с доски вручную." -ForegroundColor Yellow
}




