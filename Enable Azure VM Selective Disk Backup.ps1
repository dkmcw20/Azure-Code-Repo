#enable Selective disk backup

Connect-AzAccount 

Get-AzDisk -ResourceGroupName "ResourceGroupName"

$Vm = Get-AzVM -ResourceGroupName "ResourceGroupName" -Name "Servername"

$vm.StorageProfile.DataDisks

#update the Lun Number
$disks = (“1”)
#Set the Target Vault
$targetVault = Get-AzRecoveryServicesVault -ResourceGroupName "ResourceGroupName Recovery Service Vault" -Name "RecoveryServiceVaultName"

#Set the recovery service vault configuraion
Set-AzRecoveryServicesVaultContext -Vault $targetVault

#set backup policy
$pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name “DEV12AM7D”

#Enable backup
Enable-AzRecoveryServicesBackupProtection -Policy $pol -Name “ServerName” -ResourceGroupName “ResourceGroup” -InclusionDisksList $disks -VaultId $targetVault.ID

$item= Get-AzRecoveryServicesBackupItem -BackupManagementType “AzureVM” -WorkloadType “AzureVM” -VaultId $targetVault.ID -FriendlyName “LinuxVm01”