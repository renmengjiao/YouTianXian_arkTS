$file = Get-ChildItem -Path "D:\yyoutianxian_arkTS" -Filter "*.docx" | Select-Object -First 1
Write-Output "Found: $($file.FullName)"

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($file.FullName)
$entry = $zip.Entries | Where-Object { $_.Name -eq 'document.xml' } | Select-Object -First 1
$reader = New-Object System.IO.StreamReader($entry.Open())
$xml = $reader.ReadToEnd()
$reader.Close()
$text = [regex]::Replace($xml, '<[^>]+>', ' ')
$text = [regex]::Replace($text, '\s+', ' ')
Write-Output $text
$zip.Dispose()
