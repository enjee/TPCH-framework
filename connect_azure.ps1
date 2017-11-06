
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

# Get information for the HDInsight cluster
# Cluster login is used to secure HTTPS services hosted on the cluster
$httpCredential = Get-Credential -Message "Enter Cluster login credentials \n(password needs to be longer than 6 chars and have a number + symbol)" -UserName "sshuser"
# SSH user is used to remotely connect to the cluster using SSH clients
$sshCredentials = Get-Credential -Message "Enter SSH user credentials \n(password needs to be longer than 6 chars and have a number + symbol)" -UserName "sshuser"

# Default cluster size (# of worker nodes), version, type, and OS
$clusterSizeInNodes = "4"
$clusterVersion = "3.5"
$clusterType = "Hadoop"
$clusterOS = "Linux"
$clusterName = "tpch" + $random + "benchmark"

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
    -HttpCredential $httpCredential `
    -DefaultStorageAccountName "$defaultStorageAccountName.blob.core.windows.net" `
    -DefaultStorageAccountKey $defaultStorageAccountKey `
    -DefaultStorageContainer $clusterName `
    -SshCredential $sshCredentials


Remove-AzureRmResourceGroup -Name $resourceGroupName