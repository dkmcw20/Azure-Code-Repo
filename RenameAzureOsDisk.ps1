<#.EXAMPLE
.\Rename-AzOSDisk.ps1 -resourceGroup [ResourceGroupName] -VMName [VMName] -osdiskName [OSDiskName] -Verbose
This example will rename the OS Disk for the specified VM, you need to specify the Resource Group name, VM name and the new OS disk name.
Then the script will use the Swap OS disk feature in Azure and change the OS disk on the fly.
#>
[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = 'Enter the Resource Group of the VM')]
    [Alias('rg')]
    [String]$resourceGroup,

    [Parameter(Position = 1, Mandatory = $True, HelpMessage = 'Enter Azure VM name')]
    [Alias('VM')]
    [String]$VMName,

    [Parameter(Position = 2, Mandatory = $true, HelpMessage = 'Enter the desired OS Disk name')]
    [Alias('DiskName')]
    [String]$osdiskName,

    [Parameter(Position = 3, Mandatory = $true, HelpMessage = 'Enter the SubsriptionName name')]
    [Alias('SubscriptionName')]
    [String]$SubName

)

#! Check Azure Connection
Try {
    Write-Verbose "Connecting to Azure Cloud..."
    Connect-AzAccount -Subscription $SubName -ErrorAction Stop | Out-Null
}
Catch {
    Write-Warning "Cannot connect to Azure Cloud. Please check your credentials. Exiting!"
    Break
}

#Select the Azure Subscription
#Select-AzSubscription -SubscriptionName $SubName

#! Get the details of the VM
Write-Verbose "Get the VM information details: $VMName"
$VM = Get-AzVM -Name $VMName -ResourceGroupName $resourceGroup

#! Get source OS Disk information
Write-Verbose "Get the source OS Disk information: $($VM.StorageProfile.OsDisk.Name)"
$sourceOSDisk = Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $VM.StorageProfile.OsDisk.Name

#! Create the managed disk configuration
Write-Verbose "Create the managed disk configuration..."
$diskConfig = New-AzDiskConfig -SkuName $sourceOSDisk.Sku.Name -Location $VM.Location `
    -DiskSizeGB $vm.StorageProfile.OsDisk.DiskSizeGB -SourceResourceId $sourceOSDisk.Id -CreateOption Copy

#! Create the new disk
Write-Verbose "Create the new OS disk..."
$newOSDisk = New-AzDisk -Disk $diskConfig -DiskName $osdiskName -ResourceGroupName $resourceGroup

#! Swap the OS Disk
Write-Verbose "Swap the OS disk to: $osdiskName"
Set-AzVMOSDisk -VM $VM -ManagedDiskId $newOSDisk.Id -Name $osdiskName | Out-Null
Write-Verbose "The VM is rebooting..."
Update-AzVM -ResourceGroupName $resourceGroup -VM $VM

#! Delete the old OS Disk
$delete = Read-Host "Do you want to delete the original OS Disk [y/n]"
If ($delete -eq "y" -or $delete -eq "Y") {
    Write-Warning "Deleting the old OS Disk: $($sourceOSDisk.Name)"
    Remove-AzDisk -ResourceGroupName $resourceGroup -DiskName $sourceOSDisk.Name -Force -Confirm:$false
}
