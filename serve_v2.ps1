$port = 8421
$path = "C:\Users\Maggie Coleman\portfolio\v2"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $filePath = Join-Path $path $request.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($request.Url.LocalPath) -or $request.Url.LocalPath -eq '/') {
        $filePath = Join-Path $path "index.html"
    }

    if (Test-Path $filePath -PathType Leaf) {
        $file = Get-Item $filePath
        $response.ContentType = if ($filePath.EndsWith('.html')) { 'text/html' } elseif ($filePath.EndsWith('.css')) { 'text/css' } elseif ($filePath.EndsWith('.js')) { 'application/javascript' } else { 'application/octet-stream' }
        $response.ContentLength64 = $file.Length
        [System.IO.File]::ReadAllBytes($filePath) | ForEach-Object { $response.OutputStream.WriteByte($_) }
    } else {
        $response.StatusCode = 404
        $response.StatusDescription = "Not Found"
    }

    $response.Close()
}
