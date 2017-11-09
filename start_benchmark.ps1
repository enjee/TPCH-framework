
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
# ALL CONSTANTS & VARIABLES  #
##############################

# Randomize this run
$random = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})
Write-Output ("This script execution has been randomized with: " + $random)

# Default cluster size (# of worker nodes), version, type, and OS
$clusterVersion = "3.5"
$clusterType = "Hadoop"
$clusterOS = "Linux"
$clusterName = ($random + "cluster")
$ComputerName = ($clusterName + "-ssh.azurehdinsight.net")
$resourceGroupName = ($random + "group")
$location = "westeurope"
$defaultStorageAccountName = ($random + "storage")


# Credentials
$username = -join ((48..57) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$password = "1Password!"
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

# Files
$Path = ((Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) + "\")
$FilePath = "scripts/hdinsight_benchmark.py"
$FileName = "hdinsight_benchmark.py"
$SftpPath = ('/home/' + $username + '/')
$File = ($SftpPath + $FileName)
$command = ('chmod +x ' + $File + ' && python ' + $File + ' ' + $random)
$RemoveCommand = ('rm ' + $File)

$AcceptedNodeTypes = "D3", "D5"



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
# GUI                        #
##############################

Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Form"
$Form.BackColor = "#34bce5"
$Form.TopMost = $true
$Form.Width = 477
$Form.Height = 421

$start = New-Object system.windows.Forms.Button
$start.BackColor = "#23f71b"
$start.Text = "Start Benchmark"
$start.Width = 141
$start.Height = 29
$start.location = new-object system.drawing.point(156,323)
$start.Font = "Microsoft Sans Serif,10,style=Bold"
$Form.controls.Add($start)

$label3 = New-Object system.windows.Forms.Label
$label3.Text = "Worker Nodes"
$label3.AutoSize = $true
$label3.Width = 25
$label3.Height = 10
$label3.location = new-object system.drawing.point(9,17)
$label3.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label3)

$worker_nodes = New-Object system.windows.Forms.ListBox
$worker_nodes.Text = "Standard_D3_v2"
$worker_nodes.Width = 150
$worker_nodes.Height = 100
$worker_nodes.location = new-object system.drawing.point(150,10)
for ($i = 0; $i -lt $PossibleNodes.Count ; $i++) {
    $AddName = $PossibleNodes[$i].name
    for ($j = 0; $j -lt $AcceptedNodeTypes.Count ; $j++) {
        if ($AddName -match $AcceptedNodeTypes[$j]) {
            [void] $worker_nodes.Items.Add($AddName)
            break
        }
    }
}
$Form.controls.Add($worker_nodes)

$label5 = New-Object system.windows.Forms.Label
$label5.Text = "Select head nodes"
$label5.AutoSize = $true
$label5.Width = 25
$label5.Height = 10
$label5.location = new-object system.drawing.point(11,136)
$label5.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label5)

$head_nodes = New-Object system.windows.Forms.ListBox
$head_nodes.Text = "Standard_D3_v2"
$head_nodes.Width = 150
$head_nodes.Height = 100
$head_nodes.location = new-object system.drawing.point(150,120)
for ($i = 0; $i -lt $PossibleNodes.Count ; $i++) {
    $AddName = $PossibleNodes[$i].name
     for ($j = 0; $j -lt $AcceptedNodeTypes.Count ; $j++) {
            if ($AddName -match $AcceptedNodeTypes[$j]) {
                [void] $head_nodes.Items.Add($AddName)
                break
            }
        }
}
$Form.controls.Add($head_nodes)

$worker_count = New-Object system.windows.Forms.ListBox
$worker_count.Text = "4"
$worker_count.Width = 120
$worker_count.Height = 30
$worker_count.location = new-object system.drawing.point(150,250)
for ($i = 0; $i -le 3 ; $i++) {
    $AddCount = 2,4,8,16
    [void] $worker_count.Items.Add($AddCount[$i])
}
$Form.controls.Add($worker_count)

$label8 = New-Object system.windows.Forms.Label
$label8.Text = "Nr. of worker nodes"
$label8.AutoSize = $true
$label8.Width = 25
$label8.Height = 10
$label8.location = new-object system.drawing.point(8,259)
$label8.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label8)


$start.Add_Click({
    $form.Close()
})
[void]$Form.ShowDialog()
$Form.Dispose()

$WorkerCount = $worker_count.Text
$WorkerNodeType = $worker_nodes.Text
$HeadNodeType = $head_nodes.Text




##############################
# Azure PowerShell creation  #
##############################

# Create the resource group
Write-Output ("Creating the resource group " + $resourceGroupName + " on your account")
if (!(Get-AzureRmResourceGroup -Name $resourceGroupName -EA 0)) {
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}

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

Write-Output ("Pushing " + $Path + $FilePath + " onto the cluster, at " + $File)
Invoke-SSHCommand -SSHSession $ssh -Command $RemoveCommand
Set-SFTPFile -SessionId 0 -LocalFile ($Path + $FilePath) -RemotePath $SftpPath

Write-Output ("Invoking script " + $File + " on your HDInsight cluster")
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install requests'
Invoke-SSHCommand -SSHSession $ssh -Command $command

Remove-SFTPSession -SessionId 0
Remove-SSHSession -SessionId 0

Write-Output ("Finished executing all scripts through ssh")
Write-Output "$(Get-Date)"
Write-Output ("Removing all earlier created resources from your Azure account")

Remove-AzureRmResourceGroup -Name $resourceGroupName -Force

Write-Output "$(Get-Date)"


read-Host -Prompt "Press Enter to exit"