# Update Issue status using option ID directly
param(
    [Parameter(Mandatory=$true)]
    [int]$IssueNumber
)

$tokenFile = "D:\Projects\HampfreeBlog-Private\.github-token"
$token = (Get-Content $tokenFile -Raw -Encoding UTF8).Trim()
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$username = "Hampfree-hub"
$projectNumber = 1
$repo = "Hampfree-hub/marketlab-academy"

# Get project and status field
$projectQuery = @{
    query = "query { user(login: `"$username`") { projectV2(number: $projectNumber) { id fields(first: 20) { nodes { ... on ProjectV2Field { id name } ... on ProjectV2SingleSelectField { id name options { id name } } } } } } }"
} | ConvertTo-Json -Compress

$projectResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $projectQuery -ContentType "application/json"
$projectId = $projectResponse.data.user.projectV2.id
$statusField = $projectResponse.data.user.projectV2.fields.nodes | Where-Object { $_.name -eq "Status" }
# Use ID for "Done / Закрыто" directly
$doneOptionId = "48adc0c2"

# Get Issue ID
$repoOwner = $repo.Split('/')[0]
$repoName = $repo.Split('/')[1]
$issueQuery = @{
    query = "query { repository(owner: `"$repoOwner`", name: `"$repoName`") { issue(number: $IssueNumber) { id } } }"
} | ConvertTo-Json -Compress

$issueResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $issueQuery -ContentType "application/json"
$issueId = $issueResponse.data.repository.issue.id

# Get Project Item ID
$itemQuery = @{
    query = "query { user(login: `"$username`") { projectV2(number: $projectNumber) { items(first: 100) { nodes { id content { ... on Issue { id number } } } } } } }"
} | ConvertTo-Json -Compress

$itemResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $itemQuery -ContentType "application/json"
$projectItem = $itemResponse.data.user.projectV2.items.nodes | Where-Object { $_.content.id -eq $issueId }
$projectItemId = $projectItem.id

# Update status
$updateMutation = @{
    query = "mutation { updateProjectV2ItemFieldValue(input: {projectId: `"$projectId`" itemId: `"$projectItemId`" fieldId: `"$($statusField.id)`" value: {singleSelectOptionId: `"$doneOptionId`"}}) { projectV2Item { id } } }"
} | ConvertTo-Json -Compress

$updateResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $updateMutation -ContentType "application/json"

if (-not $updateResponse.errors) {
    Write-Host "Issue #$IssueNumber status updated to 'Done / Закрыто'!" -ForegroundColor Green
} else {
    Write-Host "Error: $($updateResponse.errors | ConvertTo-Json)" -ForegroundColor Red
}
