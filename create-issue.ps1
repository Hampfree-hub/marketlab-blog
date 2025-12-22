# Скрипт для создания Issue в GitHub
# Использование: .\create-issue.ps1 -Title "Title" -Body "Body" -Labels @("enhancement")

param(
    [Parameter(Mandatory=$true)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [string]$Body = "",
    
    [Parameter(Mandatory=$false)]
    [string[]]$Labels = @()
)

# Настройки
$repo = "Hampfree-hub/marketlab-academy"
$repoOwner = $repo.Split('/')[0]
$repoName = $repo.Split('/')[1]

# Получаем токен из приватного файла
$tokenFile = "D:\Projects\HampfreeBlog-Private\.github-token"
if (-not (Test-Path $tokenFile)) {
    Write-Host "❌ ОШИБКА: Файл с токеном не найден: $tokenFile" -ForegroundColor Red
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

Write-Host "🆕 Создание Issue: $Title" -ForegroundColor Cyan

# Создаём Issue через GraphQL
$createMutation = @{
    query = "mutation { createIssue(input: {repositoryId: `"R_kgDOJzVjXQ`" title: `"$($Title.Replace('"', '\"'))`" body: `"$($Body.Replace('"', '\"').Replace("`r`n", "\n"))`"}) { issue { id number url } } }"
} | ConvertTo-Json -Compress

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $createMutation -ContentType "application/json" -ErrorAction Stop
    
    if ($response.errors) {
        Write-Host "❌ Ошибка GraphQL: $($response.errors | ConvertTo-Json)" -ForegroundColor Red
        exit 1
    }
    
    $issue = $response.data.createIssue.issue
    Write-Host "✅ Issue создан!" -ForegroundColor Green
    Write-Host "   Номер: #$($issue.number)" -ForegroundColor Cyan
    Write-Host "   URL: $($issue.url)" -ForegroundColor White
    
    # Добавляем метки если указаны
    if ($Labels.Count -gt 0) {
        Write-Host "`n🏷️  Добавление меток..." -ForegroundColor Yellow
        # Здесь можно добавить логику добавления меток через API
    }
    
    return $issue
} catch {
    Write-Host "❌ Ошибка при создании Issue: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    exit 1
}

