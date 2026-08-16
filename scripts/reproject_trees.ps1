# Reprojects CITY_TREES.json from NAD83 StatePlane Missouri East (FIPS 2401, US feet)
# to WGS84 lon/lat, for use in MapLibre GL.
# Projection params come from CITY_TREES.prj (Transverse Mercator).

param(
    [string]$InPath  = "C:\Users\Maggie Coleman\OneDrive - Washington University in St. Louis\FL2026\LEC\PreliminaryMap\raw_data\JSON\CITY_TREES.json",
    [string]$OutPath = "C:\Users\Maggie Coleman\OneDrive - Washington University in St. Louis\FL2026\LEC\PreliminaryMap\raw_data\JSON\CITY_TREES_wgs84.json"
)

# --- GRS80 ellipsoid ---
$a  = 6378137.0
$f  = 1.0 / 298.257222101
$e2 = 2*$f - $f*$f
$ep2 = $e2 / (1 - $e2)

# --- Projection params (from .prj) ---
$falseEasting  = 820208.3333333333          # US survey feet
$falseNorthing = 0.0
$lon0 = -90.5 * [Math]::PI / 180.0
$lat0 = 35.83333333333334 * [Math]::PI / 180.0
$k0   = 0.9999333333333333
$footToMeter = 0.3048006096012192           # US survey foot

function Inverse-TransverseMercator($xFt, $yFt) {
    $x = ($xFt - $falseEasting) * $footToMeter
    $y = ($yFt - $falseNorthing) * $footToMeter

    $M0 = $a * ((1 - $e2/4 - 3*[Math]::Pow($e2,2)/64 - 5*[Math]::Pow($e2,3)/256) * $lat0 `
              - (3*$e2/8 + 3*[Math]::Pow($e2,2)/32 + 45*[Math]::Pow($e2,3)/1024) * [Math]::Sin(2*$lat0) `
              + (15*[Math]::Pow($e2,2)/256 + 45*[Math]::Pow($e2,3)/1024) * [Math]::Sin(4*$lat0) `
              - (35*[Math]::Pow($e2,3)/3072) * [Math]::Sin(6*$lat0))

    $M = $M0 + $y / $k0
    $mu = $M / ($a * (1 - $e2/4 - 3*[Math]::Pow($e2,2)/64 - 5*[Math]::Pow($e2,3)/256))

    $e1 = (1 - [Math]::Sqrt(1-$e2)) / (1 + [Math]::Sqrt(1-$e2))

    $phi1 = $mu `
        + (3*$e1/2 - 27*[Math]::Pow($e1,3)/32) * [Math]::Sin(2*$mu) `
        + (21*[Math]::Pow($e1,2)/16 - 55*[Math]::Pow($e1,4)/32) * [Math]::Sin(4*$mu) `
        + (151*[Math]::Pow($e1,3)/96) * [Math]::Sin(6*$mu) `
        + (1097*[Math]::Pow($e1,4)/512) * [Math]::Sin(8*$mu)

    $sinPhi1 = [Math]::Sin($phi1)
    $cosPhi1 = [Math]::Cos($phi1)
    $tanPhi1 = [Math]::Tan($phi1)

    $C1 = $ep2 * $cosPhi1 * $cosPhi1
    $T1 = $tanPhi1 * $tanPhi1
    $N1 = $a / [Math]::Sqrt(1 - $e2*$sinPhi1*$sinPhi1)
    $R1 = $a * (1-$e2) / [Math]::Pow(1 - $e2*$sinPhi1*$sinPhi1, 1.5)
    $D = $x / ($N1 * $k0)

    $lat = $phi1 - ($N1 * $tanPhi1 / $R1) * ( `
        [Math]::Pow($D,2)/2 `
        - (5 + 3*$T1 + 10*$C1 - 4*$C1*$C1 - 9*$ep2) * [Math]::Pow($D,4)/24 `
        + (61 + 90*$T1 + 298*$C1 + 45*$T1*$T1 - 252*$ep2 - 3*$C1*$C1) * [Math]::Pow($D,6)/720)

    $lon = $lon0 + ( `
        $D `
        - (1 + 2*$T1 + $C1) * [Math]::Pow($D,3)/6 `
        + (5 - 2*$C1 + 28*$T1 - 3*$C1*$C1 + 8*$ep2 + 24*$T1*$T1) * [Math]::Pow($D,5)/120 `
        ) / $cosPhi1

    return @(($lon * 180.0 / [Math]::PI), ($lat * 180.0 / [Math]::PI))
}

$coordRegex = [regex]'"coordinates":\[(-?[0-9.]+),(-?[0-9.]+)\]'

$reader = New-Object System.IO.StreamReader($InPath)
$writer = New-Object System.IO.StreamWriter($OutPath, $false)

$count = 0
while (($line = $reader.ReadLine()) -ne $null) {
    $m = $coordRegex.Match($line)
    if ($m.Success) {
        $xFt = [double]$m.Groups[1].Value
        $yFt = [double]$m.Groups[2].Value
        $lonlat = Inverse-TransverseMercator $xFt $yFt
        $newCoord = '"coordinates":[' + $lonlat[0].ToString("F8") + ',' + $lonlat[1].ToString("F8") + ']'
        $line = $line.Substring(0, $m.Index) + $newCoord + $line.Substring($m.Index + $m.Length)
        $count++
        if ($count % 20000 -eq 0) { Write-Host "Processed $count features" }
    }
    $writer.WriteLine($line)
}

$writer.Close()
$reader.Close()
Write-Host "Done. Reprojected $count features to $OutPath"
