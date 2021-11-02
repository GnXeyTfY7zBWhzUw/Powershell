function Sync-ADObjectAllDCs {
    <#
    .SYNOPSIS
        Syncs AD object across all DCs
    .DESCRIPTION
        Syncs AD object across all DCs, except the DC you're currently connected to.
    .EXAMPLE
        Sync-ADObjectAllDCs -ADObject "CN=Some Person Here,CN=Users,DC=contoso,DC=com"
        Sync-ADObjectAllDCs -ADObject 46952533-1c47-4272-9b20-456ff4979c65
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "ADObject")]
        [ValidateScript({Get-ADObject -Identity $_})]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $ADObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ObjectGUID")]
        [ValidateScript({Get-ADObject -Identity $_})]
        $ObjectGUID,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "DistinguishedName")]
        [string]
        [ValidateScript({Get-ADObject -Identity $_})]
        $DistinguishedName
    )
    begin {
        $CurrentDC = Get-ADDomainController
        $DCs = Get-ADDomainController -Filter *
    }
    process {
        if ($DistinguishedName) {
            $ADObject = $ObjectGUID
        }
        if ($DistinguishedName) {
            $ADObject = $DistinguishedName
        }
        foreach ($DC in $DCs) {
            # If you want to exclude current DC, but doesn't really matter
            if ($DC.HostName -eq $CurrentDC.HostName) {
                continue
            }
            Write-Verbose "Syncing $($CurrentDC.HostName) with $($DC.HostName)"
            Sync-ADObject -Object $ADObject -Source $CurrentDC.HostName -Destination $DC.HostName
        }
    }
}
