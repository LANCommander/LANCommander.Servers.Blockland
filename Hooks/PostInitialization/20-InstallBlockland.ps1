#Requires -Modules Logging
#Requires -Modules Hooks

# Blockland is retail software with no public download. Use an existing install in /config/Server,
# or set BLOCKLAND_ARCHIVE_URL to a zip of the game folder (BLRebuilt.exe at the zip root, or in a
# single top-level folder), e.g. a LANCommander archive.

Invoke-Hook "PreInstallBlockland"

$exe = Join-Path $Env:SERVER_DIR 'BLRebuilt.exe'

if (Test-Path -Path $exe) {
    Write-Log "Blockland found in $Env:SERVER_DIR"
} elseif ($Env:BLOCKLAND_ARCHIVE_URL) {
    Write-Log "Downloading Blockland from $Env:BLOCKLAND_ARCHIVE_URL"

    $zip     = '/tmp/blockland.zip'
    $extract = '/tmp/blockland'

    curl -fL --retry 3 --output $zip "$Env:BLOCKLAND_ARCHIVE_URL"
    if ($LASTEXITCODE -ne 0) { throw "Download failed: $Env:BLOCKLAND_ARCHIVE_URL" }

    Remove-Item -Recurse -Force -Path $extract -ErrorAction SilentlyContinue
    unzip -q -o $zip -d $extract
    if ($LASTEXITCODE -ne 0) { throw "Could not extract $zip" }

    # Accept the game at the zip root or inside one top-level folder
    $root = Get-ChildItem -Path $extract -Filter 'BLRebuilt.exe' -Recurse -File -Depth 1 |
        Select-Object -First 1 -ExpandProperty DirectoryName
    if (-not $root) { throw "BLRebuilt.exe not found in $Env:BLOCKLAND_ARCHIVE_URL" }

    New-Item -ItemType Directory -Path $Env:SERVER_DIR -Force | Out-Null
    Move-Item -Force -Path (Join-Path $root '*') -Destination $Env:SERVER_DIR
    chown -R "$($Env:UID):$($Env:GID)" $Env:SERVER_DIR

    Remove-Item -Recurse -Force -Path $zip, $extract

    Write-Log "Blockland installed"
} else {
    Write-Log -Level Error "BLRebuilt.exe not found in $Env:SERVER_DIR. Copy a Blockland Rebuilt v2.1 install there or set BLOCKLAND_ARCHIVE_URL."
}

Invoke-Hook "PostInstallBlockland"

Set-Location $Env:SERVER_ROOT
