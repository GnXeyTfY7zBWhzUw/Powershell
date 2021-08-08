function Install-Git {
        <#
    .SYNOPSIS
        Lorem ipsum
    .DESCRIPTION
        Adapted from https://www.robvit.com/automation/install-git-with-powershell-on-windows/
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

            try {
                git
            }
            catch {
                Write-Verbose -Message "Git not available."
                Write-Verbose -Message "Downloading and installing git."
                $InstallGit = $true
            }
            if ($InstallGit) {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $Releases = "https://api.github.com/repos/git-for-windows/git/releases"
                $Response = Invoke-WebRequest -Uri $Releases -UseBasicParsing | ConvertFrom-Json
                $DownloadUrl = $Response.assets | Where-Object { ($_.Name -like "*64*.exe" -or $_.Name -like "*64*.msi") -and (-not($_.Name -like "*rc*" -or $_.Name -like "*zip*" -or $_.Name -like "*7z*")) } | Sort-Object -Property created_at -Descending | Select-Object -First 1

                # Download file to temporary folder
                Write-Verbose -Message "Trying to download $($DownloadUrl.browser_download_url)."
                try {
                    $OutputPath = Join-Path -Path $TempDir -ChildPath $($DownloadUrl.Name)
                    Invoke-RestMethod -Method Get -Uri $DownloadUrl.browser_download_url -OutFile $OutputPath
                }
                catch {
                    Write-Verbose -Message "Failed to download git, download and install git manually."
                    Write-Verbose -Message "Download location: $($DownloadUrl.browser_download_url)"
                    Write-Error -Message $_.Exception.Message
                }

                Write-Verbose -Message "Trying to install git."

                try {
                    $Arguments = "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS"
                    Start-Process -FilePath $OutputPath -ArgumentList -Wait
                }
                catch {
                    Write-Verbose -Message "Failed to install Git on your laptop, download and install GIT Manually."
                    Write-Verbose -Message "Download Location: https://gitforwindows.org/"
                    Write-Error -Message $_.Exception.Message
                }
            }
            else {
                Write-Verbose -Message "Git is already installed, no action needed."
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

Install-Git -MeasureTime -Verbose