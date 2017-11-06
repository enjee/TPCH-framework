
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkCyan"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator

   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
   }



##############################
# ALL CONSTANTS              #
##############################

# Randomize this run
$random = -join ((48..57) + (97..122) | Get-Random -Count 14 | % {[char]$_})
Write-Output ("This script execution has been randomized with: " + $random)

# Default cluster size (# of worker nodes), version, type, and OS
$clusterSizeInNodes = "4"
$clusterVersion = "3.5"
$clusterType = "Hadoop"
$clusterOS = "Linux"
$clusterName = ($random + "cluster")
$ComputerName = ($clusterName + "-ssh.azurehdinsight.net")
$resourceGroupName = ($random + "group")
$location = "westeurope"


# Credentials
$username = -join ((48..57) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$password = "1Password!"
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

# Files
$Path = ((Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) + "\")
$FilePath = "benchmark.sh"
$SftpPath = '/home/sshuser/'
$File = ($SftpPath + $FilePath)
$command = ('chmod +x ' + $File + ' && ' + $File)
$RemoveCommand = ('rm ' + $File)






##############################
# Azure Powershell           #
##############################


# Install powershell for Azure if not exists
Write-Output "$(Get-Date)"


Write-Output "Checking for Azure Powershell"
if (!(Get-Module -ListAvailable -Name AzureRM)) {
    Install-Module AzureRM
    Import-Module AzureRM
    Write-Output "Azure Powershell installed"
} else {
    Import-Module AzureRM
    Write-Output "Azure Powershell already present"
}

# Login to your Azure subscription
Write-Output "Logging in to your Azure subscription"
$sub = Add-AzureRmAccount



# Create the resource group
Write-Output ("Creating the resource group " + $resourceGroupName + " on your account")
if (!(Get-AzureRmResourceGroup -Name $resourceGroupName -EA 0)) {
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}


$defaultStorageAccountName = ("tpchbenchmark"  + $random)

# Create an Azure storage account and container
Write-Output ("Creating the Azure storage account and container " + $defaultStorageAccountName + " on your account")
New-AzureRmStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $defaultStorageAccountName `
    -Type Standard_LRS `
    -Location $location


$defaultStorageAccountKey = (Get-AzureRmStorageAccountKey `
                                -ResourceGroupName $resourceGroupName `
                                -Name $defaultStorageAccountName)[0].Value
$defaultStorageContext = New-AzureStorageContext `
                                -StorageAccountName $defaultStorageAccountName `
                                -StorageAccountKey $defaultStorageAccountKey






# Set the storage container name to the cluster name
$defaultBlobContainerName = $clusterName

# Create a blob container. This holds the default data store for the cluster.
Write-Output ("Creating the storage container " + $defaultBlobContainerName + " on your account")
New-AzureStorageContainer `
    -Name $clusterName -Context $defaultStorageContext

# Create the HDInsight cluster
Write-Output ("Creating the HDInsight cluster " + $defaultBlobContainerName + " on your account")
New-AzureRmHDInsightCluster `
    -ResourceGroupName $resourceGroupName `
    -ClusterName $clusterName `
    -Location $location `
    -ClusterSizeInNodes $clusterSizeInNodes `
    -ClusterType $clusterType `
    -OSType $clusterOS `
    -Version $clusterVersion `
    -HttpCredential $credentials `
    -DefaultStorageAccountName "$defaultStorageAccountName.blob.core.windows.net" `
    -DefaultStorageAccountKey $defaultStorageAccountKey `
    -DefaultStorageContainer $clusterName `
    -SshCredential $credentials


Write-Output "$(Get-Date)"
Write-Output ("Done creating all resources on your Azure account")



##############################
# SSH INTO SERVER            #
##############################


# Install ssh for powershell
if (!(Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module Posh-SSH
    Import-Module Posh-SSH
} else {
    Import-Module Posh-SSH
}


New-SFTPSession -ComputerName $ComputerName -Credential $credentials
$ssh = New-SSHSession -ComputerName $ComputerName -Credential $credentials -AcceptKey:$true

Write-Output ("Pushing " + $Path + $FilePath + " onto the cluster, at " + $File)
Invoke-SSHCommand -SSHSession $ssh -Command $RemoveCommand
Set-SFTPFile -SessionId 0 -LocalFile ($Path + $FilePath) -RemotePath $SftpPath

Write-Output ("Invoking script " + $File + " on your HDInsight cluster")
Invoke-SSHCommand -SSHSession $ssh -Command $command

Remove-SFTPSession -SessionId 0
Remove-SSHSession -SessionId 0

Write-Output ("Finished executing all scripts through ssh")
Write-Output "$(Get-Date)"
Write-Output ("Removing all earlier created resources from your Azure account")

Remove-AzureRmResourceGroup -Name $resourceGroupName -Force

Write-Output "$(Get-Date)"


read-Host -Prompt "Press Enter to exit"