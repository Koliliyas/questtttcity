# PowerShell script to fix LocaleKeys imports
# This script will add the missing import for LocaleKeys to all Dart files that use it

Write-Host "Fixing LocaleKeys imports..." -ForegroundColor Green

# Get all Dart files that use LocaleKeys
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $content = Get-Content $_.FullName -Raw
    $content -match "LocaleKeys\."
}

Write-Host "Found $($files.Count) files that use LocaleKeys" -ForegroundColor Yellow

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    $lines = Get-Content $file.FullName
    
    # Check if LocaleKeys is already imported
    if ($content -match "import.*LocaleKeys" -or $content -match "export.*LocaleKeys") {
        Write-Host "  Already has LocaleKeys import, skipping..." -ForegroundColor Gray
        continue
    }
    
    # Find the first import statement
    $importIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*import\s+") {
            $importIndex = $i
            break
        }
    }
    
    if ($importIndex -eq -1) {
        # No imports found, add at the beginning
        $importIndex = 0
    }
    
    # Add the import statement
    $newLines = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $newLines += $lines[$i]
        if ($i -eq $importIndex) {
            $newLines += "import 'package:los_angeles_quest/l10n/locale_keys.dart';"
        }
    }
    
    # Write back to file
    $newLines | Set-Content $file.FullName -Encoding UTF8
    Write-Host "  Added LocaleKeys import" -ForegroundColor Green
}

Write-Host "Done! All files have been updated." -ForegroundColor Green
