function Copy-GameSaves {
    <#
    .SYNOPSIS
        Lorem ipsum
    .DESCRIPTION
        Lorem ipsum
    .EXAMPLE
        Lorem ipsum
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SaveGamePath,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]
        $BackupPath,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GameName,

        [Parameter(Mandatory = $false)]
        [Switch]
        $MeasureTime
    )
    begin {
        if ($MeasureTime) {
            $FuncStartTime = Get-Date
            Write-Host "Function start time: $(Get-Date -Date $FuncStartTime -Format FileDateTimeUniversal)"
        }

        if ([environment]::OSVersion.Platform -ne "Win32NT") {
            throw "You're not on Windows."
        }

        try {
            $SteamDir = Get-ItemProperty -Path HKLM:\SOFTWARE\Valve\Steam -Name InstallPath -ErrorAction Stop
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            try {
                $SteamDir = Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Valve\Steam -Name InstallPath -ErrorAction Stop
            }
            catch {
                $CatchErr = $PSItem
                Write-Error -Message "Cannot find Steam installation directory."
                throw $CatchErr
            }
        }
        catch {
            $CatchErr = $PSItem
            Write-Error -Message "Cannot find Steam installation directory."
            throw $CatchErr
        }

        $SteamDir = $SteamDir | Select-Object -ExpandProperty InstallPath

        try {
            $SteamExe = Join-Path -Path $SteamDir -ChildPath "steam.exe" | Resolve-Path | Select-Object -ExpandProperty Path
        }
        catch {
            $CatchErr
            Write-Error -Message "Cannot locate Steam.exe"
            throw $CatchErr
        }

        $SteamProc = Get-Process -Name Steam -ErrorAction SilentlyContinue
        if ($SteamProc) {
            Start-Process -FilePath $SteamExe -ArgumentList "-shutdown" -Wait
            Start-Sleep -Seconds 3
        }
    }
    process {
        try {
            $SaveGamePath = Join-Path -Path $SteamDir -ChildPath $SaveGamePath | Resolve-Path | Select-Object -ExpandProperty Path
            # PS 5.1 doesn't allow -AdditionalChildPath so we have to combine
            $BackupPath = Join-Path -Path $BackupPath -ChildPath $GameName
            $BackupPath = Join-Path -Path $BackupPath -ChildPath $(Get-Date -Format FileDateTimeUniversal)

            Copy-Item -Path $SaveGamePath -Destination $BackupPath -Recurse
        }
        catch {
            $CatchErr = $PSItem
            throw $CatchErr
        }
        finally {
            if ($MeasureTime) {
                $ItemEndTime = Get-Date
                Write-Host "Item run time: $((New-TimeSpan -Start $FuncStartTime -End $ItemEndTime).TotalSeconds) seconds"
            }
        }
    }
    end {
        if ($SteamProc) {
            Start-Process -FilePath $SteamExe
        }
        if ($MeasureTime) {
            $FuncEndTime = Get-Date
            Write-Host "Function run time: $((New-TimeSpan -Start $FuncStartTime -End $FuncEndTime).TotalSeconds) seconds"
            Write-Host "Function end time: $(Get-Date -Date $FuncEndTime -Format FileDateTimeUniversal)"
        }
    }
}

$GameSaveList = New-Object -TypeName System.Collections.Generic.List[pscustomobject] # [pscustomobject] [string]

$BatmanArkhamOrigins = [PSCustomObject]@{
    GameName = "Batman Arkham Origins"
    SaveGamePath = "\userdata\*\209000\remote"
}
$GameSaveList.Add($BatmanArkhamOrigins)

# $Fallout4 = [PSCustomObject]@{
#     GameName = "Fallout 4"
#     SaveGamePath = "$(Join-Path -Path $HOME -ChildPath "Documents\My Games\Fallout4")"
# }
# $GameSaveList.Add($Fallout4)

$GameSaveList | Copy-GameSaves -BackupPath $(Join-Path -Path $HOME -ChildPath "Game Save Backups")