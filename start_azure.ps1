##############################
# Get arguments              #
##############################
$Size = $args[0]
$Repeat = $args[1]
$WorkerCount = $args[2]
$WorkerNodeType = $args[3]
$HeadNodeType = $args[4]
$Tag = $args[5]

##############################
# ALL CONSTANTS & VARIABLES  #
##############################

# Randomize this run
$random = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})
$random = "a" + $random
Write-Output ("This script execution has been randomized with: " + $random)

# Default cluster size (# of worker nodes), version, type, and OS
$clusterVersion = "3.5"
$clusterType = "Hadoop"
$clusterOS = "Linux"
$clusterName = ($random + "cluster")
$ComputerName = ($clusterName + "-ssh.azurehdinsight.net")
$resourceGroupName = ($random + "group")
$location = "northeurope"
$defaultStorageAccountName = ($random + "storage")


# Credentials
$username = -join ((48..57) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$password = "1Password!"
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

# Files
$Path = ((Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) + "\")
$PythonFileName = "hdinsight_benchmark.py"
$SftpPath = ('/home/' + $username + '/')
$PythonFile = ($SftpPath + 'TPCH-framework/scripts/' + $PythonFileName)
$PythonCHmodCommand = ('sudo chmod +x ' + $PythonFile)
$PythonCommand = ('python ' + $PythonFile + ' ' + $random)

# Test variables
$AllowedTestSizes = 1, 5, 10, 100
$MaxRepeatTest = 10
$AcceptedNodeTypes = "Standard_A3", "Standard_A4", "Standard_A5", "Standard_D3", "Standard_D4", "Standard_D5"
$Tag = "no-tag"



##########################################
# Check and install required libraries   #
##########################################

# Install PowerShell for Azure if not exists
Write-Output "$(Get-Date)"

Write-Output "Checking for Azure PowerShell"
if (!(Get-Module -ListAvailable -Name AzureRM)) {
    Install-Module AzureRM -Force
    Import-Module AzureRM
    Write-Output "Azure Powershell installed"
} else {
    Write-Output "Azure PowerShell already present"
}

# Install ssh for powershell if not exists
Write-Output "Checking for Posh-SSH"
if (!(Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module Posh-SSH -Force
    Import-Module Posh-SSH
} else {
    Write-Output "Posh-SSH is already present"
}


##############################
# Azure PowerShell  login    #
##############################

# Login to your Azure subscription
Write-Output "Logging in to your Azure subscription"
$sub = Add-AzureRmAccount

$PossibleNodes = Get-AzureRmVMSize -location 'westeurope'

##############################
# Azure PowerShell creation  #
##############################

# Create the resource group
$start = Get-Date -format HH:mm:ss

$start_minute = (Get-Date).Minute;
$start_minute = $start_minute/1;

Write-Output ("Creating the resource group " + $resourceGroupName + " on your account")
if (!(Get-AzureRmResourceGroup -Name $resourceGroupName -EA 0)) {
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}
$start_date = (Get-Date).Hour;
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
Write-Output ("Please be patient, this could take more than 10 minutes.")
New-AzureRmHDInsightCluster `
    -ResourceGroupName $resourceGroupName `
    -ClusterName $clusterName `
    -WorkerNodeSize $WorkerNodeType `
    -HeadNodeSize $HeadNodeType `
    -Location $location `
    -ClusterSizeInNodes $WorkerCount `
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

New-SFTPSession -ComputerName $ComputerName -Credential $credentials -AcceptKey:$true
$ssh = New-SSHSession -ComputerName $ComputerName -Credential $credentials -AcceptKey:$true

Write-Output ("Invoking scripts")
Invoke-SSHCommand -SSHSession $ssh -Command 'export DEBIAN_FRONTEND=noninteractive'
Write-Output ("Installing Python modules")
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install requests'
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install natsort'

Write-Output ("Cloning GIT repo")
Invoke-SSHCommand -SSHSession $ssh -Command 'git clone -b development https://github.com/enjee/TPCH-framework'

Write-Output ("Running the Python benchmark")
$PythonCommand = ($PythonCommand + ' ' + $Size + ' ' + $Repeat + ' ' + $WorkerCount + ' ' + $WorkerNodeType + ' ' + $HeadNodeType + ' ' + $Tag + "Azure")
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCHmodCommand -timeout 999999
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCommand -timeout 999999

Remove-SFTPSession -SessionId 0
Remove-SSHSession -SessionId 0

Write-Output ("Finished executing all scripts through ssh")
Write-Output "$(Get-Date)"
Write-Output ("Removing all earlier created resources from your Azure account")

Remove-AzureRmResourceGroup -Name $resourceGroupName -Force

############################################
# CALCULATE AMOUNT OF BILLED HOURS         #
############################################

$end = Get-Date -format HH:mm:ss

$TimeDiff = New-TimeSpan $start $end

$hours = $TimeDiff.totalHours;

##############################################
# CALCULATE COST OF THIS BENCHMARK           #
##############################################

switch($HeadNodeType) {
	"Standard_A3" {$HeadNodeCost = (( 2 * 0.27) * $hours) }
	"Standard_A4" {$HeadNodeCost = (( 2 * 0.54) * $hours) }
	"Standard_A5" {$HeadNodeCost = (( 2 * 0.296) * $hours) }
	"Standard_D3" {$HeadNodeCost = (( 2 * 0.525) * $hours) }
	"Standard_D4" {$HeadNodeCost = (( 2 * 1.049) * $hours) }
	"Standard_D5" {$HeadNodeCost = (( 2 * 2.097) * $hours) }
}

switch($WorkerNodeType) {
	"Standard_A3" {$WorkerNodeCost = (( $WorkerCount * 0.27) * $hours) }
	"Standard_A4" {$WorkerNodeCost = (( $WorkerCount * 0.54) * $hours) }
	"Standard_A5" {$WorkerNodeCost = (( $WorkerCount * 0.296) * $hours) }
	"Standard_D3" {$WorkerNodeCost = (( $WorkerCount * 0.525) * $hours) }
	"Standard_D4" {$WorkerNodeCost = (( $WorkerCount * 1.049) * $hours) }
	"Standard_D5" {$WorkerNodeCost = (( $WorkerCount * 2.097) * $hours) }
}

$cost = $HeadNodeCost + $WorkerNodeCost;

Invoke-RestMethod -Uri http://13.79.186.204/api/pricing/$random/$cost


Write-Output "$(Get-Date)"

Write-Output ("Find your benchmark at: http://tpch.ga/detailed/" + $random)
Write-Host "Press any key to exit ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")