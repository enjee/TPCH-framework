
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
   $Host.UI.RawUI.ForegroundColor = "white"
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
$random = "a" + $random
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
$PythonFileName = "hdinsight_benchmark.py"
$SftpPath = ('/home/' + $username + '/')
$PythonFile = ($SftpPath + 'TPCH-framework/scripts/' + $PythonFileName)
$PythonCHmodCommand = ('sudo chmod +x ' + $PythonFile)
$PythonCommand = ('python ' + $PythonFile + ' ' + $random)

# Test variables
$AllowedTestSizes = 1, 5, 10
$MaxRepeatTest = 10
$AcceptedNodeTypes = "Standard_A3", "Standard_A4", "Standard_A5", "Standard_D1", "Standard_D2", "Standard_D3", "Standard_D4", "Standard_D5"



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
$Form.Text = "TPCH Benchmark on Azure"
$Form.BackColor = "#34bce5"
$Form.TopMost = $true
$Form.Width = 500
$Form.Height = 600
$Form.StartPosition = "CenterScreen"

$start = New-Object system.windows.Forms.Button
$start.BackColor = "#23f71b"
$start.Text = "Start Benchmark"
$start.Width = 141
$start.Height = 29
$start.location = new-object system.drawing.point(156,520)
$start.Font = "Microsoft Sans Serif,10,style=Bold"
$Form.controls.Add($start)

$worker_nodes_label = New-Object system.windows.Forms.Label
$worker_nodes_label.Text = "Worker Nodes"
$worker_nodes_label.AutoSize = $true
$worker_nodes_label.Width = 25
$worker_nodes_label.Height = 10
$worker_nodes_label.location = new-object system.drawing.point(9,17)
$worker_nodes_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($worker_nodes_label)

$worker_nodes = New-Object system.windows.Forms.ListBox
$worker_nodes.Width = 150
$worker_nodes.Height = 100
$worker_nodes.location = new-object system.drawing.point(150,10)
for ($i = 0; $i -lt $PossibleNodes.Count ; $i++) {
    $AddName = $PossibleNodes[$i].name
    if ($AcceptedNodeTypes -contains $AddName) {
        [void] $worker_nodes.Items.Add($AddName)
    }
}
$worker_nodes.SetSelected(0, $true)
$Form.controls.Add($worker_nodes)

$head_nodes_label = New-Object system.windows.Forms.Label
$head_nodes_label.Text = "Select head nodes"
$head_nodes_label.AutoSize = $true
$head_nodes_label.Width = 25
$head_nodes_label.Height = 10
$head_nodes_label.location = new-object system.drawing.point(11,136)
$head_nodes_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($head_nodes_label)

$head_nodes = New-Object system.windows.Forms.ListBox
$head_nodes.Width = 150
$head_nodes.Height = 100
$head_nodes.location = new-object system.drawing.point(150,120)
for ($i = 0; $i -lt $PossibleNodes.Count ; $i++) {
    $AddName = $PossibleNodes[$i].name
    if ($AcceptedNodeTypes -contains $AddName) {
         [void] $head_nodes.Items.Add($AddName)
    }
}
$head_nodes.SetSelected(0, $true)
$Form.controls.Add($head_nodes)

$worker_count = New-Object system.windows.Forms.ListBox
$worker_count.Width = 120
$worker_count.Height = 60
$worker_count.location = new-object system.drawing.point(150,250)
for ($i = 0; $i -le 3 ; $i++) {
    $AddCount = 2,4,8,16
    [void] $worker_count.Items.Add($AddCount[$i])
}
$worker_count.SetSelected(0, $true)
$Form.controls.Add($worker_count)

$worker_count_label = New-Object system.windows.Forms.Label
$worker_count_label.Text = "Nr. of worker nodes"
$worker_count_label.AutoSize = $true
$worker_count_label.Width = 25
$worker_count_label.Height = 10
$worker_count_label.location = new-object system.drawing.point(8,250)
$worker_count_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($worker_count_label)


$repeat_test_count = New-Object system.windows.Forms.ListBox
$repeat_test_count.Width = 120
$repeat_test_count.Height = 60
$repeat_test_count.location = new-object system.drawing.point(150,320)
for ($i = 0; $i -lt $MaxRepeatTest ; $i++) {
    $AddCount = 1..$MaxRepeatTest
    [void] $repeat_test_count.Items.Add($AddCount[$i])
}
$repeat_test_count.SetSelected(0, $true)
$Form.controls.Add($repeat_test_count)

$repeat_test_count_label = New-Object system.windows.Forms.Label
$repeat_test_count_label.Text = "Repeat test N times"
$repeat_test_count_label.AutoSize = $true
$repeat_test_count_label.Width = 25
$repeat_test_count_label.Height = 10
$repeat_test_count_label.location = new-object system.drawing.point(8,320)
$repeat_test_count_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($repeat_test_count_label)

$test_size = New-Object system.windows.Forms.ListBox
$test_size.Width = 120
$test_size.Height = 60
$test_size.location = new-object system.drawing.point(150,390)
for ($i = 0; $i -lt $AllowedTestSizes.Count ; $i++) {
    $AddCount = $AllowedTestSizes
    [void] $test_size.Items.Add($AddCount[$i])
}
$test_size.SetSelected(0, $true)
$Form.controls.Add($test_size)

$test_size_label = New-Object system.windows.Forms.Label
$test_size_label.Text = "Test size in Giga Bytes"
$test_size_label.AutoSize = $true
$test_size_label.Width = 25
$test_size_label.Height = 10
$test_size_label.location = new-object system.drawing.point(8,390)
$test_size_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($test_size_label)


$start.Add_Click({
    $form.Close()
})
[void]$Form.ShowDialog()
$Form.Dispose()

$WorkerCount = $worker_count.Text
$WorkerNodeType = $worker_nodes.Text
$HeadNodeType = $head_nodes.Text
$Repeat = $repeat_test_count.Text
$Size = $test_size.Text

Write-Output $Size


Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "TPCH Benchmark on Azure"
$Form.BackColor = "#34bce5"
$Form.TopMost = $true
$Form.Width = 800
$Form.Height = 300
$Form.StartPosition = "CenterScreen"

$start = New-Object system.windows.Forms.Button
$start.BackColor = "#23f71b"
$start.Text = "Accept and Start"
$start.Width = 141
$start.Height = 29
$start.location = new-object system.drawing.point(300,220)
$start.Font = "Microsoft Sans Serif,10,style=Bold"
$Form.controls.Add($start)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "You are starting the benchmark with these parameters:"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,20)
$header_lbl.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Head node type: " + $HeadNodeType
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,60)
$header_lbl.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Worker node type: " + $WorkerNodeType
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,80)
$header_lbl.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Worker count: " + $WorkerCount
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,100)
$header_lbl.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Number of times to repeat the test: " + $Repeat
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,120)
$header_lbl.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Testset size: " + $Size + "GB"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,140)
$header_lbl.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "At the end of this script, the resources will be removed. Please check if this succeeded to prevent unexpected costs."
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,180)
$header_lbl.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($header_lbl)

$start.Add_Click({
    $form.Close()
})
[void]$Form.ShowDialog()
$Form.Dispose()



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

Write-Output ("Invoking scripts")
Invoke-SSHCommand -SSHSession $ssh -Command 'export DEBIAN_FRONTEND=noninteractive'
Write-Output ("Installing Python modules")
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install requests'
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install natsort'

Write-Output ("Installing Microsoft .NET core")
Invoke-SSHCommand -SSHSession $ssh -Command 'curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg'
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg'
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo sh -c ''echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list'''
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo apt-get update'
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo apt-get -y install dotnet-sdk-2.0.2' -timeout 600
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo apt-get -y install dotnet-dev-1.1.4' -timeout 600

Write-Output ("Installing AZCopy")
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo wget -O azcopy.tar.gz https://aka.ms/downloadazcopyprlinux'
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo tar -xf azcopy.tar.gz'
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo ./install.sh'

Write-Output ("Cloning GIT repo")
Invoke-SSHCommand -SSHSession $ssh -Command 'git clone https://github.com/enjee/TPCH-framework'

Write-Output ("Copy required datasets from central datastore")
$SourceUrl = ('https://benchmarkdatasaxion.blob.core.windows.net/' + $Size + 'gb')
$AzCopyCommand = ('azcopy --source-key vKqcXAZEI5TjwfBYBjx9BCWzkzmf8hG4t4O3O0h7RQXPcUL6FVSrMamXq+2cS7Qe7h/oVJbv7sboi9JsKQbKJw== --source ' + $SourceUrl + ' --destination ~/dataset --recursive')
Invoke-SSHCommand -SSHSession $ssh -Command $AzCopyCommand

Write-Output ("Running the Python benchmark")
$PythonCommand = ($PythonCommand + ' ' + $Size + ' ' + $Repeat + ' ' + $WorkerCount + ' ' + $WorkerNodeType + ' ' + $HeadNodeType)
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCHmodCommand -timeout 999999
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCommand -timeout 999999

Remove-SFTPSession -SessionId 0
Remove-SSHSession -SessionId 0

Write-Output ("Finished executing all scripts through ssh")
Write-Output "$(Get-Date)"
Write-Output ("Removing all earlier created resources from your Azure account")

Remove-AzureRmResourceGroup -Name $resourceGroupName -Force

Write-Output "$(Get-Date)"


Write-Host "Press any key to exit ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")