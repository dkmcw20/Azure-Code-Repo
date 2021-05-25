$resourceGroup = "AUSE-DEV-KIWI-RG"
$DiskName = "ODC1AP0027"
$NewDiskName = "ODC1AP0027_OSDISK"
$SubName = "AZPCM29421001-M-Opal"

Connect-AzAccount

#! Get source OS Disk information
Write-Verbose "Get the source OS Disk information: $($VM.StorageProfile.OsDisk.Name)"
$sourceOSDisk = Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $DiskName

#! Create the managed disk configuration
Write-Verbose "Create the managed disk configuration..."
$diskConfig = New-AzDiskConfig -SkuName $sourceOSDisk.Sku.Name -Location $sourceOSDisk.Location -DiskSizeGB $sourceOSDisk.DiskSizeGB -SourceResourceId $sourceOSDisk.Id -CreateOption Copy

#! Create the new disk
Write-Verbose "Create the new OS disk..."
$newOSDisk = New-AzDisk -Disk $diskConfig -DiskName $NewDiskName -ResourceGroupName $resourceGroup
