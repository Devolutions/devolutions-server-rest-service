function Get-DSEntrySensitiveData {
    <#
    .SYNOPSIS
    
    .DESCRIPTION
    
    .EXAMPLE
    
    .NOTES
    Only works for DVLS 2020.3.17 and later.
    #>
    [CmdletBinding()]
    param(			
        [ValidateNotNullOrEmpty()]
        [guid]$EntryId    
    )
 
    BEGIN {
        Write-Verbose '[Get-DSEntrySensitiveData] begin...'
        if ([string]::IsNullOrWhiteSpace($Global:DSSessionToken)) {
            throw "Session does not seem authenticated, call New-DSSession."
        }

        if ([string]::IsNullOrWhiteSpace($Script:DSInstanceVersion)) {
            throw "Your Devoltions Server version is not supported by this module. Please update to the latest stable release."
        }
    }
    
    PROCESS {
        try {        
            if (($LegacyRequested) -or (Confirm-DSServerVersionAtLeast -CandidVersion "2020.3.17")) {
                [ServerResponse]$response = Get-DSEntrySensitiveDataLegacy @PSBoundParameters
            }
            else {
                #TODO Get-DSEntrySensitiveDataModern ?
                throw [System.Exception]::new("Retreiving entries's sensitive data is supported only for DVLS v2020.3.17 and later. Please consider updating your DVLS instance.")
            }

            return $response
        }
        catch {
            $ErrorRecord = $_
            Write-Host
        }
    }
    
    END {
        If (!$? -and $response.isSuccess) {
            Write-Verbose '[Get-DSEntrySensitiveData] Completed Successfully.'
        }
        else {
            Write-Verbose '[Get-DSEntrySensitiveData] Ended with errors...'
        }
    }
}