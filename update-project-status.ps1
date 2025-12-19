# Скрипт для обновления статуса Issue на GitHub Projects доске
# Использование: .\update-project-status.ps1 -IssueNumber 123 -NewStatus "Done"

param(
    [Parameter(Mandatory=$true)]
    [int]$IssueNumber,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("Todo", "In Progress", "Done")]
    [string]$NewStatus
)

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

Write-Host "🔄 Обновление статуса Issue #$IssueNumber на '$NewStatus'..." -ForegroundColor Cyan

# Шаг 1: Получаем ID проекта
Write-Host "📋 Получение ID проекта..." -ForegroundColor Yellow
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
    
    $statusOption = $statusField.options | Where-Object { $_.name -eq $NewStatus }
    if (-not $statusOption) {
        Write-Host "❌ Опция '$NewStatus' не найдена в поле Status" -ForegroundColor Red
        Write-Host "Доступные опции: $($statusField.options.name -join ', ')" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✅ Проект найден: $projectId" -ForegroundColor Green
    Write-Host "✅ Поле Status: $($statusField.id)" -ForegroundColor Green
    Write-Host "✅ Опция '$NewStatus': $($statusOption.id)" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка при получении проекта: $_" -ForegroundColor Red
    exit 1
}

# Шаг 2: Получаем ID Issue
Write-Host "📋 Получение ID Issue #$IssueNumber..." -ForegroundColor Yellow
$repoOwner = $repo.Split('/')[0]
$repoName = $repo.Split('/')[1]
$issueQueryBody = @{
    query = "query { repository(owner: `"$repoOwner`", name: `"$repoName`") { issue(number: $IssueNumber) { id } } }"
}
$issueQuery = $issueQueryBody | ConvertTo-Json -Compress

try {
    $issueResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $issueQuery -ContentType "application/json" -ErrorAction Stop
    
    if ($issueResponse.errors) {
        Write-Host "❌ Ошибка GraphQL: $($issueResponse.errors | ConvertTo-Json)" -ForegroundColor Red
        exit 1
    }
    
    if (-not $issueResponse.data.repository.issue) {
        Write-Host "❌ Issue #$IssueNumber не найдена" -ForegroundColor Red
        exit 1
    }
    
    $issueId = $issueResponse.data.repository.issue.id
    Write-Host "✅ Issue найдена: $issueId" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка при получении Issue: $_" -ForegroundColor Red
    exit 1
}

# Шаг 3: Получаем Project Item ID
Write-Host "📋 Получение Project Item ID..." -ForegroundColor Yellow
$itemQueryBody = @{
    query = "query { user(login: `"$username`") { projectV2(number: $projectNumber) { items(first: 100) { nodes { id content { ... on Issue { id number } } } } } } }"
}
$itemQuery = $itemQueryBody | ConvertTo-Json -Compress

try {
    $itemResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $itemQuery -ContentType "application/json" -ErrorAction Stop
    
    if ($itemResponse.errors) {
        Write-Host "❌ Ошибка GraphQL: $($itemResponse.errors | ConvertTo-Json)" -ForegroundColor Red
        exit 1
    }
    
    $projectItem = $itemResponse.data.user.projectV2.items.nodes | Where-Object { $_.content.id -eq $issueId }
    
    if (-not $projectItem) {
        Write-Host "⚠️ Issue #$IssueNumber не найдена на доске проекта" -ForegroundColor Yellow
        Write-Host "💡 Добавьте Issue на доску сначала через CREATE_AND_ADD_TO_BOARD.ps1" -ForegroundColor Yellow
        exit 1
    }
    
    $projectItemId = $projectItem.id
    Write-Host "✅ Project Item найден: $projectItemId" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка при получении Project Item: $_" -ForegroundColor Red
    exit 1
}

# Шаг 4: Обновляем статус
Write-Host "🔄 Обновление статуса на '$NewStatus'..." -ForegroundColor Yellow
$updateMutationBody = @{
    query = "mutation { updateProjectV2ItemFieldValue(input: {projectId: `"$projectId`" itemId: `"$projectItemId`" fieldId: `"$($statusField.id)`" value: {singleSelectOptionId: `"$($statusOption.id)`"}}) { projectV2Item { id } } }"
}
$updateMutation = $updateMutationBody | ConvertTo-Json -Compress

try {
    $updateResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $updateMutation -ContentType "application/json" -ErrorAction Stop
    
    if ($updateResponse.errors) {
        Write-Host "❌ Ошибка GraphQL: $($updateResponse.errors | ConvertTo-Json)" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Статус успешно обновлён!" -ForegroundColor Green
    Write-Host "📋 Issue #$IssueNumber теперь в статусе '$NewStatus'" -ForegroundColor Cyan
    Write-Host "🔗 Доска: https://github.com/users/$username/projects/$projectNumber/views/1" -ForegroundColor White
} catch {
    Write-Host "❌ Ошибка при обновлении статуса: $_" -ForegroundColor Red
    exit 1
}

