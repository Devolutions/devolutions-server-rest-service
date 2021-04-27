function New-DSUser {
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
        
    #>
    [CmdletBinding()]
    PARAM (
        #General tab
        [validateset([Devolutions.RemoteDesktopManager.ServerUserType]::Builtin, [Devolutions.RemoteDesktopManager.ServerUserType]::Domain)]
        [string]$AuthenticationType = [Devolutions.RemoteDesktopManager.ServerUserType]::Builtin,

        [Devolutions.RemoteDesktopManager.UserType]$UserType = [Devolutions.RemoteDesktopManager.UserType]::User, #TODO Maybe not needed
        [Devolutions.RemoteDesktopManager.UserLicenceTypeMode]$UserLicenseType = [Devolutions.RemoteDesktopManager.UserLicenceTypeMode]::Default,

        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [string]$FirstName = "",
        [string]$LastName = "",
        [string]$Email = "",
        [ValidateSet("English", "French", "German", "Spanish", "Hungarian", "Italian", "Dutch", "Polish (Poland)", "Russian", "Swedish", "Ukrainian", "Chinese (Simplified) Legacy", "Chinese (Traditional, Taiwan)", "Czech")]
        [string]$Language = "English",
        [bool]$Enabled = $true,
        [bool]$ChangePasswordNextLogon = $false,

        #Information tab
        [string]$Company = "",
        [string]$JobTitle = "",
        [string]$Department = "",
        [string]$GravatarEmail = "",
        [string]$Address = "",
        [string]$State = "",
        [string]$Country = "", #TODO Find a way to validateset country name
        [string]$Phone = "",
        [string]$Work = "",
        [string]$Mobile = "",
        [string]$Fax = "",

        #Application access tab
        [bool]$HasAccessRDM = $true,
        [bool]$HasAccesWebLogin = $true,
        [bool]$HasAccessLauncher = $true,
        [bool]$HasAccessWeb = $true,
        [bool]$HasAccessCLI = $true,

        #Privileges tab
        [bool]$AllowDragAndDrop = $true, #CustomSecurityEntity
        [bool]$CanViewInformations = $true, #CustomSecurityEntity
        [bool]$CanViewGlobalLogs = $true, #CustomSecurityEntity
        [bool]$CanImport = $true, #CustomSecurityEntity
        [bool]$CanExport = $true, #CustomSecurityEntity

        [ValidateSet([Devolutions.RemoteDesktopManager.OfflineMode]::Disabled, [Devolutions.RemoteDesktopManager.OfflineMode]::ReadOnly, [Devolutions.RemoteDesktopManager.OfflineMode]::ReadWrite)]
        [string]$OfflineMode = [Devolutions.RemoteDesktopManager.OfflineMode]::ReadWrite #CustomSecurityEntity
    )
    
    BEGIN {
        Write-Verbose "[New-DSUser] Begining..."

        $URI = "$env:DS_URL/api/security/user/save?csToXml=1"
    }
    
    PROCESS {
        $Parameters = Get-ParameterValues
        
        $User = @{
            Display      = $Username
            UserAccount  = Get-DSUserAccountSegment $Parameters
            UserProfile  = Get-DSUserProfileSegment $Parameters
            UserSecurity = Get-DSUserSecuritySegment $Parameters
        }

        $RequestParams = @{
            URI    = $URI
            Method = "PUT"
            Body   = $User | ConvertTo-Json
        }

        $res = Invoke-DS @RequestParams -Verbose
        return $res
    }
    
    END {
        if ($res.isSuccess) {
            Write-Verbose "[New-DSUser] Completed successfully!"
        }
        else {
            Write-Verbose "[New-DSUser] Ended with errors..."
            Write-Error $res.ErrorMessage
        }
    }
}