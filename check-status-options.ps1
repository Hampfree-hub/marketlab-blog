# Check Status field options
$tokenFile = "D:\Projects\HampfreeBlog-Private\.github-token"
$token = (Get-Content $tokenFile -Raw -Encoding UTF8).Trim()
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$query = @{
    query = "query { user(login: `"Hampfree-hub`") { projectV2(number: 1) { fields(first: 20) { nodes { ... on ProjectV2Field { id name } ... on ProjectV2SingleSelectField { id name options { id name } } } } } } }"
} | ConvertTo-Json -Compress

$response = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $query -ContentType "application/json"
$statusField = $response.data.user.projectV2.fields.nodes | Where-Object { $_.name -eq "Status" }

Write-Host "Status field ID: $($statusField.id)" -ForegroundColor White
Write-Host "Status options:" -ForegroundColor White
$statusField.options | ForEach-Object {
    Write-Host "  - $($_.name): $($_.id)" -ForegroundColor Cyan
}
