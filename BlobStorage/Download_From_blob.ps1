#=====================================================================================================
# Created on:   29.01.2021
# Created by:   Mattias Melkersen
# Version:	    0.1 
# Mail:         mm@mindcore.dk
# Twitter:      MMelkersen
# Function:     Sample script to download files locally to the device
# 
# Special Thanks: 
# Tom Degreef https://www.oscc.be/sccm/Logging-in-the-cloud-Part-1/
#
# Requirements:
# install-module azure.storage and AzureRM.profile
#
# This script is provided As Is
# Compatible with Windows 10 and later
#=====================================================================================================

If(-not(Get-InstalledModule azure.storage -ErrorAction silentlycontinue)){
    Install-Module azure.storage -Confirm:$False -Force
}

Import-Module azure.storage

$BlobProperties = @{

    StorageAccountName   = 'mindlabstorage'
    storSas              = '?sp=racwdl&st=2021-01-29T11:14:39Z&se=2021-01-30T11:14:39Z&sv=2019-12-12&sr=c&sig=hlGukRFNPifzFgBNG8RMhlWg%2Fh9hNKrLOdQ%2FPZcMHTI%3D'
    container            = 'osdlogs'
}

if (!(test-path "C:\LogsFromAzure"))
{
    New-Item -ItemType Directory -Path "C:\LogsFromAzure"
}

$clientContext = New-AzureStorageContext -SasToken ($BlobProperties.storsas) -StorageAccountName ($blobproperties.StorageAccountName)

$files = Get-AzureStorageBlob -Container ($BlobProperties.container) -Context $clientContext 

foreach ($file in $files)
{
    write-host $file.name
    Get-AzureStorageBlobContent -Destination "C:\LogsFromAzure" -Container ($BlobProperties.container) -Context $clientContext -Blob $file.name
   
    write-host "expanding logfiles"
    Expand-Archive -Path "C:\LogsFromAzure\$($file.name)" -DestinationPath "C:\LogsFromAzure"

    write-host "cleaning up"
    Remove-Item -Path "C:\LogsFromAzure\$($file.name)" -Force

    Remove-AzureStorageBlob -Container ($BlobProperties.container) -Context $clientContext -Blob $file.name
  
}