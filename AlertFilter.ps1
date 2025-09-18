<#
.SYNOPSIS
    Filters NPS alerts from a JSON data source or API.

.DESCRIPTION
    This script filters National Park Service (NPS) alerts based on a user-provided keyword.
    It uses a local cache (nps-alerts.json) if available and up-to-date.
    Otherwise, it fetches data from the NPS API in two calls: one to get the total count, and one to retrieve all alerts.

.PARAMETER Keyword
    The keyword to search for in the alert title and description. This parameter is mandatory.

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "A topic parameter is needed to filter the alerts.")]
    [string]$Keyword
)

$jsonFile = "nps-alerts.json"

# Read API key from environment variable
$apiKey = $env:NPS_API_KEY
if (-not $apiKey) {
    Write-Error "NPS_API_KEY environment variable is not set. Please set it before running the script."
    exit 1
}

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
        Write-Host "Fetching alert metadata..."
        # First call to get total count
        $metaResponse = Invoke-RestMethod -Uri "https://developer.nps.gov/api/v1/alerts?limit=1&api_key=$apiKey" -Method Get
        $totalAlerts = $metaResponse.total

        Write-Host "Downloading all $totalAlerts alerts from NPS API..."
        # Second call to get all alerts
        $allResponse = Invoke-RestMethod -Uri "https://developer.nps.gov/api/v1/alerts?limit=$totalAlerts&api_key=$apiKey" -Method Get
        $alerts = $allResponse.data

        # Save to local JSON file
        $alerts | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile
    }
    catch {
        Write-Error "Failed to retrieve alerts from the API. Please check your internet connection or the API endpoint."
        exit 1
    }
}
else {
    try {
        $alerts = Get-Content $jsonFile -Raw | ConvertFrom-Json
    }
    catch {
        Write-Error "Failed to parse the local JSON file. It might be corrupted."
        exit 1
    }
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
        "Park Name: $($alert.parkName)"
        "Link: $($alert.url)"
        "ID: $($alert.id)"
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
