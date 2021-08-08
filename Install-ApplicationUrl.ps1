function Install-ApplicationUrl {
    <#
    .SYNOPSIS
        Lorem ipsum
    .DESCRIPTION
        Lorem ipsum
    .EXAMPLE
        Lorem ipsum
    #>
    #Requires -RunAsAdministrator
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Url")]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Github")]
        [string]
        $Github,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Github")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Url")]
        [string]
        $FileName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Github")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Url")]
        [array]
        $ArgumentList,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Github")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Url")]
        [switch]
        $MeasureTime
    )
    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #$ErrorActionPreference = 'Stop'
        if ($MeasureTime) {
            $FuncStartTime = Get-Date
            Write-Verbose -Message "Function start time: $(Get-Date -Date $FuncStartTime -Format FileDateTimeUniversal)"
        }
    }
    process {
        try {
            $TempPath = [IO.Path]::GetTempPath().ToString()
            $TempGuid = [System.Guid]::NewGuid().ToString()
            $TempDir = Join-Path -Path $TempPath -ChildPath $TempGuid
            if (!(Test-Path -Path $TempDir)) {
                $TempDir = New-Item -Path $TempPath -Name $TempGuid -ItemType Directory
                $TempDir = $TempDir | Select-Object -ExpandProperty FullName
            }

            # Download file to temporary folder
            try {
                if ($Github) {
                    $Releases = "https://api.github.com/repos/$Github/releases"
                    Write-Verbose -Message "Trying to download from $Releases"
                    $Response = Invoke-WebRequest -Uri $Releases -UseBasicParsing | ConvertFrom-Json
                    $DownloadUrl = $Response.assets | Where-Object { ($_.Name -like "*64*.exe" -or $_.Name -like "*64*.msi") -and (-not($_.Name -like "*rc*" -or $_.Name -like "*zip*" -or $_.Name -like "*7z*")) } | Sort-Object -Property created_at -Descending | Select-Object -First 1
                    $OutputPath = Join-Path -Path $TempDir -ChildPath $($DownloadUrl.Name)
                    Invoke-RestMethod -Method Get -Uri $DownloadUrl.browser_download_url -OutFile $OutputPath
                } else {
                    Write-Verbose -Message "Trying to download $Url"
                    if (!($Filename)) {
                        $Filename = ($Url | Select-String -Pattern "[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))").Matches.Value #| Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
                    }
                    $OutputPath = Join-Path -Path $TempDir -ChildPath $Filename
                    Invoke-RestMethod -Method Get -Uri $Url -OutFile $OutputPath
                }
            }
            catch {
                Write-Warning -Message "Failed to download application, download and install application manually."
                Write-Error -Message $_.Exception.Message
                return
            }

            try {
                if ($ArgumentList) {
                    Start-Process -FilePath $OutputPath -ArgumentList $ArgumentList -Wait
                }
                else {
                    Start-Process -FilePath $OutputPath -Wait
                }
            }
            catch {
                Write-Warning -Message "Failed to install application, download and install application manually."
                Write-Error -Message $_.Exception.Message
                return
            }
        }
        catch {
            Write-Warning -Message "Something went wrong."
            Write-Error -Message $_.Exception.Message
            return
        }
        finally {
            Remove-Item -Path $TempDir -Recurse -Force
            if ($MeasureTime) {
                $ItemEndTime = Get-Date
                Write-Verbose -Message "Item run time: $((New-TimeSpan -Start $FuncStartTime -End $ItemEndTime).TotalSeconds) seconds"
            }
            $Error.Clear()
        }
    }
    end {
        if ($MeasureTime) {
            $FuncEndTime = Get-Date
            Write-Verbose -Message "Function run time: $((New-TimeSpan -Start $FuncStartTime -End $FuncEndTime).TotalSeconds) seconds"
            Write-Verbose -Message "Function end time: $(Get-Date -Date $FuncEndTime -Format FileDateTimeUniversal)"
        }
    }
}

$InstallList = New-Object -TypeName System.Collections.Generic.List[pscustomobject] # [pscustomobject] [string]

$VSCode = [PSCustomObject]@{
    Url          = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
    ArgumentList = "/VERYSILENT", "/NORESTART", "/MERGETASKS=!runcode"
    Filename     = "VSCode.exe"
}
$InstallList.Add($VSCode)

$Steam = [PSCustomObject]@{
    Url          = "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
    ArgumentList = "/S"
}
$InstallList.Add($Steam)

$KeePassXC = [PSCustomObject]@{
    Github       = "keepassxreboot/keepassxc"
    ArgumentList = "/S"
}
$InstallList.Add($KeePassXC)

$Git = [PSCustomObject]@{
    Github       = "git-for-windows/git"
    ArgumentList = "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS"
}
$InstallList.Add($Git)

$InstallList | Install-ApplicationUrl -MeasureTime -Verbose