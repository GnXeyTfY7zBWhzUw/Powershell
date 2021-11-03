function Measure-LastCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]
        $History = 1,

        [Parameter(Mandatory = $false)]
        [switch]
        $ShowCommandLine,

        [Parameter(Mandatory = $false)]
        [switch]
        $Total
    )
    begin {}
    process {
        $LastCommands = Get-History -Count $History
        if ($LastCommands) {
            $RunTimes = [System.Collections.Generic.List[psobject]]::new()
            foreach ($LastCommand in $LastCommands) {
                if ($ShowCommandLine) {
                    $LastCommand.CommandLine
                }
                $RunTime = New-TimeSpan -Start $LastCommand.StartExecutionTime -End $LastCommand.EndExecutionTime
                $RunTimes.Add($RunTime)
                if ($Total) {
                    continue
                }
                else {
                    $RunTimes
                }
            }
            if ($Total) {
                $TotalMilliseconds = 0
                foreach ($RunTime in $RunTimes) {
                    $TotalMilliseconds = $TotalMilliseconds + $RunTime.TotalMilliseconds
                }
                $RunTime = [TimeSpan]::FromMilliseconds($TotalMilliseconds)
                $RunTime
            }
        }
        else {
            Write-Error -Message "No commands to measure."
        }
    }
    end {}
}
