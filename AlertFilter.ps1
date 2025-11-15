<#
.SYNOPSIS
    Filters NPS alerts from a JSON data source or API.

.DESCRIPTION
    This script filters National Park Service (NPS) alerts based on a user-provided keyword.
    It uses a local cache (nps-alerts.json) if available and up-to-date.
    Otherwise, it fetches data from the NPS API in two calls: one to get the total count, and one to retrieve all alerts.

.PARAMETER Keyword
    The keyword to search for in the alert title and description. This parameter is mandatory.

.PARAMETER Category
    This optional parameter filters alerts by: "Caution", "Danger", "Information", or "Park Closure".

.PARAMETER Format
    Specifies the output format: console (default), json, or csv.

.PARAMETER ParkCode
    This optional parameter filters alerts by a specific park code.

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "A topic parameter is needed to filter the alerts.")]
    [string]$Keyword,
    [Parameter(Mandatory = $false, HelpMessage = "A category parameter can be used to further filter the alerts.")]
    [string]$Category,
    [Parameter(Mandatory = $false, HelpMessage = "A park code parameter can be used to further filter the alerts.")]
    [string]$ParkCode,
    [Parameter(Mandatory = $false, HelpMessage = "Specify output format: console (default), json, or csv.")]
    [ValidateSet('console', 'json', 'csv')]
    [string]$Format = 'console'
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

if ($PSBoundParameters.ContainsKey('Category')) {
    $filteredAlerts = $filteredAlerts | Where-Object {
        $_.category -and $_.category.ToLower() -eq $Category.ToLower()
    }
}

if ($PSBoundParameters.ContainsKey('ParkCode')) {
    $filteredAlerts = $filteredAlerts | Where-Object {
        $_.parkCode -and $_.parkCode.ToLower() -eq $ParkCode.ToLower()
    }
}

# Handle export options
switch ($Format) {
    'json' {
        # Output raw JSON to the console
        $filteredAlerts | ConvertTo-Json -Depth 5
        exit
    }
    'csv' {
        # Convert the filtered objects to CSV text
        $csvText = $filteredAlerts | ConvertTo-Csv -NoTypeInformation | Out-String

        # Prepend UTF-8 BOM
        $bom = [System.Text.Encoding]::UTF8.GetString([byte[]](0xEF, 0xBB, 0xBF))

        # Output BOM + CSV text to STDOUT
        Write-Output ($bom + $csvText)

        exit
    }
    default { } # fall through to console display
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
        "Park: $($alert.parkCode)"
        "Link: $($alert.url)"
        "ID: $($alert.id)"
        if ($alert.startDate) {
            "Start Date: $($alert.startDate)"
        }
        if ($alert.endDate) {
            "End Date: $($alert.endDate)"
        }
        "Last Indexed Date: $($alert.lastIndexedDate)"
    }
}
