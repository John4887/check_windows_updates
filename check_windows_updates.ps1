<#
.VERSION
1.4.0

.AUTHOR
John Gonzalez
#>

$script = "check_windows_updates.ps1"
$version = "1.4.0"
$author = "John Gonzalez"

if ($args.Contains("-v")) {
    Write-Host "$script - $author - $version"
    exit 0
}

# Check for available updates
$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()

# Search for updates that aren't installed
$notInstalledUpdates = $updateSearcher.Search("IsInstalled=0 and IsHidden=0").Updates

# Filter out downloaded and installed updates
$relevantUpdates = $notInstalledUpdates | Where-Object { $_.Title -notlike "Security Intelligence Update for Microsoft Defender Antivirus*" }

# Get the count of available updates
$updateCount = $relevantUpdates.Count

# Get the count of important and critical updates
$criticalCount = $relevantUpdates | Where-Object { ($_.MsrcSeverity -ge "Critical" -and $_.IsHidden -eq $false) -or $_.Title -like "Security Intelligence Update for Microsoft Defender Antivirus*" } | Measure-Object | Select-Object -ExpandProperty Count
$importantCount = $relevantUpdates | Where-Object { $_.MsrcSeverity -eq "Important" -and $_.IsHidden -eq $false -and $_.Title -notlike "Security Intelligence Update for Microsoft Defender Antivirus*" } | Measure-Object | Select-Object -ExpandProperty Count

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
