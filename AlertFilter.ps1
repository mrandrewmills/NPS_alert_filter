
<#
.SYNOPSIS
    Filters NPS alerts from a JSON data source.

.DESCRIPTION
    This script filters National Park Service (NPS) alerts based on a user-provided keyword.
    It automatically downloads or updates the alert data from the NPS website if necessary.

.PARAMETER Keyword
    The keyword to search for in the alert title and description. This parameter is mandatory.

.EXAMPLE
    ./AlertFilter.ps1 covid
    Filters alerts for "covid".
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "A topic parameter is needed to filter the alerts.")]
    [string]$Keyword
)

$jsonFile = "nps-alerts.json"
$url = "https://nps.gov/nps-alerts.json"

# Check if the JSON file needs to be downloaded or updated
$download = $false
if (-not (Test-Path $jsonFile)) {
    $download = $true
}
else {
    $fileDate = (Get-Item $jsonFile).LastWriteTime.Date
    $today = (Get-Date).Date
    if ($fileDate -lt $today) {
        $download = $true
    }
}

if ($download) {
    try {
        Write-Host "Downloading the latest alerts from $url..."
        Invoke-WebRequest -Uri $url -OutFile $jsonFile
    }
    catch {
        Write-Error "Failed to download the alerts file. Please check your internet connection or the URL."
        exit 1
    }
}

# Load and parse the JSON file
try {
    $alerts = Get-Content $jsonFile -Raw | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse the JSON file. The file might be corrupted or not in the expected format."
    exit 1
}

# Filter the alerts
$filteredAlerts = $alerts | Where-Object {
    ($_.title -and $_.title.ToLower().Contains($Keyword.ToLower())) -or
    ($_.description -and $_.description.ToLower().Contains($Keyword.ToLower()))
}

# Display the filtered alerts
if ($filteredAlerts.Count -eq 0) {
    "No alerts found for the keyword: $Keyword"
}
else {
    foreach ($alert in $filteredAlerts) {
        "----------------------------------------"
        "Title: $($alert.title)"
        "Description: $($alert.description)"
        "Category: $($alert.category)"
        "Park Name: $($alert.park_name)"
        "Link: $($alert.internal_link)"
        "ID: $($alert.unique_id)"
        # Assuming park and state information is nested
        if ($alert.parks.Count -gt 0) {
            $park = $alert.parks[0]
            "Park: $($park.fullName)"
            "State: $($park.states)"
        }
        if ($alert.startDate) {
            "Start Date: $($alert.startDate)"
        }
        if ($alert.endDate) {
            "End Date: $($alert.endDate)"
        }
    }
}
