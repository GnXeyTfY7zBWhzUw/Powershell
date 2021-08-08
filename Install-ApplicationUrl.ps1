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
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FileName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ArgumentList,

        [Parameter(Mandatory = $false)]
        [switch]
        $MeasureTime
    )
    begin {
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
                Write-Verbose -Message "Trying to download $Url"
                if (!($Filename)) {
                    $Filename = ($Url | Select-String -Pattern "[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))").Matches.Value #| Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
                }
                $OutputPath = Join-Path -Path $TempDir -ChildPath $Filename
                Invoke-RestMethod -Method Get -Uri $Url -OutFile $OutputPath
            }
            catch {
                Write-Warning -Message "Failed to download application, download and install application manually."
                Write-Error -Message $_.Exception.Message.ToString()
                return
            }

            try {
                Start-Process -FilePath $OutputPath -ArgumentList $ArgumentList -Wait
            }
            catch {
                Write-Warning -Message "Failed to install application, download and install application manually."
                Write-Error -Message $_.Exception.Message.ToString()
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
    ArgumentList = "/S"
    Filename     = "VSCode.exe"
}
$InstallList.Add($VSCode)

$Steam = [PSCustomObject]@{
    Url          = "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
    ArgumentList = "/S"
}
$InstallList.Add($Steam)

$InstallList | Install-ApplicationUrl -MeasureTime -Verbose