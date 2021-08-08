function Install-Steam {
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
        [Parameter(Mandatory = $false)]
        [Switch]
        $MeasureTime
    )
    begin {
        $ErrorActionPreference = 'Stop'
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
                $Url = "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
                Write-Verbose -Message "Trying to download $Url."
                $Filename = ($Url | Select-String -Pattern "[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))").Matches.Value #| Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
                $OutputPath = Join-Path -Path $TempDir -ChildPath $Filename
                Invoke-RestMethod -Method Get -Uri $Url -OutFile $OutputPath
            }
            catch {
                Write-Verbose -Message "Failed to download Steam, download and install Steam manually."
                Write-Verbose -Message "Download location: $Url"
                Write-Error -Message $_.Exception.Message
            }

            try {
                $Arguments = "/S"
                Start-Process $OutputPath $Arguments -Wait
            }
            catch {
                Write-Verbose -Message "Failed to install Steam on your laptop, download and install Steam manually."
                Write-Verbose -Message "Download location: $Url"
                Write-Error -Message $_.Exception.Message
            }
        }
        catch {
            Write-Error -Message $_.Exception.Message
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

Install-Steam -MeasureTime -Verbose