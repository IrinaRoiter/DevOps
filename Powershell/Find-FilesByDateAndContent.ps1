param (
    [Parameter(Mandatory)]
    [string]$BasePath,

    [Parameter(Mandatory)]
    [string]$NamePattern,    # e.g. _260208_

    [Parameter(Mandatory)]
    [string]$SearchString
)

Write-Host "=== File Search Started ==="
Write-Host "Base path        : $BasePath"
Write-Host "Name pattern     : $NamePattern"
Write-Host "Search string    : $SearchString"
Write-Host ""

# ---- Guard clause: BasePath must exist ----
if (-not (Test-Path -Path $BasePath -PathType Container)) {
    Write-Error "BasePath does not exist or is not a directory: $BasePath" -ForegroundColor Red
    Write-Error "Please verify the path and try again." -ForegroundColor Red
    return
}

# Timestamped output folder name (created lazily)
$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$folderName = "$NamePattern`_$timestamp"

# Sanitize folder name (remove illegal characters)
$folderName = $folderName -replace '[\\/:*?"<>|]', '_'

$downloadPath = $null

# Step 1: Find candidate files by name pattern
$candidateFiles = Get-ChildItem `
    -Path $BasePath `
    -Recurse `
    -File |
    Where-Object {
        $_.Name -like "*$NamePattern*"
    }

Write-Host "Candidate files found: $($candidateFiles.Count)" -ForegroundColor Green

# Step 2: Check content and copy matching files
$matchedCount = 0

foreach ($file in $candidateFiles) {

if (Select-String `
        -Path $file.FullName `
        -Pattern $SearchString `
        -SimpleMatch `
        -Quiet `
        -CaseSensitive:$false) {

        # Create download folder only on first match
        if (-not $downloadPath) {
            $downloadPath = Join-Path $env:USERPROFILE "Downloads\$folderName"
            New-Item -Path $downloadPath -ItemType Directory -Force | Out-Null
        }

        Copy-Item `
            -Path $file.FullName `
            -Destination $downloadPath `
            -Force

        Write-Host "Copied:" $file.Name
        $matchedCount++
    }
}

# Step 3: Summary
Write-Host ""
Write-Host "=== Search Complete ===" -ForegroundColor Green
Write-Host "The search string '$SearchString' is found in $matchedCount file(s)" -ForegroundColor Green

if ($matchedCount -gt 0) {
    Write-Host "Downloaded to   : $downloadPath" -ForegroundColor Green
}
else {
    Write-Host "No files matched the search criteria." -ForegroundColor Yellow
}
