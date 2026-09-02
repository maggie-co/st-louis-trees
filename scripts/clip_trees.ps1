$dataDir = "C:\Users\Maggie Coleman\portfolio\map_site\data"

function Test-PointInPolygon {
    param($x, $y, $polygon)
    $inside = $false
    $n = $polygon.Count
    $j = $n - 1
    for ($i = 0; $i -lt $n; $i++) {
        $xi = $polygon[$i][0]; $yi = $polygon[$i][1]
        $xj = $polygon[$j][0]; $yj = $polygon[$j][1]
        if ((($yi -gt $y) -ne ($yj -gt $y)) -and ($x -lt ($xj - $xi) * ($y - $yi) / ($yj - $yi) + $xi)) {
            $inside = -not $inside
        }
        $j = $i
    }
    return $inside
}

$cityBoundary = Get-Content "$dataDir\st_louis_city_boundary.json" -Raw | ConvertFrom-Json
$cityPolyRaw = $cityBoundary.features[0].geometry.coordinates[0]
$cityPoly = @()
foreach ($pt in $cityPolyRaw) { $cityPoly += ,@([double]$pt[0], [double]$pt[1]) }

Write-Host "Loading trees_slim.json..."
$path = Join-Path $dataDir 'trees_slim.json'
$data = Get-Content $path -Raw | ConvertFrom-Json
$total = $data.features.Count
Write-Host "Loaded $total features. Clipping..."

$kept = New-Object System.Collections.Generic.List[object]
$count = 0
foreach ($feature in $data.features) {
    $count++
    if ($count % 20000 -eq 0) { Write-Host "  processed $count / $total" }
    $coords = $feature.geometry.coordinates
    if (Test-PointInPolygon -x ([double]$coords[0]) -y ([double]$coords[1]) -polygon $cityPoly) {
        $kept.Add($feature)
    }
}

if ($kept.Count -eq 0) {
    Write-Host "ABORT - 0 features kept out of $total. Not overwriting." -ForegroundColor Red
    exit 1
}

Write-Host "Writing $($kept.Count) features..."
$outObj = @{ type = "FeatureCollection"; features = $kept }
$outObj | ConvertTo-Json -Depth 20 -Compress | Set-Content $path
Write-Host "trees_slim.json : $total -> $($kept.Count)" -ForegroundColor Green
