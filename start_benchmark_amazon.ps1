
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


Write-Output "Checking for AWS PowerShell"
if (!(Get-Module -ListAvailable -Name AWSPowerShell)) {
    Install-Module -Name AWSPowerShell
    Import-Module AWSPowerShell
    Write-Output "AWS Powershell installed"
} else {
    Write-Output "AWS PowerShell already installed"
}

# Install ssh for powershell if not exists
Write-Output "Checking for Posh-SSH"
if (!(Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module Posh-SSH -Force
    Import-Module Posh-SSH
} else {
    Write-Output "Posh-SSH is already present"
}

# Keys
$access_key = "XXXX"
$secret_key = "XXXX"
Set-AWSCredential -AccessKey $access_key -SecretKey $secret_key -StoreAs AwsProfile
Initialize-AWSDefaults -ProfileName AwsProfile -Region eu-central-1

# Files
$Path = ((Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) + "\")
$PythonFileName = "hdinsight_benchmark.py"
$SftpPath = ('/home/' + $username + '/')
$PythonFile = ($SftpPath + 'TPCH-framework/scripts/' + $PythonFileName)
$PythonCHmodCommand = ('sudo chmod +x ' + $PythonFile)
$PythonCommand = ('python ' + $PythonFile + ' ' + $random)

# Create random cluster name
$random = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})
$random = "aws" + $random
Write-Output ("Random cluster name is: " + $random)

$hive = new-object Amazon.ElasticMapReduce.Model.Application
$hive.Name = "Hive"
$filename = $random + ".pem"
$myPSKeyPair = New-EC2KeyPair -KeyName $random
$myPSKeyPair.KeyMaterial | Out-File -Encoding ascii $filename

# Enable ssh access
$groupid = New-EC2SecurityGroup -GroupName $random -GroupDescription "EC2-Classic from PowerShell"
$ip1 = new-object Amazon.EC2.Model.IpPermission 
$ip1.IpProtocol = "tcp" 
$ip1.FromPort = 22 
$ip1.ToPort = 22 
$ip1.IpRanges.Add("203.0.113.25/32") 

$ip2 = new-object Amazon.EC2.Model.IpPermission 
$ip2.IpProtocol = "tcp" 
$ip2.FromPort = 3389 
$ip2.ToPort = 3389 
$ip2.IpRanges.Add("203.0.113.25/32") 

Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermissions @( $ip1, $ip2 )	


Write-Output ("Creating the EMR cluster on your account")
$job_id = Start-EMRJobFlow -Name $random `
                  -Instances_MasterInstanceType "m4.large" `
                  -Instances_SlaveInstanceType "m4.large" `
                  -Instances_KeepJobFlowAliveWhenNoStep $true `
                  -Instances_InstanceCount 2 `
                  -Instances_Ec2SubnetId "subnet-af4fbcd2" `
                  -Instances_Ec2KeyName $random `
                  -Application $hive `
                  -ReleaseLabel "emr-5.10.0" `
                  -JobFlowRole "EMR_EC2_DefaultRole" `
                  -ServiceRole "EMR_DefaultRole" `
                  -VisibleToAllUsers $true `
				          -Instances_AdditionalMasterSecurityGroup $groupid


Write-Output ("Cluster with id " + $job_id + " is being created")

# Wait until cluster is created
do {
    Start-Sleep 10
    $waitingiswaiting = Get-EMRClusterList -ClusterState "STARTING"
    $waitcnt = $waitcnt + 10
    Write-Output("Starting..." + $waitcnt)
}while($waitingiswaiting.Count -eq 1)


# Get cluster information
$cluster = Get-EMRCluster -ClusterId $job_id

##############################
# SSH INTO SERVER            #
##############################
$ComputerName = $cluster.MasterPublicDnsName
$UserName = "hadoop"
$KeyFile = ".\" + $filename
$nopasswd = new-object System.Security.SecureString
$Crendtial = New-Object System.Management.Automation.PSCredential ($UserName, $nopasswd)

Write-Output("Using keyfile to start ssh session")
$ssh = New-SSHSession -ComputerName $ComputerName -Credential $Crendtial -KeyFile $KeyFile -AcceptKey:$true

Write-Output ("Invoking scripts")
Invoke-SSHCommand -SSHSession $ssh -Command 'export DEBIAN_FRONTEND=noninteractive'

Write-Output ("Installing Python modules")
Invoke-SSHCommand -SSHSession $ssh -Command 'yes | sudo yum install git'
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install requests'
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install natsort'

Write-Output ("Cloning GIT repo")
Invoke-SSHCommand -SSHSession $ssh -Command 'git clone -b development https://github.com/enjee/TPCH-framework'

Write-Output ("Running the Python benchmark")
#$PythonCommand = ($PythonCommand + ' ' + $Size + ' ' + $Repeat + ' ' + $WorkerCount + ' ' + $WorkerNodeType + ' ' + $HeadNodeType + ' ' + $Tag)
$PythonCommand = ($PythonCommand + ' ' + 1 + ' ' + 1 + ' ' + 1 + ' ' + 1 + ' ' + 1 + ' ' + "asad")
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCHmodCommand -timeout 999999
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCommand -timeout 999999

Remove-SSHSession -SessionId 0


Remove-EC2KeyPair -KeyName $random
Stop-EMRJobFlow-JobFlowId $job_id

