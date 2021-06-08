using namespace System.Management.Automation

class ConnectionLogMessageSubTypeValidator : IValidateSetValuesGenerator {
	[string[]]GetValidValues() {
		return ('PasswordAnalyzer', 'AdministrationLogs', 'ConnectedUserList', 'ConnectionExpiredEntry', 'DeletedEntries', 'LastUsageLog', 'SharedConnectionLog', 'LoginHistory', 'LoginAttempt', 'ServerLogs', 'OpenedConnections', 'CopiedPasswordToClipboard', 'RequestedForWebEdit', 'DontHaveRight', 'UserIsNotFoundOrIncorrectPassword', 'InvalidAttachmentId', 'CantAccessAnotherUsersRoamingSetting', 'DatabaseUsersAreNotAllowed', 'DomainUsersAreNotAllowed', 'CustomUsersAreNotAllowed', 'LocalMachineUsersAreNotAllowed', 'NotAllowedToSaveUser', 'CannotDeleteEntry', 'InvalidRepositoryId', 'CannotSaveRole', 'NotAllowedToChangePassword', 'NotAllowedToSaveRole', 'IncorrectUserType', 'NotAllowedToManageAttachments', 'NotAllowedToAddInFolder', 'NotAllowedToSaveEntry', 'NotAllowedToDeleteEntry', 'NotAllowedToCheckin', 'NotAllowedToGetTwoFactorInformation', 'NotAllowedToViewAttachment', 'NotTheUsersPrivateVault', 'NotAllowedToDeleteEntryHistory', 'LicenseDoesNotAllowEntryInteraction', 'MustBeAnAdministrator', 'NotAllowedToViewEntry', 'EntryNotFound', 'NoAllowedToViewEntryHistory', 'NotAllowedToCheckoutEntry', 'NotAllowedToGetCheckoutInformation', 'NotAllowedToGetCheckoutsForUser', 'NotAllowedToManageHandbooks', 'NotAllowedToGetHandbookPages', 'NotAllowedToViewLogs', 'NotAllowedToViewPasswordHistory', 'UserSpecificSettingsNotAllowed', 'InvalidConnectionId', 'NotAllowedToViewDeletedEntries', 'NotAllowedToViewTemplates', 'NotAllowedToCopyToClipboard', 'NotAllowedToViewPassword', 'NotAllowedToManageUsers', 'NotAllowedToResetPassword', 'OnlyRecipientCanDeleteAttachement', 'InvalidAccessToken', 'CantReleaseAnotherUsersLock', 'UserDoesNotHaveAccessToVault', 'OnlyRecipientCanSaveSecureAttachment', 'OnlyRecipientCanReadSecureMessage', 'TwoFactorNotConfigured')
	}
}