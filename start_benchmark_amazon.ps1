
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


$access_key = "XXXX"
$secret_key = "XXXX"
Set-AWSCredential -AccessKey $access_key -SecretKey $secret_key -StoreAs AwsProfile
Initialize-AWSDefaults -ProfileName AwsProfile -Region eu-central-1


Write-Output ("Creating the EMR cluster on your account")
Start-EMRJobFlow -Name "new_cluster" `
                  -Instances_MasterInstanceType "m4.large" `
                  -Instances_SlaveInstanceType "m4.large" `
                  -Instances_KeepJobFlowAliveWhenNoSteps $true `
                  -Instances_InstanceCount 2 `
                  -Instances_Ec2SubnetId "subnet-af4fbcd2" `
                  -ReleaseLabel "emr-5.10.0" `
                  -JobFlowRole "EMR_EC2_DefaultRole" `
                  -ServiceRole "EMR_DefaultRole" `
                  -VisibleToAllUsers $true                 
