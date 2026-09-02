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

function Get-Centroid {
    param($ring)
    $sx = 0.0; $sy = 0.0; $n = $ring.Count
    foreach ($pt in $ring) { $sx += $pt[0]; $sy += $pt[1] }
    return @(($sx / $n), ($sy / $n))
}

$cityBoundary = Get-Content "$dataDir\st_louis_city_boundary.json" -Raw | ConvertFrom-Json
$cityPolyRaw = $cityBoundary.features[0].geometry.coordinates[0]
$cityPoly = @()
foreach ($pt in $cityPolyRaw) { $cityPoly += ,@([double]$pt[0], [double]$pt[1]) }

function Clip-File {
    param([string]$filename)
    $path = Join-Path $dataDir $filename
    $backup = "$path.bak"
    Copy-Item $path $backup -Force

    $data = Get-Content $path -Raw | ConvertFrom-Json
    $total = $data.features.Count
    $kept = @()

    foreach ($feature in $data.features) {
        $geom = $feature.geometry
        $keep = $false
        if ($geom.type -eq 'Point') {
            $keep = Test-PointInPolygon -x ([double]$geom.coordinates[0]) -y ([double]$geom.coordinates[1]) -polygon $cityPoly
        } elseif ($geom.type -eq 'Polygon') {
            $c = Get-Centroid -ring $geom.coordinates[0]
            $keep = Test-PointInPolygon -x $c[0] -y $c[1] -polygon $cityPoly
        } elseif ($geom.type -eq 'MultiPolygon') {
            $c = Get-Centroid -ring $geom.coordinates[0][0]
            $keep = Test-PointInPolygon -x $c[0] -y $c[1] -polygon $cityPoly
        }
        if ($keep) { $kept += $feature }
    }

    if ($kept.Count -eq 0) {
        Write-Host "$filename : ABORT - 0 features kept out of $total. Not overwriting." -ForegroundColor Red
        return
    }

    $outObj = @{ type = "FeatureCollection"; features = $kept }
    $outObj | ConvertTo-Json -Depth 20 -Compress | Set-Content $path
    Write-Host "$filename : $total -> $($kept.Count)" -ForegroundColor Green
}

$files = @(
    'rivers_and_lakes.json',
    'stl_floodplain.json',
    'impacted_blocks_flood_2022.json',
    'msd_problem_areas.json',
    'msd_large_stormwater_projects.json',
    'msd_ownership.json'
)

foreach ($f in $files) {
    Clip-File -filename $f
}
