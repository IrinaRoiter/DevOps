<# Minimal requirements: 
- PowerShell 7.5.4 or later for Az.Storage module compatibility
- See README.md for installation instructions and usage examples.
#>


param (
    [Parameter(Mandatory)]
    [string]$StorageAccountName,

    [Parameter(Mandatory)]
    [string]$ContainerName,

    [Parameter(Mandatory)]
    [string]$SasToken,          # e.g., "?sv=2025-01-01&ss=b&srt=sco&sp=rl&se=2026-02-11T00:00:00Z&st=2026-02-10T00:00:00Z&spr=https&sig=..."

    [Parameter(Mandatory)]
    [string]$NamePattern,        # e.g. _260208_

    [Parameter(Mandatory)]
    [string]$SearchString
)

Write-Host "=== Azure Blob Search Started ==="
Write-Host "Storage Account   : $StorageAccountName"
Write-Host "Container Name    : $ContainerName"
Write-Host "Name pattern      : $NamePattern"
Write-Host "Search string     : $SearchString"
Write-Host ""


#[AppDomain]::CurrentDomain.GetAssemblies() |
#Where-Object { $_.FullName -like "*Azure.PowerShell.Storage*" } | Select FullName, Location

# ---- Build the Blob URI with SAS token ----
$blobEndpoint = "https://$StorageAccountName.blob.core.windows.net"
$context = New-AzStorageContext -StorageAccountName $StorageAccountName -SasToken $SasToken

if (-not $context) {
    Write-Error "Failed to create storage context. Check your account name and SAS token."
    return
}

# Timestamped output folder name
$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$folderName = "$NamePattern`_$timestamp"
$folderName = $folderName -replace '[\\/:*?"<>|]', '_'  # sanitize folder name
$downloadPath = Join-Path $env:USERPROFILE "Downloads\$folderName"

# Create local folder
New-Item -Path $downloadPath -ItemType Directory -Force | Out-Null

# Step 1: List blobs matching the name pattern
$blobs = Get-AzStorageBlob -Container $ContainerName -Context $context | Where-Object {
    $_.Name -like "*$NamePattern*"
}

Write-Host "Candidate blobs found: $($blobs.Count)" -ForegroundColor Green

# Step 2: Check content and download matching blobs
$matchedCount = 0

foreach ($blob in $blobs) {
    # Download blob content temporarily
    $tempFile = Join-Path $downloadPath ([IO.Path]::GetFileName($blob.Name))
    Get-AzStorageBlobContent -Blob $blob.Name -Container $ContainerName -Destination $tempFile -Context $context -Force | Out-Null

    # Search content
    if (Select-String -Path $tempFile -Pattern $SearchString -SimpleMatch -Quiet -CaseSensitive:$false) {
        Write-Host "Matched & downloaded:" $blob.Name -ForegroundColor Green
        $matchedCount++
    }
    else {
        # Remove temp file if it doesn't match
        Remove-Item -Path $tempFile -Force
    }
}

# Step 3: Summary
Write-Host ""
Write-Host "=== Search Complete ===" -ForegroundColor Green
Write-Host "The search string '$SearchString' is found in $matchedCount blob(s)" -ForegroundColor Green

if ($matchedCount -gt 0) {
    Write-Host "Downloaded to   : $downloadPath" -ForegroundColor Green
}
else {
    Write-Host "No blobs matched the search criteria." -ForegroundColor Yellow
}
