# Script to add Issues to GitHub Projects board
param(
    [Parameter(Mandatory=$true)]
    [int[]]$IssueNumbers
)

$tokenFile = "D:\Projects\HampfreeBlog-Private\.github-token"
if (-not (Test-Path $tokenFile)) {
    Write-Host "ERROR: Token file not found: $tokenFile" -ForegroundColor Red
    exit 1
}

$token = (Get-Content $tokenFile -Raw -Encoding UTF8).Trim()
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "Getting project ID..." -ForegroundColor Cyan
$projectQuery = @{
    query = "query { user(login: `"Hampfree-hub`") { projectV2(number: 1) { id } } }"
} | ConvertTo-Json -Compress

try {
    $projectResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $projectQuery -ContentType "application/json"
    $projectId = $projectResponse.data.user.projectV2.id
    Write-Host "Project ID: $projectId" -ForegroundColor Green
} catch {
    Write-Host "ERROR getting project: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nAdding Issues to board..." -ForegroundColor Cyan

foreach ($issueNum in $IssueNumbers) {
    Write-Host "`nProcessing Issue #$issueNum..." -ForegroundColor Yellow
    
    # Get Issue ID
    $issueQuery = @{
        query = "query { repository(owner: `"Hampfree-hub`", name: `"marketlab-academy`") { issue(number: $issueNum) { id title } } }"
    } | ConvertTo-Json -Compress
    
    try {
        $issueResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $issueQuery -ContentType "application/json"
        
        if (-not $issueResponse.data.repository.issue) {
            Write-Host "  WARNING: Issue #$issueNum not found" -ForegroundColor Yellow
            continue
        }
        
        $issueId = $issueResponse.data.repository.issue.id
        $issueTitle = $issueResponse.data.repository.issue.title
        Write-Host "  Issue found: $issueTitle" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR getting Issue: $_" -ForegroundColor Red
        continue
    }
    
    # Add Issue to board
    $addMutation = @{
        query = "mutation { addProjectV2ItemById(input: {projectId: `"$projectId`" contentId: `"$issueId`"}) { item { id } } }"
    } | ConvertTo-Json -Compress
    
    try {
        $addResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $addMutation -ContentType "application/json"
        Write-Host "  Issue #$issueNum added to board!" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 422) {
            Write-Host "  WARNING: Issue #$issueNum already on board" -ForegroundColor Yellow
        } else {
            Write-Host "  ERROR adding Issue: $_" -ForegroundColor Red
        }
    }
}

Write-Host "`nDone!" -ForegroundColor Green
Write-Host "Board: https://github.com/users/Hampfree-hub/projects/1/views/1" -ForegroundColor White

