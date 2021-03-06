function Get-DSPamAccounts {
    <#
    .SYNOPSIS
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [guid]$folderID
    )

    BEGIN {
        Write-Verbose '[Get-DSPamAccount] Beginning...'

        $URI = "$Script:DSBaseURI/api/pam/credentials"

        if ([string]::IsNullOrWhiteSpace($Global:DSSessionToken)) {
            throw "Session invalid. Please call New-DSSession."
        }
    }
    PROCESS {
        $params = @{
            Uri    = $URI
            Method = 'GET'
            Body   = $folderID
        }

        $res = Invoke-DS @params
        return $res
    }
    END {
        If ($res.isSuccess) {
            Write-Verbose '[Get-DSPamAccount] Completed Successfully.'
        }
        else {
            Write-Verbose '[Get-DSPamAccount] Ended with errors...'
        }
    }
}