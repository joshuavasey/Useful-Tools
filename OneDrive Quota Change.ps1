$TenantUrl = Read-Host "Enter the SharePoint admin center URL" 
Connect-SPOService -Url $TenantUrl 

$OneDriveSite = Read-Host "Enter the OneDrive Site URL" 
$OneDriveStorageQuota = Read-Host "Enter the OneDrive Storage Quota in MB" 
$OneDriveStorageQuotaWarningLevel = Read-Host "Enter the OneDrive Storage Quota Warning Level in MB" 
Set-SPOSite -Identity $OneDriveSite -StorageQuota $OneDriveStorageQuota -StorageQuotaWarningLevel $OneDriveStorageQuotaWarningLevel 
Write-Host "Done" 