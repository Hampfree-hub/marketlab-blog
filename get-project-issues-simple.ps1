# Simple script to get Issues from GitHub Projects board
$tokenFile = "D:\Projects\HampfreeBlog-Private\.github-token"
$token = (Get-Content $tokenFile -Raw -Encoding UTF8).Trim()
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$query = @{
    query = "query { user(login: `"Hampfree-hub`") { projectV2(number: 1) { id title items(first: 50) { nodes { id content { ... on Issue { id number title state url repository { nameWithOwner } } } fieldValues(first: 10) { nodes { ... on ProjectV2ItemFieldSingleSelectValue { field { ... on ProjectV2FieldCommon { name } } name } } } } } } } }"
} | ConvertTo-Json -Compress

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $query -ContentType "application/json" -ErrorAction Stop
    
    if ($response.errors) {
        Write-Host "Error: $($response.errors | ConvertTo-Json)" -ForegroundColor Red
        exit 1
    }
    
    $project = $response.data.user.projectV2
    $items = $project.items.nodes
    
    Write-Host ""
    Write-Host "=== BOARD: $($project.title) ===" -ForegroundColor Cyan
    Write-Host "Total Issues: $($items.Count)"
    Write-Host ""
    
    foreach ($item in $items) {
        if ($item.content) {
            $issue = $item.content
            $statusObj = $item.fieldValues.nodes | Where-Object { $_.field.name -eq 'Status' }
            $statusName = if ($statusObj) { $statusObj.name } else { "N/A" }
            
            Write-Host "[$statusName] Issue #$($issue.number): $($issue.title)" -ForegroundColor White
            Write-Host "  Repo: $($issue.repository.nameWithOwner)" -ForegroundColor Gray
            Write-Host "  State: $($issue.state)" -ForegroundColor $(if ($issue.state -eq "OPEN") { "Yellow" } else { "Green" })
            Write-Host "  URL: $($issue.url)"
            Write-Host ""
        }
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
