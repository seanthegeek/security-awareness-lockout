# security-awareness-lockout

A script for creating a self-extracting EXE that blocks user input while a Rickroll plays. Useful for security awareness training.

## How it works

`build.bat` creates a self-extracting (SFX) 7-Zip archive called `confidential.exe`, which can be placed on a bait flash drive.

When `confidential.exe` is run, and the user Clicks `Yes` on the Windows User Access Control (UAC) prompt, the exe extracts the contents of `lock.7z` to a temporary directory, and executes `lock\lock.ps1`.

`lock.ps1` is a PowerShell script that blocks user keyboard and mouse input, and opens `lock\lock.ppsx`, which is an automatic PowerPoint Show.

Thus, the user is forced to listen to/look at the presentation until the PowerShell script stops blocking user input (configured at 2 minutes by default).

## Modifying the PowerPoint show

`lock\lock.ppsx` can be modified as needed, as long as the filename and path remain unchanged.

After saving changes, run `build.bat` to update the payload files.

## Adjusting the lockout length

1. Change the value of `minutes` at the top of  `lock\lock.ps1`.
2. Edit the text in `lock\lock.ppsx` so that the message and auto advance match the new lock out time.
3. Set the auto advance time for the PowerPoint slide to match, in the `Timing` section  in the `Transitions` tab of the PowerPoint Office Ribbon.
4. After saving changes, run `build.bat` to update the payload.

## Adding reporting

Reporting can accomplished by creating a web service to track HTTP POST requests, and modifying  `lock\lock.ps1` to make a request containing the PC name and username. For example:

```powershell
$uri = "https://example.local/report"
$Params = @(computername=$env:COMPUTERNAME; username=$env:USERNAME; userdomain=$env:USERDOMAIN)
Invoke-WebRequest -Uri $url -Method POST -Body $Params
```

Place the code **before** the part of the script that checks if it is running as Administrator. That way, the actual username is reported, and not just Administrator, and reports get made even if the user clicks No on the UAC prompt.

A second request could also be added **after** the check, to track who clicked Yes and No on the UAC prompt.

## File inventory

- `doc\`
  - `sfx.txt` Documentation on self-extracting (SFX) 7-Zip archives
- `lock\`
  - `lock.ppsx` - The PowerPoint Show
  - `lock.ps1` - The PowerShell script that blocks user input and runs the show
- `music\` - A directory containing backup copies of sutible music files
- `7zSD.sfx` - The 7-Zip SFX module from the [LZMA SDK][1]
- `README.md` - This file
- `build.bat` - The build script
- `config.txt` - the 7-Zip SFX configuration file

[1]: https://www.7-zip.org/sdk.html
