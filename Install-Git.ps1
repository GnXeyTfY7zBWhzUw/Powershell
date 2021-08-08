function Install-Git {
        <#
    .SYNOPSIS
        Lorem ipsum
    .DESCRIPTION
        Adapted from https://www.robvit.com/automation/install-git-with-powershell-on-windows/
    .EXAMPLE
        Lorem ipsum
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $false)]
        [string]
        $Repo
    )
    begin {
        $ErrorActionPreference = 'Stop'
    }
    process {
        try {
            $TempPath = [IO.Path]::GetTempPath().ToString()
            $TempGuid = [System.Guid]::NewGuid().ToString()
            $TempDir = Join-Path -Path $TempPath -ChildPath $TempGuid
            if (!(Test-Path -Path $TempDir)) {
                $TempDir = New-Item -Type Directory -Path $TempPath -Name $TempGuid
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
                $Releases = "https://api.github.com/repos/$repo/git/releases"
                $Response = Invoke-WebRequest -Uri $Releases -UseBasicParsing | ConvertFrom-Json
                $DownloadUrl = $Response.assets | Where-Object { $_.Name -match "-64-bit.exe" -and $_.Name -notmatch "rc" } | Sort-Object -Property created_at -Descending | Select-Object -First 1

                # Download file to temporary folder
                Write-Verbose -Message "Trying to download $($repo)."
                try {
                    $OutputPath = Join-Path -Path $TempDir -ChildPath $($DownloadUrl.Name)
                    Invoke-RestMethod -Method Get -Uri $DownloadUrl.browser_download_url -OutFile $OutputPath
                }
                catch {
                    Write-Verbose -Message "Failed to download git on your laptop, download and install git manually."
                    Write-Verbose -Message "Download location: https://gitforwindows.org/"
                    Write-Error -Message $_.Exception.Message
                }

                Write-Verbose -Message "Trying to install git."

                try {
                    $arguments = "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS"
                    Start-Process $OutputPath $arguments -Wait
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
        }
    }
    end {

    }
}

Install-Git -Repo "git-for-windows" -Verbose