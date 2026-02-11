# Find-FilesByNamePatternAndContent.ps1
<br />

<details>
<summary>Install PowerShell 7.5.4</summary>
<br />

- Close all powershell terminals
- Download an MSI instaler and install it
- `pwsh` - verify it is installed. Output: PowerShell 7.5.4 or later
</details>

<details>
<summary>Install Az module</summary>
<br />

- `Get-Module -ListAvailable Az.Storage | ForEach-Object { Write-Host "Uninstalling $($_.Name) version $($_.Version) from $($_.ModuleBase)"; Uninstall-Module -Name $_.Name -AllVersions -Force }
` - uninstall any previously installed AZ modules for earlier version of powershell.
- `Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber` - installs all AZ module for Powershell 7 into
C:\Users\<userprofile>\Documents\PowerShell\Modules
- `Get-Module -ListAvailable Az.Storage | Select Name,Version,ModuleBase` - validate that Az.Storage module is available now. The output of the command should look like this: <br />
Az.Storage 9.6.0   C:\Users\<userprofile>\Documents\PowerShell\Modules\Az.Storage\9.6.0
- `Import-Module Az.Storage -Force` - import Az.Storage module
</details>

<details>
<summary>Required arguments</summary>
<br />

- Valid Azure Storage Account
- Container name
- SAS Token with Read / List permissions for top level blob container!
</details>

<details>
<summary>How to run Find-FilesByNamePatternAndContent.ps1</summary>
<br />

.\Find-FilesByNamePatternAndContent-Azure.ps1 -StorageAccountName "mystorageaccount" -SasToken "sv=..." -ContainerName "test" -NamePattern "260208" -SearchString "Hello"

Result: the script will find all the files recursively starting from top level blob container that match NamePatter, then download all the files that contain SearchString into C:\Users\,user profile>\Downloads\<NamePattern>_<Date>_<Time> folder
</details>