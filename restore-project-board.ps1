# Script to restore deleted Issues back to board
# Usage: .\restore-project-board.ps1

$tokenFile = "D:\Projects\HampfreeBlog-Private\.github-token"
$token = (Get-Content $tokenFile -Raw -Encoding UTF8).Trim()
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host ""
Write-Host "=== RESTORING DELETED ISSUES ===" -ForegroundColor Yellow
Write-Host ""

# List of Issues to restore (from previous output)
$issuesToRestore = @(
    @{Repo="Hampfree-hub/hampfreeblog-private"; Number=1},
    @{Repo="Hampfree-hub/hampfreeblog-private"; Number=2},
    @{Repo="Hampfree-hub/hampfreeblog-private"; Number=3},
    @{Repo="Hampfree-hub/tradingbots"; Number=1},
    @{Repo="Hampfree-hub/tradingbots"; Number=2},
    @{Repo="Hampfree-hub/tradingbots"; Number=3},
    @{Repo="Hampfree-hub/tradingbots"; Number=4},
    @{Repo="Hampfree-hub/tradingbots"; Number=5},
    @{Repo="Hampfree-hub/tradingbots"; Number=6},
    @{Repo="Hampfree-hub/n8n-workflows"; Number=1},
    @{Repo="Hampfree-hub/n8n-workflows"; Number=2},
    @{Repo="Hampfree-hub/n8n-workflows"; Number=3},
    @{Repo="Hampfree-hub/n8n-workflows"; Number=4},
    @{Repo="Hampfree-hub/matrixbot"; Number=1},
    @{Repo="Hampfree-hub/matrixbot"; Number=2},
    @{Repo="Hampfree-hub/matrixbot"; Number=3},
    @{Repo="Hampfree-hub/matrixbot"; Number=4},
    @{Repo="Hampfree-hub/contentbot"; Number=1},
    @{Repo="Hampfree-hub/contentbot"; Number=2},
    @{Repo="Hampfree-hub/contentbot"; Number=3},
    @{Repo="Hampfree-hub/contentbot"; Number=4},
    @{Repo="Hampfree-hub/contentbot"; Number=5}
)

# Get project ID
$projectQuery = @{
    query = "query { user(login: `"Hampfree-hub`") { projectV2(number: 1) { id } } }"
} | ConvertTo-Json -Compress

try {
    $projectResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $projectQuery -ContentType "application/json" -ErrorAction Stop
    $projectId = $projectResponse.data.user.projectV2.id
    
    Write-Host "Project ID: $projectId" -ForegroundColor White
    Write-Host ""
    
    # Restore each Issue
    foreach ($issueInfo in $issuesToRestore) {
        $repoOwner = $issueInfo.Repo.Split('/')[0]
        $repoName = $issueInfo.Repo.Split('/')[1]
        $issueNumber = $issueInfo.Number
        
        Write-Host "Restoring Issue #$issueNumber from $($issueInfo.Repo)..." -ForegroundColor Yellow
        
        # Get Issue ID
        $issueQuery = @{
            query = "query { repository(owner: `"$repoOwner`", name: `"$repoName`") { issue(number: $issueNumber) { id } } }"
        } | ConvertTo-Json -Compress
        
        try {
            $issueResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $issueQuery -ContentType "application/json" -ErrorAction Stop
            
            if ($issueResponse.errors -or -not $issueResponse.data.repository.issue) {
                Write-Host "  -> Issue not found or error" -ForegroundColor Red
                continue
            }
            
            $issueId = $issueResponse.data.repository.issue.id
            
            # Add Issue to project
            $addMutation = @{
                query = "mutation { addProjectV2ItemById(input: {projectId: `"$projectId`" contentId: `"$issueId`"}) { item { id } } }"
            } | ConvertTo-Json -Compress
            
            $addResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $addMutation -ContentType "application/json" -ErrorAction Stop
            
            if (-not $addResponse.errors) {
                Write-Host "  -> Restored!" -ForegroundColor Green
            } else {
                Write-Host "  -> Error: $($addResponse.errors | ConvertTo-Json)" -ForegroundColor Red
            }
        } catch {
            Write-Host "  -> Error: $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "=== RESTORATION COMPLETE ===" -ForegroundColor Green
    Write-Host "Board: https://github.com/users/Hampfree-hub/projects/1/views/1" -ForegroundColor Cyan
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
