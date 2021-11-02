function Measure-LastCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]
        $History = 1,

        [Parameter(Mandatory = $false)]
        [switch]
        $ShowCommandLine
    )
    begin {}
    process {
        $LastCommands = Get-History -Count $History
        if ($LastCommands) {
            foreach ($LastCommand in $LastCommands) {
                if ($ShowCommandLine) {
                    $LastCommand.CommandLine
                }
                $RunTime = New-TimeSpan -End $LastCommand.EndExecutionTime -Start $LastCommand.StartExecutionTime
                $Runtime
            }
        }
    }
    end {}
}
