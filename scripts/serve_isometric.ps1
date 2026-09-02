$root = "C:\Users\Maggie Coleman\portfolio\map_site"
$port = if ($env:PORT) { [int]$env:PORT } else { 8422 }
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
$mime = @{ ".html"="text/html"; ".css"="text/css"; ".js"="application/javascript"; ".json"="application/json"; ".svg"="image/svg+xml"; ".png"="image/png"; ".jpg"="image/jpeg" }
Write-Host "Serving Isometric Map on http://localhost:$port/isometric.html"

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $path = $ctx.Request.Url.LocalPath
    if ($path -eq "/") { $path = "/isometric.html" }
    $file = Join-Path $root ($path -replace "^/","")
    if (Test-Path $file -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($file)
      $ctx.Response.ContentType = if ($mime[$ext]) { $mime[$ext] } else { "application/octet-stream" }
      $ctx.Response.SendChunked = $false
      $ctx.Response.KeepAlive = $false
      $ctx.Response.Headers.Set("Connection", "close")
      $fileStream = [System.IO.File]::OpenRead($file)
      $ctx.Response.ContentLength64 = $fileStream.Length
      $fileStream.CopyTo($ctx.Response.OutputStream)
      $fileStream.Close()
    } else {
      $ctx.Response.StatusCode = 404
    }
  } catch {
    Write-Host "Request error on $path : $($_.Exception.Message)"
    try { $ctx.Response.StatusCode = 500 } catch {}
  } finally {
    $ctx.Response.OutputStream.Close()
  }
}
