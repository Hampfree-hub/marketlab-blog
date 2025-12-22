# Script to update GitHub Projects board issue statuses
param(
    [Parameter(Mandatory=$false)]
    [int[]]$IssueNumbers = @(14, 13, 12, 10, 9, 8, 7, 6),
    
    [Parameter(Mandatory=$false)]
    [string]$NewStatus = "Done"
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

Write-Host "Getting project info..." -ForegroundColor Cyan
$projectQueryBody = @{
    query = "query { user(login: `"Hampfree-hub`") { projectV2(number: 1) { id fields(first: 20) { nodes { ... on ProjectV2Field { id name } ... on ProjectV2SingleSelectField { id name options { id name } } } } } } }"
}
$projectQuery = $projectQueryBody | ConvertTo-Json -Compress

try {
    $projectResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $projectQuery -ContentType "application/json"
    $projectId = $projectResponse.data.user.projectV2.id
    $statusField = $projectResponse.data.user.projectV2.fields.nodes | Where-Object { $_.name -eq "Status" }
    $statusOption = $statusField.options | Where-Object { $_.name -eq $NewStatus }
    
    Write-Host "Project ID: $projectId" -ForegroundColor Green
    Write-Host "Status Field ID: $($statusField.id)" -ForegroundColor Green
    Write-Host "Status Option '$NewStatus' ID: $($statusOption.id)" -ForegroundColor Green
} catch {
    Write-Host "ERROR getting project: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nUpdating issue statuses..." -ForegroundColor Cyan

foreach ($issueNum in $IssueNumbers) {
    Write-Host "`nProcessing Issue #$issueNum..." -ForegroundColor Yellow
    
    # Get Issue ID
    $issueQueryBody = @{
        query = "query { repository(owner: `"Hampfree-hub`", name: `"marketlab-academy`") { issue(number: $issueNum) { id } } }"
    }
    $issueQuery = $issueQueryBody | ConvertTo-Json -Compress
    
    try {
        $issueResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $issueQuery -ContentType "application/json"
        
        if (-not $issueResponse.data.repository.issue) {
            Write-Host "  WARNING: Issue #$issueNum not found" -ForegroundColor Yellow
            continue
        }
        
        $issueId = $issueResponse.data.repository.issue.id
        Write-Host "  Issue found: $issueId" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR getting Issue: $_" -ForegroundColor Red
        continue
    }
    
    # Get Project Item ID
    $itemQueryBody = @{
        query = "query { user(login: `"Hampfree-hub`") { projectV2(number: 1) { items(first: 100) { nodes { id content { ... on Issue { id number } } } } } } }"
    }
    $itemQuery = $itemQueryBody | ConvertTo-Json -Compress
    
    try {
        $itemResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $itemQuery -ContentType "application/json"
        $projectItem = $itemResponse.data.user.projectV2.items.nodes | Where-Object { $_.content.id -eq $issueId }
        
        if (-not $projectItem) {
            Write-Host "  WARNING: Issue #$issueNum not found on board" -ForegroundColor Yellow
            continue
        }
        
        $projectItemId = $projectItem.id
        Write-Host "  Project Item found: $projectItemId" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR getting Project Item: $_" -ForegroundColor Red
        continue
    }
    
    # Update status
    $updateMutationBody = @{
        query = "mutation { updateProjectV2ItemFieldValue(input: {projectId: `"$projectId`" itemId: `"$projectItemId`" fieldId: `"$($statusField.id)`" value: {singleSelectOptionId: `"$($statusOption.id)`"}}) { projectV2Item { id } } }"
    }
    $updateMutation = $updateMutationBody | ConvertTo-Json -Compress
    
    try {
        $updateResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $updateMutation -ContentType "application/json"
        Write-Host "  Status updated to '$NewStatus'!" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR updating status: $_" -ForegroundColor Red
    }
}

Write-Host "`nDone!" -ForegroundColor Green
Write-Host "Board: https://github.com/users/Hampfree-hub/projects/1/views/1" -ForegroundColor White

