function Initialize-Github {
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
        [String]
        $Git,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]
        $GithubDir = $(Join-Path -Path $Home -ChildPath "Github"),

        [Parameter(Mandatory = $false)]
        [Switch]
        $Clone,

        [Parameter(Mandatory = $false)]
        [Switch]
        $Mirror,

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
        try {
            git > $null
        }
        catch {
            Write-Error -Message "Git not available. Please install before running." -ErrorAction Stop
        }
    }
    process {
        try {
            try {
                if ($Clone) {
                    $GitAuthor = $Git | Select-String -Pattern "^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"
                    $GitAuthor = $GitAuthor.Matches.Groups.Value[4]
                    $GithubDir = Join-Path -Path $GithubDir -ChildPath $GitAuthor
                }
                if ($(Test-Path -Path $GithubDir) -and $Mirror) {
                    Set-Location -Path $GithubDir
                    git init
                    git remote add origin $Git
                    git fetch
                    git checkout origin/master -ft
                    return
                }
                else {
                    $GithubDir = New-Item -Path $GithubDir -ItemType Directory -Force
                    $GithubDir = $GithubDir | Select-Object -ExpandProperty FullName
                    Set-Location -Path $GithubDir
                    git clone $Git
                    return
                }
            }
            catch {
                Write-Error -Message $_.Exception.Message
            }
        }
        catch {
            Write-Error -Message $_.Exception.Message
        }
        finally {
            $Error.Clear()
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