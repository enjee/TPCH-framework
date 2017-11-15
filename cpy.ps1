
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
$random = "aae5mpuk8h9xyzd2t"
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
$username = "x2n5jm74lz"
$password = "1Password!"
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

# Files
$Path = ((Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) + "\")
$PythonFileName = "hdinsight_benchmark.py"
$SftpPath = ('/home/' + $username + '/')
$PythonFile = ($SftpPath + 'TPCH-framework/scripts/' + $PythonFileName)
$PythonCommand = ('sudo chmod +x ' + $PythonFile + ' && python ' + $PythonFile + ' ' + $random)

$WorkerCount = 2
$WorkerNodeType = 'Standard_A3'
$HeadNodeType = 'Standard_A3'
$Repeat = 1
$Size = 1

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

Write-Output ("Runnning the Python benchmark")
$PythonCommand = ($PythonCommand + ' ' + $Size + ' ' + $Repeat + ' ' + $WorkerCount + ' ' + $WorkerNodeType + ' ' + $HeadNodeType)
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCommand

Remove-SFTPSession -SessionId 0
Remove-SSHSession -SessionId 0

Write-Output ("Finished executing all scripts through ssh")
Write-Output "$(Get-Date)"
Write-Output ("Removing all earlier created resources from your Azure account")

#Remove-AzureRmResourceGroup -Name $resourceGroupName -Force

Write-Output "$(Get-Date)"


read-Host -Prompt "Press Enter to exit"