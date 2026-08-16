param(
    [string]$InPath  = "C:\Users\Maggie Coleman\OneDrive - Washington University in St. Louis\FL2026\LEC\PreliminaryMap\site\data\trees.json",
    [string]$OutPath = "C:\Users\Maggie Coleman\OneDrive - Washington University in St. Louis\FL2026\LEC\PreliminaryMap\site\data\trees_slim.json"
)

$featureRegex = [regex]'"coordinates":\[(?<lon>-?[0-9.]+),(?<lat>-?[0-9.]+)\].*?"COMMON":"(?<common>(?:[^"\\]|\\.)*)".*?"DBH":(?<dbh>-?[0-9.]+).*?"CONDITION":"(?<cond>(?:[^"\\]|\\.)*)".*?"ADDRESS":"(?<addr>(?:[^"\\]|\\.)*)"'

$reader = New-Object System.IO.StreamReader($InPath)
$writer = New-Object System.IO.StreamWriter($OutPath, $false)
$writer.WriteLine('{"type":"FeatureCollection","features":[')

$count = 0
$first = $true
while (($line = $reader.ReadLine()) -ne $null) {
    if ($line -notmatch '"type":"Feature"') { continue }
    if ($line -match '"geometry":null') { continue }
    $m = $featureRegex.Match($line)
    if (-not $m.Success) { continue }

    $lon = $m.Groups['lon'].Value
    $lat = $m.Groups['lat'].Value
    $common = $m.Groups['common'].Value
    $dbh = $m.Groups['dbh'].Value
    $cond = $m.Groups['cond'].Value
    $addr = $m.Groups['addr'].Value

    $feature = '{"type":"Feature","geometry":{"type":"Point","coordinates":[' + $lon + ',' + $lat + ']},"properties":{"species":"' + $common + '","dbh":' + $dbh + ',"condition":"' + $cond + '","address":"' + $addr + '"}}'

    if (-not $first) { $writer.WriteLine(',') }
    $writer.Write($feature)
    $first = $false

    $count++
    if ($count % 20000 -eq 0) { Write-Host "Processed $count" }
}

$writer.WriteLine('')
$writer.WriteLine(']}')
$writer.Close()
$reader.Close()
Write-Host "Done. Wrote $count features to $OutPath"
