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
        $ErrorActionPreference = 'Stop'
        if ($MeasureTime) {
            $FuncStartTime = Get-Date
            Write-Host "Function start time: $(Get-Date -Date $FuncStartTime -Format FileDateTimeUniversal)"
        }

        if ([environment]::OSVersion.Platform -ne "Win32NT") {
            throw "You're not on Windows."
        }

        try {
            $SteamDir = Get-ItemProperty -Path HKLM:\SOFTWARE\Valve\Steam -Name InstallPath
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            try {
                $SteamDir = Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Valve\Steam -Name InstallPath
            }
            catch {
                Write-Verbose -Message "Cannot find Steam installation directory."
                Write-Error -Message $_.Exception.Message -ErrorAction Stop
            }
        }
        catch {
            Write-Verbose -Message "Cannot find Steam installation directory."
            Write-Error -Message $_.Exception.Message -ErrorAction Stop
        }

        $SteamDir = $SteamDir | Select-Object -ExpandProperty InstallPath

        try {
            $SteamExe = Join-Path -Path $SteamDir -ChildPath "steam.exe" | Resolve-Path | Select-Object -ExpandProperty Path
        }
        catch {
            Write-Verbose -Message "Cannot locate Steam.exe"
            Write-Error -Message $_.Exception.Message -ErrorAction Stop
        }
    }
    process {
        try {
            $SteamProc = Get-Process -Name Steam
            if ($SteamProc) {
                Start-Process -FilePath $SteamExe -ArgumentList "-shutdown" -Wait
            }
            $SaveGamePath = Join-Path -Path $SteamDir -ChildPath $SaveGamePath | Resolve-Path | Select-Object -ExpandProperty Path
            $BackupPath = Join-Path -Path $BackupPath -ChildPath $GameName

            Copy-Item -Path $SaveGamePath -Destination "$BackupPath-$(Get-Date -Format FileDateTimeUniversal)" -Recurse

            if ($SteamProc) {
                Start-Process -FilePath $SteamExe -Wait
            }
        }
        catch {
            Write-Error -Message $_.Exception.Message
        }
        finally {
            if ($MeasureTime) {
                $ItemEndTime = Get-Date
                Write-Host "Item run time: $((New-TimeSpan -Start $FuncStartTime -End $ItemEndTime).TotalSeconds) seconds"
            }
        }
    }
    end {
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

$Fallout4 = [PSCustomObject]@{
    GameName = "Fallout 4"
    SaveGamePath = "$(Join-Path -Path $HOME -ChildPath "Documents\My Games\Fallout4")"
}
$GameSaveList.Add($Fallout4)

$GameSaveList | Copy-GameSaves -BackupPath $(Join-Path -Path $HOME -ChildPath "Game Save Backups")