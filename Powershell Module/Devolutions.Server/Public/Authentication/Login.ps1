function Login {
    [CmdletBinding()]
    PARAM (
        [ValidateNotNullOrEmpty()]
        [string]$Username = $(throw 'empty username'),
        [ValidateNotNullOrEmpty()]
        [string]$Password = $(throw 'empty password'),
        [ValidateNotNullOrEmpty()]
        [string]$URL = $(throw 'empty URL')
    )
    
    BEGIN {
        Write-Verbose '[Login] Beginning...'
    }
    
    PROCESS {
        #1. Create PSCredentials for authentication
        [securestring]$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        [pscredential]$Credentials = [pscredential]::new($Username, $SecurePassword)

        #2. Fetch server information
        try {
            $ServerResponse = Invoke-WebRequest -Uri "$URL/api/server-information" -Method 'GET' -SessionVariable Global:WebSession

            if ((Test-Json $ServerResponse.Content -ErrorAction SilentlyContinue) -and (@(Compare-Object (ConvertFrom-Json $ServerResponse.Content).PSObject.Properties.Name @('data', 'result')).Length -eq 0)) {
                $ServerResponse = ConvertFrom-Json $ServerResponse.Content

                if ($ServerResponse.result -ne [Devolutions.RemoteDesktopManager.SaveResult]::Success) {
                    throw '[Login] Unhandled error while fetching server information. Please submit a ticket if problem persists.'
                }
            }
            else {
                throw "[Login] There was a problem reaching your DVLS instance. Either you provided a wrong URL or it's not pointing to a DVLS instance."
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }

        #3. Setting server related variables
        $SessionKey = New-CryptographicKey
        $SafeSessionKey = Encrypt-RSA $ServerResponse.data.publicKey.modulus $ServerResponse.data.publicKey.exponent $SessionKey
        
        Set-Variable -Name DSSessionKey -Value $SessionKey -Scope Global
        Set-Variable -Name DSSafeSessionKey -Value $SafeSessionKey -Scope Global
        Set-Variable -Name DSInstanceVersion -Value $ServerResponse.data.version -Scope Global
        Set-Variable -Name DSInstanceName -Value $ServerResponse.data.serverName -Scope Global

        #4. Actually logging in
        $SafePassword = Protect-ResourceToHexString $Credentials.GetNetworkCredential().Password
        $ModuleVersion = (Get-Module Devolutions.Server).Version.ToString()

        $RequestParams = @{
            URI         = "$URL/api/login/partial"
            Method      = 'POST'
            ContentType = 'application/json'
            WebSession  = $Global:WebSession
            Body        = ConvertTo-Json @{
                userName            = $Credentials.UserName
                RDMOLoginParameters = @{
                    SafePassword     = $SafePassword
                    SafeSessionKey   = $Global:DSSafeSessionKey
                    Client           = 'Scripting'
                    Version          = $ModuleVersion
                    LocalMachineName = [System.Environment]::MachineName
                    LocalUserName    = [System.Environment]::UserName
                }
            } -Depth 3
        }

        try {
            $LoginResponse = Invoke-WebRequest @RequestParams

            if ((Test-Json $LoginResponse.Content -ErrorAction SilentlyContinue) -and (@(Compare-Object (ConvertFrom-Json $LoginResponse.Content).PSObject.Properties.Name @('data', 'result')).Length -eq 0)) {
                $LoginContent = ConvertFrom-Json $LoginResponse.Content

                if ($LoginContent.result -ne [Devolutions.RemoteDesktopManager.SaveResult]::Success) {
                    throw $LoginContent.data.message
                }
            }
            else {
                throw '[Login] Unhandled error while logging in. Please submit a ticket if problem persists.'
            }
        }
        catch {
            throw $_.Exception.Message
        }
        
        Set-Variable -Name DSSessionToken -Value $LoginContent.data.tokenId -Scope Global
        $Global:WebSession.Headers.Add('tokenId', $LoginContent.data.tokenId)

        $NewResponse = New-ServerResponse -response $LoginResponse -method 'POST'
        return $NewResponse
    }
    
    END {
        if ($NewResponse.isSuccess) {
            Write-Verbose "[Login] Successfully logged in to $($ServerInfos.data.servername)"
        }
        else {
            Write-Verbose '[Login] Could not log in. Please verify URL and credentials.'
        }
    }
}