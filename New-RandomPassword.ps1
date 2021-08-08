function New-RandomPassword {
    <#
    .SYNOPSIS
        Lorem ipsum
    .DESCRIPTION
        Modified from https://mohitgoyal.co/2017/01/13/generate-random-password-using-powershell/
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]
        $maxChars = 16, # Specifies the default maximum no of characters to be generated for password can be override by passing parameter values while calling function

        [Parameter(Mandatory = $false)]
        [switch]
        $SecureString
    )
    do {
        $Password = $null # Specifies a new empty password
        $rand = New-Object System.Random # Defines random function
        0..$maxChars | ForEach-Object { $Password += [char]$rand.Next(33, 126) } # http://www.asciitable.com/ 33,126 is a random letter, number, or symbolx.
      } until ($Password -cmatch '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W).*$') # This regex ensures lowercase, uppercase, number, and special character
    if ($SecureString){
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
    }
    return $Password
}
