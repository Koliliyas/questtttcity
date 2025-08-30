# PowerShell script to fix incorrect imports
# This script will replace all locale_keys.g.dart imports with locale_keys.dart

Write-Host "Fixing incorrect imports..." -ForegroundColor Green

# Get all Dart files that import locale_keys.g.dart
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $content = Get-Content $_.FullName -Raw
    $content -match "locale_keys\.g\.dart"
}

Write-Host "Found $($files.Count) files with incorrect imports" -ForegroundColor Yellow

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    
    # Replace the incorrect import
    $newContent = $content -replace "locale_keys\.g\.dart", "locale_keys.dart"
    
    # Write back to file
    $newContent | Set-Content $file.FullName -Encoding UTF8
    Write-Host "  Fixed import" -ForegroundColor Green
}

Write-Host "Done! All incorrect imports have been fixed." -ForegroundColor Green
