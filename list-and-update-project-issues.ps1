# Скрипт для получения списка Issues с GitHub Projects доски и обновления их статуса
# Использование: .\list-and-update-project-issues.ps1

# Настройки
$username = "Hampfree-hub"
$projectNumber = 1
$repo = "Hampfree-hub/marketlab-academy"

# Получаем токен из приватного файла
$tokenFile = "D:\Projects\HampfreeBlog-Private\.github-token"
if (-not (Test-Path $tokenFile)) {
    Write-Host "❌ ОШИБКА: Файл с токеном не найден: $tokenFile" -ForegroundColor Red
    Write-Host "Убедитесь, что файл существует в приватном репозитории" -ForegroundColor Yellow
    exit 1
}
$token = (Get-Content $tokenFile -Raw -Encoding UTF8).Trim()
if (-not $token) {
    Write-Host "❌ ОШИБКА: Токен пустой или не может быть прочитан" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "📋 Получение списка Issues с доски проекта..." -ForegroundColor Cyan

# Шаг 1: Получаем ID проекта и поле Status
$projectQueryBody = @{
    query = "query { user(login: `"$username`") { projectV2(number: $projectNumber) { id fields(first: 20) { nodes { ... on ProjectV2Field { id name } ... on ProjectV2SingleSelectField { id name options { id name } } } } } } }"
}
$projectQuery = $projectQueryBody | ConvertTo-Json -Compress

try {
    $projectResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $projectQuery -ContentType "application/json" -ErrorAction Stop
    
    if ($projectResponse.errors) {
        Write-Host "❌ Ошибка GraphQL: $($projectResponse.errors | ConvertTo-Json)" -ForegroundColor Red
        exit 1
    }
    
    $projectId = $projectResponse.data.user.projectV2.id
    $statusField = $projectResponse.data.user.projectV2.fields.nodes | Where-Object { $_.name -eq "Status" }
    
    if (-not $statusField) {
        Write-Host "❌ Поле 'Status' не найдено в проекте" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Проект найден: $projectId" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка при получении проекта: $_" -ForegroundColor Red
    exit 1
}

# Шаг 2: Получаем все Items с доски
Write-Host "📋 Получение всех Items с доски..." -ForegroundColor Yellow
$itemsQueryBody = @{
    query = "query { user(login: `"$username`") { projectV2(number: $projectNumber) { items(first: 100) { nodes { id content { ... on Issue { id number title state } } fieldValues(first: 20) { nodes { ... on ProjectV2ItemFieldSingleSelectValue { field { ... on ProjectV2FieldCommon { name } } name } } } } } } } }"
}
$itemsQuery = $itemsQueryBody | ConvertTo-Json -Compress

try {
    $itemsResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $itemsQuery -ContentType "application/json" -ErrorAction Stop
    
    if ($itemsResponse.errors) {
        Write-Host "❌ Ошибка GraphQL: $($itemsResponse.errors | ConvertTo-Json)" -ForegroundColor Red
        exit 1
    }
    
    $items = $itemsResponse.data.user.projectV2.items.nodes
    
    Write-Host "`n📊 Найдено Issues на доске: $($items.Count)" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Gray
    
    # Выводим список Issues
    foreach ($item in $items) {
        if ($item.content) {
            $issueNumber = $item.content.number
            $issueTitle = $item.content.title
            $issueState = $item.content.state
            $currentStatus = ($item.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
            
            Write-Host "`n#${issueNumber}: $issueTitle" -ForegroundColor White
            Write-Host "  Состояние: $issueState" -ForegroundColor $(if ($issueState -eq "OPEN") { "Yellow" } else { "Green" })
            Write-Host "  Статус на доске: $currentStatus" -ForegroundColor Cyan
            Write-Host "  Project Item ID: $($item.id)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n" + ("=" * 80) -ForegroundColor Gray
    
    # Ищем Issues, связанные с навигацией/UI
    $navigationKeywords = @("навигация", "navigation", "кнопки", "buttons", "отступы", "spacing", "padding", "UI", "стили", "styles")
    $uiIssues = $items | Where-Object {
        $item = $_
        if ($item.content) {
            $title = $item.content.title.ToLower()
            $navigationKeywords | ForEach-Object {
                if ($title -like "*$_*") {
                    return $true
                }
            }
        }
        return $false
    }
    
    if ($uiIssues.Count -gt 0) {
        Write-Host "`n🎯 Найдено Issues, связанных с навигацией/UI: $($uiIssues.Count)" -ForegroundColor Yellow
        
        foreach ($issue in $uiIssues) {
            $issueNumber = $issue.content.number
            $issueTitle = $issue.content.title
            $currentStatus = ($issue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
            
            Write-Host "`n📌 Issue #$issueNumber: $issueTitle" -ForegroundColor Cyan
            Write-Host "   Текущий статус: $currentStatus" -ForegroundColor $(if ($currentStatus -eq "Done") { "Green" } else { "Yellow" })
            
            # Если статус не "Done", предлагаем обновить
            if ($currentStatus -ne "Done" -and $issue.content.state -eq "OPEN") {
                Write-Host "   💡 Рекомендуется обновить статус на 'Done'" -ForegroundColor Yellow
                Write-Host "   Команда: .\update-project-status.ps1 -IssueNumber $issueNumber -NewStatus 'Done'" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "`n💡 Issues, связанных с навигацией/UI, не найдено" -ForegroundColor Gray
    }
    
    Write-Host "`n🔗 Доска: https://github.com/users/$username/projects/$projectNumber/views/1" -ForegroundColor White
    
} catch {
    Write-Host "❌ Ошибка при получении Items: $_" -ForegroundColor Red
    exit 1
}

