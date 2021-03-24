function New-DSSession {
<#
.SYNOPSIS
Establishes a session with a Devolutions Server

.DESCRIPTION

.EXAMPLE

.LINK
#>
	[CmdletBinding()]
	param(	
		[ValidateNotNullOrEmpty()]
		[PSCredential]$Credentials,
		[parameter(Mandatory)]
		[string]$BaseURI
)

	BEGIN { 
        Write-Verbose '[New-DSSession] begin...'

		if ($Script:DSBaseURI -ne $BaseURI)
		{
			if ($Script:DSSessionToken)
			{
				throw "Session already established, Close it before switching servers."
			}
		}

		#Get-ServerInfo must be called to get encryption keys...
		if ([string]::IsNullOrWhiteSpace($Script:DSSessionKey))
		{
			$info = Get-DSServerInfo -BaseURI $BaseURI
			if ($false -eq $info.IsSuccess)
			{
				throw "Unable to get server information"
			}
		}

		$URI = "$Script:DSBaseURI/api/login/partial"
	
	}

	PROCESS {

		$safePassword = Protect-ResourceToHexString $Credentials.GetNetworkCredential().Password

		$Body = @{
			userName = $Credentials.UserName
			RDMOLoginParameters = @{
				SafePassword = $safePassword
				SafeSessionKey = $Script:DSSafeSessionKey
				Client = 'Scripting'
				Version = $MyInvocation.MyCommand.Module.Version.ToString()
				LocalMachineName = [Environment]::MachineName
				LocalUserName = [Environment]::UserName
			}
		}
		
		#body is typed as a HashTable, I'd like to offer an override that pushes the conversion downstream
		$response = Invoke-WebRequest -URI $URI -Method Post -ContentType 'application/json'  -Body ($Body | ConvertTo-Json) -SessionVariable Script:WebSession
		If ($null -ne $response) {
			$jsonContent = $response.Content | ConvertFrom-JSon
			Write-Verbose "[New-DSSession] Got authentication token $($jsonContent.data.tokenId)"
			Write-Verbose "[New-DSSession] Connected to ""$($jsonContent.data.serverInfo.servername)"""

			If ([System.Management.Automation.ActionPreference]::SilentlyContinue -ne $DebugPreference) {
					Write-Debug "[Response.Data] $($jsonContent.data)"
			}

			Set-Variable -Name DSSessionToken -Value $jsonContent.data.tokenId -Scope Script
			$Script:WebSession.Headers["tokenId"] = $jsonContent.data.tokenId

			return [ServerResponse]::new(($response.StatusCode -eq 200), $response, $jsonContent, $null, "", $response.StatusCode)
		}

		return [ServerResponse]::new(($false), $null, $null, $null, "", 500)	
	}

	END { 
		if ($?) {
			Write-Verbose '[New-DSSession ] Completed Successfully.'
		} else {
			Write-Verbose '[New-DSSession ] ended with errors...'
		}
	}

}