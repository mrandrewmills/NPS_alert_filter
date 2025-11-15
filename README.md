# AlertFilter.ps1

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

This PowerShell script filters **National Park Service (NPS) alerts** by a user-provided keyword, matching against alert titles and descriptions. It automatically downloads and caches the latest alert data from the [NPS API](https://www.nps.gov/subjects/developer/api-documentation.htm#/alerts/getAlerts), refreshing it daily.

## 📌 Features

- 🔄 Downloads the latest alert data from the official NPS API
- 💾 Caches data locally to avoid repeated downloads
- 🔍 Case-insensitive keyword search in title and description
- 🗂 Optionally filters by alert category for more precise results
- 🏝 Displays alert details including park name, category, alert dates, and link
- 📤 Supports multiple output formats: `console`, `json`, and `csv`
- 🗽 Graceful error handling for connectivity and data issues
- 🔑 API key is read from an environment variable `NPS_API_KEY` for security

## 📁 Requirements

- PowerShell 5.1+ (Windows) or PowerShell Core 7+ (macOS/Linux)
- NPS API key stored in the environment variable `NPS_API_KEY`

```powershell
# Temporary for current session:
$env:NPS_API_KEY = "YOUR_API_KEY"

# Permanent (User-level):
[System.Environment]::SetEnvironmentVariable("NPS_API_KEY", "YOUR_API_KEY", "User")
```

## 🚀 Usage

### Basic Usage

To search for a keyword in the title or description:

```powershell
.\AlertFilter.ps1 "fire"
```

### Advanced Usage

To filter by both a keyword and a specific category, use the optional `-Category` parameter:

```powershell
.\AlertFilter.ps1 "shutdown" -Category "Park Closure"
```

To get the results in a different format, use the `-Format` parameter:

```powershell
.\AlertFilter.ps1 "construction" -Format "csv" > alerts.csv
```

## 📤 Output Formats

The script supports three output formats, specified with the `-Format` parameter.

### Console (Default)

Displays results in a human-readable format in the console.

```powershell
.\AlertFilter.ps1 "road closure"
```

**Example Output:**

```
----------------------------------------
Title: North Shore Road Construction July 9 - Sept 22, 2025
Description: A section of N Shore Rd near mile 10.2 is closed...
Category: Closure
Park Name: Olympic National Park
State: WA
Link: https://www.nps.gov/olym/planyourvisit/road-closure.htm
Start Date: 2025-07-09
End Date: 2025-09-22
ID: 12345
```

### JSON

Outputs the filtered alert objects as a JSON array. This is useful for programmatic use or integration with other tools.

```powershell
.\AlertFilter.ps1 "fire" -Format "json"
```

**Example Output:**

```json
[
    {
        "id": "12345",
        "url": "https://www.nps.gov/olym/planyourvisit/road-closure.htm",
        "title": "North Shore Road Construction July 9 - Sept 22, 2025",
        "description": "A section of N Shore Rd near mile 10.2 is closed...",
        "category": "Closure",
        "parkCode": "olym"
    }
]
```

### CSV

Outputs the results in CSV format, which can be easily imported into spreadsheets or other data analysis tools.

```powershell
.\AlertFilter.ps1 "construction" -Format "csv" > alerts.csv
```

**Example Output (in `alerts.csv`):**

```csv
"id","url","title","description","category","parkCode"
"12345","https://www.nps.gov/olym/planyourvisit/road-closure.htm","North Shore Road Construction...","A section of N Shore Rd...","Closure","olym"
```

## 🔧 Parameters

| Name     | Required | Description                                                               |
| -------- | -------- | ------------------------------------------------------------------------- |
| Keyword  | ✅ Yes   | The keyword to search for in the title or description (case-insensitive). |
| Category | ❌ No    | The category to filter by (e.g., "Park Closure", "Caution"). Optional.    |
| ParkCode | ❌ No    | The park code to filter by (e.g., "shen", "yell", "romo"). Optional.      |
| Format   | ❌ No    | The output format: `console` (default), `json`, or `csv`. Optional.       |

## 💾 Local Caching

- The script saves JSON data as `nps-alerts.json` in the current working directory.
- Only re-downloads the file if it’s missing or older than today.
- Enables multiple searches in a day without hitting the API repeatedly.

## 🛠 Tips

- Pipe output to a file using `>` or `Out-File`
- Try keywords like `"closure"`, `"fire"`, `"construction"`, etc.

## 📝 License

This script is provided under the [MIT License](https://opensource.org/licenses/MIT).
