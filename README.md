# AlertFilter.ps1

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

This PowerShell script filters **National Park Service (NPS) alerts** by a user-provided keyword, matching against alert titles and descriptions. It automatically downloads and caches the latest alert data from the [NPS alerts API](https://www.nps.gov/nps-alerts.json), refreshing it daily.

## 📌 Features

- 🔄 Downloads the latest alert data from the official NPS source
- 💾 Caches data locally to avoid repeated downloads
- 🔍 Case-insensitive keyword search in title and description
- 🏞️ Displays alert details including park name, category, and alert dates
- 🛑 Graceful error handling for connectivity and data issues

## 📁 Requirements

- PowerShell 5.1+ (Windows) or PowerShell Core 7+ (macOS/Linux)

## 🚀 Usage

```powershell
.\AlertFilter.ps1 fire
```

### Example Output

```
----------------------------------------
Title: North Shore Road Construction July 9 - Sept 22, 2025
Description: A section of N Shore Rd near mile 10.2 is closed...
Category: Closure
Park: Olympic National Park
State: WA
Start Date: 2025-07-09
End Date: 2025-09-22
```

## ⚙ Parameters

| Name    | Required | Description                                      |
|---------|----------|--------------------------------------------------|
| Keyword | ✅ Yes   | The keyword to search for in title or description (case-insensitive) |

## 🗂 Local Caching

The script saves the JSON data as `nps-alerts.json` in the current working directory. It only re-downloads the file if it’s missing or outdated (older than today).

## 🛠 Tips

- You can pipe the output to a file using `>` or `Out-File`
- Put quotes around multiple-word filters like `"black bears"`, `"forest fire"`, etc.

## 📄 License

This script is provided under the [MIT License](https://opensource.org/licenses/MIT).
