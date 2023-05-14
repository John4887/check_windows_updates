<#
.VERSION
1.2.0

.AUTOR
John Gonzalez
#>

$script = "check_windows_updates.ps1"
$version = "1.2.0"
$author = "John Gonzalez"

if ($args.Contains("-v")) {
    Write-Host "$script - $author - $version"
    exit 0
}

# Check for available updates
$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()
$updates = $updateSearcher.Search("IsInstalled=0")

# Determine status based on number and severity of updates

# Filtrer les mises à jour téléchargées et non téléchargées
$downloadedUpdates = $updates.Updates | Where-Object {$_.IsDownloaded -eq $true -or $_.IsDownloaded -eq $false}

# Filtrer les mises à jour installées
$installedUpdates = $updates.Updates | Where-Object {$_.IsInstalled -eq $true}

# Obtenir le nombre de mises à jour disponibles
$updateCount = $downloadedUpdates.Count

# Obtenir le nombre de mises à jour critiques et importantes
$criticalCount = $downloadedUpdates | Where-Object {($_.MsrcSeverity -ge "Critical" -and $_.IsHidden -eq $false) -or $_.Title -like "Security Intelligence Update for Microsoft Defender Antivirus*"} | Measure-Object | Select-Object -ExpandProperty Count
$importantCount = $downloadedUpdates | Where-Object {$_.MsrcSeverity -eq "Important" -and $_.IsHidden -eq $false -and $_.Title -notlike "Security Intelligence Update for Microsoft Defender Antivirus*"} | Measure-Object | Select-Object -ExpandProperty Count

# Set the exit code and message based on the number and severity of updates

if ($updateCount -eq 0) {
    Write-Host "No updates available."
    exit 0
} elseif ($importantCount -eq 0 -and $criticalCount -eq 0) {
    Write-Host "$updateCount Windows updates are available. No updates are important or critical."
    exit 1
} else {
    Write-Host "$updateCount Windows updates are available. $importantCount are important and $criticalCount are critical."
    exit 2
}