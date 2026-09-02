$path = "C:\Users\Maggie Coleman\portfolio\map_site\data\trees_slim.json"
$backup = "$path.bak"
Copy-Item $path $backup -Force

Write-Host "Loading trees_slim.json..."
$data = Get-Content $path -Raw | ConvertFrom-Json
$total = $data.features.Count
Write-Host "Loaded $total features."

$targetCount = 10000
$step = [Math]::Floor($total / $targetCount)
if ($step -lt 1) { $step = 1 }

$kept = New-Object System.Collections.Generic.List[object]
for ($i = 0; $i -lt $total; $i += $step) {
    $kept.Add($data.features[$i])
}

if ($kept.Count -eq 0) {
    Write-Host "ABORT - 0 features kept. Not overwriting." -ForegroundColor Red
    exit 1
}

Write-Host "Writing $($kept.Count) features..."
$outObj = @{ type = "FeatureCollection"; features = $kept }
$outObj | ConvertTo-Json -Depth 20 -Compress | Set-Content $path
Write-Host "trees_slim.json : $total -> $($kept.Count)" -ForegroundColor Green
