# Скрипт для автоматической отправки заблокированных файлов в приватный репозиторий
# Используется в pre-commit hook

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$BlockedFiles = @()
)

$ErrorActionPreference = "Stop"

# Путь к приватному репозиторию
$PrivateRepoPath = Join-Path $PSScriptRoot "..\..\HampfreeBlog-Private"

# Проверяем, существует ли приватный репозиторий
if (-not (Test-Path $PrivateRepoPath)) {
    Write-Host "❌ ОШИБКА: Приватный репозиторий не найден: $PrivateRepoPath" -ForegroundColor Red
    Write-Host "   Создайте репозиторий или укажите правильный путь" -ForegroundColor Yellow
    exit 1
}

# Проверяем, инициализирован ли Git в приватном репозитории
if (-not (Test-Path (Join-Path $PrivateRepoPath ".git"))) {
    Write-Host "⚠️  ПРЕДУПРЕЖДЕНИЕ: Приватный репозиторий не инициализирован как Git репозиторий" -ForegroundColor Yellow
    Write-Host "   Инициализирую..." -ForegroundColor Yellow
    Set-Location $PrivateRepoPath
    git init
    Set-Location $PSScriptRoot
}

if ($BlockedFiles.Count -eq 0) {
    Write-Host "ℹ️  Нет файлов для отправки в приватный репозиторий" -ForegroundColor Cyan
    exit 0
}

Write-Host ""
Write-Host "📦 Отправляю файлы в приватный репозиторий..." -ForegroundColor Cyan
Write-Host ""

$RepoRoot = Join-Path $PSScriptRoot ".."

foreach ($file in $BlockedFiles) {
    $sourcePath = Join-Path $RepoRoot $file
    $destPath = Join-Path $PrivateRepoPath $file
    
    if (Test-Path $sourcePath) {
        # Создаём директории, если нужно
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # Копируем файл
        Copy-Item $sourcePath $destPath -Force
        Write-Host "   ✅ $file → $PrivateRepoPath\" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Файл не найден: $file" -ForegroundColor Yellow
    }
}

# Переходим в приватный репозиторий и коммитим
Set-Location $PrivateRepoPath

# Добавляем файлы
foreach ($file in $BlockedFiles) {
    if (Test-Path $file) {
        git add $file 2>&1 | Out-Null
    }
}

# Коммитим (если есть изменения)
$status = git status --porcelain
if ($status) {
    $commitMessage = "docs: add planning files from main repo - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $commitMessage 2>&1 | Out-Null
    Write-Host ""
    Write-Host "✅ Файлы закоммичены в приватный репозиторий!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "ℹ️  Нет изменений для коммита" -ForegroundColor Cyan
}

Set-Location $RepoRoot

Write-Host ""
Write-Host "✅ Готово! Файлы отправлены в приватный репозиторий" -ForegroundColor Green
Write-Host ""

exit 0




