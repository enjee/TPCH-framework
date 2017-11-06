Write-Output "$(Get-Date)"


# Install powershell for Azure if not exists
if (!(Get-Module -ListAvailable -Name AzureRM)) {
    Install-Module AzureRM
    Import-Module AzureRM
}

# Enable Running Scripts
Set-ExecutionPolicy RemoteSigned


# Login to your Azure subscription
$sub = Add-AzureRmAccount

# Randomize this run
$random = -join ((48..57) + (97..122) | Get-Random -Count 5 | % {[char]$_})

# Get user input/default values
$resourceGroupName = "tpchbenchmarkgroup"
$location = "westeurope"


# Create the resource group
if (!(Get-AzureRmResourceGroup -Name $resourceGroupName -EA 0)) {
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}


$defaultStorageAccountName = "tpchbenchmark"

# Create an Azure storage account and container
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

$username = "sshuser"
$password = "1Password!"
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr


# Default cluster size (# of worker nodes), version, type, and OS
$clusterSizeInNodes = "4"
$clusterVersion = "3.5"
$clusterType = "Hadoop"
$clusterOS = "Linux"
$clusterName = "tpchbenchmark"

# Set the storage container name to the cluster name
$defaultBlobContainerName = $clusterName

# Create a blob container. This holds the default data store for the cluster.
New-AzureStorageContainer `
    -Name $clusterName -Context $defaultStorageContext

# Create the HDInsight cluster
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

# Install ssh for powershell
if (!(Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module Posh-SSH
    Import-Module Posh-SSH
}

$clusterName = "tpchbenchmark"
New-SFTPSession -ComputerName "tpchbenchmark-ssh.azurehdinsight.net" -Credential $credentials
$ssh = New-SSHSession -ComputerName "tpchbenchmark-ssh.azurehdinsight.net" -Credential $credentials

$FilePath = "benchmark.sh"
$SftpPath = '/home/sshuser/'
$File = ($SftpPath + $FilePath)
$command = ('chmod +x ' + $File + ' && ' + $File)
$RemoveCommand = ('rm ' + $File)

Invoke-SSHCommand -SSHSession $ssh -Command $RemoveCommand
Set-SFTPFile -SessionId 0 -LocalFile $FilePath -RemotePath $SftpPath
Invoke-SSHCommand -SSHSession $ssh -Command $command

Remove-SFTPSession -SessionId 0
Remove-SSHSession -SessionId 0

Write-Output "$(Get-Date)"

Remove-AzureRmResourceGroup -Name $resourceGroupName -Force

Write-Output "$(Get-Date)"