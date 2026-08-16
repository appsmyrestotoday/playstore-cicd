$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$extensions = @('.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.bmp')

$images = Get-ChildItem -Path $dir -File |
    Where-Object { $extensions -contains $_.Extension.ToLower() } |
    Sort-Object Name |
    ForEach-Object { $_.Name }

$json = $images | ConvertTo-Json -Compress

Set-Content -Path (Join-Path $dir 'images.json') -Value $json -Encoding UTF8

Write-Host "✅ Found $($images.Count) images → images.json updated"
