function Install-Git {
        <#
    .SYNOPSIS
        Lorem ipsum
    .DESCRIPTION
        Lorem ipsum
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
        $TempDir = New-Item -Type Directory -Name $([System.Guid]::NewGuid().ToString()) -Path $([IO.Path]::GetTempPath().ToString()) -Force
        $TempDir = $TempDir | Select-Object -ExpandProperty FullName
    }
    process {
        try {
            git
        }
        catch {
            Write-Verbose -Message "Git not available."
            Write-Verbose -Message "Downloading and installing git."
            $InstallGit = $True
        }
        if ($InstallGit) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $Releases = "https://api.github.com/repos/$repo/git/releases"
            $Response = Invoke-WebRequest -Uri $Releases -UseBasicParsing | ConvertFrom-Json
            $DownloadUrl = $Response.assets | Where-Object { $_.Name -match "-64-bit.exe" -and $_.Name -notmatch "rc" } | Sort-Object -Property created_at -Descending | Select-Object -First 1

            # --- Download the file to the current location
            Write-Verbose -Message "Trying to download $($repo)."
            try {
                $OutputPath = Join-Path -Path $TempDir -ChildPath $($DownloadUrl.Name)
                Invoke-RestMethod -Method Get -Uri $DownloadUrl.browser_download_url -OutFile $OutputPath
            }
            catch {
                Write-Verbose -Message $_.Exception.Message
                Write-Verbose -Message "Failed to download git on your laptop, download and install git manually."
                Write-Verbose -Message "Download location: https://gitforwindows.org/"
            }

            Write-Verbose -Message "Trying to install git."

            try {
                $arguments = "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS"
                Start-Process $OutputPath $arguments -Wait
            }
            catch {
                Write-Verbose -Message $_.Exception.Message
                Write-Verbose -Message "Failed to install Git on your laptop, download and install GIT Manually."
                Write-Verbose -Message "Download Location: https://gitforwindows.org/"
            }

        }
        else {
            Write-Verbose -Message "Git is already installed, no action needed."
        }
    }
    end {
        Remove-Item -Path $TempDir -Recurse -Force
    }
}

Install-Git -Repo "git-for-windows" -Verbose