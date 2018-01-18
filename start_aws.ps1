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
# Install needed modules     #
##############################
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

##############################
# Login GUI                  #
##############################
Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Authenticate for Amazon"
$Form.TopMost = $true
$Form.Width = 500
$Form.Height = 300
$Form.StartPosition = "CenterScreen"

$error_label = New-Object system.windows.Forms.ErrorProvider

$access_key_label = New-Object system.windows.Forms.Label
$access_key_label.Text = "Access key: "
$access_key_label.AutoSize = $true
$access_key_label.Width = 25
$access_key_label.Height = 10
$access_key_label.location = new-object system.drawing.point(130,100)
$access_key_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($access_key_label)

$access = New-Object system.windows.Forms.TextBox
$access.Width = 150
$access.Height = 20
$access.location = new-object system.drawing.point(260,100)
$access.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($access)

$secret_key_label = New-Object system.windows.Forms.Label
$secret_key_label.Text = "Secret key: "
$secret_key_label.AutoSize = $true
$secret_key_label.Width = 25
$secret_key_label.Height = 10
$secret_key_label.location = new-object system.drawing.point(130,150)
$secret_key_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($secret_key_label)

$secret = New-Object Windows.Forms.MaskedTextBox
$secret.Width = 150
$secret.Height = 20
$secret.PasswordChar = '*'
$secret.location = new-object system.drawing.point(260,150)
$secret.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($secret)

$start = New-Object system.windows.Forms.Button
$start.Text = "Authenticate"
$start.Width = 141
$start.Height = 29
$start.location = new-object system.drawing.point(200,200)
$Form.controls.Add($start)

$start.Add_Click({
  $access_key = $access.Text
  $secret_key_secure =  $secret.Text | ConvertTo-SecureString -AsPlainText -Force
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret_key_secure)
  $secret_key = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  Set-AWSCredential -AccessKey $access_key -SecretKey $secret_key -StoreAs AwsProfile
  Initialize-AWSDefaults -ProfileName AwsProfile -Region eu-central-1
  $global:authorization = Get-IAMAccountAuthorizationDetail
  
  
  if(-not $global:authorization.HttpStatusCode -eq "OK")
  {
    $error_label.SetError($this, "Invalid access or secret key");
  }else{
    $form.Close()
  }

    
})
[System.Windows.Forms.Application]::EnableVisualStyles();
[void]$Form.ShowDialog()
$Form.Dispose()


if(-not $global:authorization.HttpStatusCode -eq "OK")
  {
    Write-Host "Can not execute script, wrong access/secret key. Press any key to exit ..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit

  }

##############################
# ALL CONSTANTS & VARIABLES  #
##############################

# Create random cluster name
$random = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})
$random = "aws" + $random
Write-Output ("Random cluster name is: " + $random)

# Files
$Path = ((Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) + "\")
$PythonFileName = "hdinsight_benchmark.py"
$PythonFile = ('TPCH-framework/scripts/' + $PythonFileName)
$PythonCHmodCommand = ('sudo chmod +x ' + $PythonFile)
$PythonCommand = ('python ' + $PythonFile + ' ' + $random)

#start time for calculating cost
$start = Get-Date -format HH:mm:ss

###################################
# Enable ssh access and make Hive #
###################################
$hive = new-object Amazon.ElasticMapReduce.Model.Application
$hive.Name = "Hive"
$filename = $random + ".pem"
$myPSKeyPair = New-EC2KeyPair -KeyName $random
$myPSKeyPair.KeyMaterial | Out-File -Encoding ascii $filename

$groupid = New-EC2SecurityGroup -GroupName $random -GroupDescription "EC2-Classic from PowerShell"
$ip1 = new-object Amazon.EC2.Model.IpPermission 
$ip1.IpProtocol = "tcp" 
$ip1.FromPort = 22 
$ip1.ToPort = 22 
$ip1.IpRanges.Add("0.0.0.0/0")

$ip2 = new-object Amazon.EC2.Model.IpPermission 
$ip2.IpProtocol = "tcp" 
$ip2.FromPort = 3389 
$ip2.ToPort = 3389 
$ip2.IpRanges.Add("0.0.0.0/0") 

Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermissions @( $ip1, $ip2 )	

##############################
# Get subnet                 #
##############################
$vpc_filter = new-object Amazon.EC2.Model.Filter
$vpc_filter.name = "isDefault"
$vpc_filter.values = "true"
$vpc = Get-EC2Vpc -Filter $vpc_filter
$subnet_filter_zone =  new-object Amazon.EC2.Model.Filter
$subnet_filter_zone.name = "availabilityZone"
$subnet_filter_zone.values = "eu-central-1b"
$subnet_filter_vpc =  new-object Amazon.EC2.Model.Filter
$subnet_filter_vpc.name = "vpc-id"
$subnet_filter_vpc.values = $vpc.VpcId
$subnet = Get-EC2Subnet -Filter $subnet_filter_zone, $subnet_filter_vpc

##############################################
# removing previous & creating new IAM role  #
##############################################

$jfrole = 'EMR_EC2_DefaultRole'
$srole = 'EMR_DefaultRole'

Get-IAMInstanceProfileForRole -RoleName $jfrole | Remove-IAMRoleFromInstanceProfile -RoleName $jfrole | Remove-IAMInstanceProfile
Get-IAMAttachedRolePolicies -RoleName $jfrole | Unregister-IAMRolePolicy -RoleName $jfrole
Remove-IAMRole -RoleName $jfrole -force
#$accid = Get-IAMAccountAlias

Get-IAMInstanceProfileForRole -RoleName $srole | Remove-IAMRoleFromInstanceProfile -RoleName $srole | Remove-IAMInstanceProfile
Get-IAMAttachedRolePolicies -RoleName $srole | Unregister-IAMRolePolicy -RoleName $srole
Remove-IAMRole -RoleName $srole -force

$EMRpolicyFilePath = $PSScriptRoot + '\policies\emrpolicy.json'
$EC2policyFilePath = $PSScriptRoot + '\policies\ec2policy.json'
$iamrole = New-IAMRole -RoleName $jfrole -AssumeRolePolicyDocument (Get-Content -raw $EC2policyFilePath)
Write-Output ($policyFilePath)
$iamrole = New-IAMRole -RoleName $srole -AssumeRolePolicyDocument (Get-Content -raw $EMRpolicyFilePath)
Register-IAMRolePolicy -RoleName $jfrole -PolicyArn "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
Register-IAMRolePolicy -RoleName $jfrole -PolicyArn "arn:aws:iam::aws:policy/AmazonS3FullAccess"
Register-IAMRolePolicy -RoleName $srole -PolicyArn "arn:aws:iam::aws:policy/AmazonS3FullAccess"
Register-IAMRolePolicy -RoleName $srole -PolicyArn "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
#Start-Sleep 1000

		$instanceprofilename = "EMR_EC2_DefaultRole"
		$accid = @(get-ec2securitygroup -GroupNames "default")[0].OwnerId
		$path = "arn:aws:iam::" + $accid + ":instance-profile/EMR_EC2_DefaultRole"
		New-IAMInstanceProfile -InstanceProfileName $instanceprofilename -Path "/"
		Add-IAMRoleToInstanceProfile -InstanceProfileName $instanceprofilename -RoleName $srole

		
				$configuration = '[{"classification":"core-site", "properties":{"AWS_ACCESS_KEY_ID":"' + access_key + '", "AWS_SECRET_ACCESS_KEY":"'+$secret_key+'"}, "configurations":[{"classification":"export", "properties":{"AWS_ACCESS_KEY_ID":"' + access_key + '", "AWS_SECRET_ACCESS_KEY":"'+$secret_key+'"}, "configurations":[]}]}]'

##############################
# Create EMR cluster         #
##############################
Write-Output ("Creating the EMR cluster on your account")
$job_id = Start-EMRJobFlow -Name $random `
                  -Instances_MasterInstanceType $HeadNodeType `
                  -Instances_SlaveInstanceType $WorkerNodeType `
                  -Instances_KeepJobFlowAliveWhenNoStep $true `
                  -Instances_InstanceCount $WorkerCount `
                  -Instances_Ec2SubnetId $subnet.SubnetId[1] `
                  -Instances_Ec2KeyName $random `
                  -Application $hive `
                  -ReleaseLabel "emr-5.11.0" `
                  -JobFlowRole $jfrole `
				  -ServiceRole $srole `
				  -configuration $configuration `

                  -VisibleToAllUsers $true `
				          -Instances_AdditionalMasterSecurityGroup $groupid


Write-Output ("Cluster with id " + $job_id + " is being created")

# Wait until cluster is created
do {
    Start-Sleep 10
    $state = Get-EMRCluster -ClusterId $job_id
    $waitcnt = $waitcnt + 10
    Write-Output("Starting..." + $waitcnt)
}while($state.Status.State -eq "STARTING")


# Get cluster information
$cluster = Get-EMRCluster -ClusterId $job_id

$waitcnt = 0

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

#Invoke-SSHCommand -SSHSession $ssh -Command 'export AWS_ACCESS_KEY_ID=' + $access_key
#Invoke-SSHCommand -SSHSession $ssh -Command 'export AWS_SECRET_ACCESS_KEY=' +$secret_key
Write-Output ("Installing Python modules")
Invoke-SSHCommand -SSHSession $ssh -Command 'yes | sudo yum install git'
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install requests'
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo pip install natsort'

Write-Output ("Cloning GIT repo")
Invoke-SSHCommand -SSHSession $ssh -Command 'git clone -b development https://github.com/enjee/TPCH-framework'

$endBeforeScript = Get-Date -format HH:mm:ss
$startupTime = New-TimeSpan $start $endBeforeScript
$startupMinutes = $startupTime.totalMinutes;

Write-Output ("Running the Python benchmark")
$PythonCommand = ($PythonCommand + ' ' + $Size + ' ' + $Repeat + ' ' + $WorkerCount + ' ' + $WorkerNodeType + ' ' + $HeadNodeType + ' ' + $Tag + " Amazon")
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCHmodCommand -timeout 999999
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCommand -timeout 999999

Remove-SSHSession -SessionId 0

#Stop-EMRJobFlow -JobFlowId $job_id -Force

# Wait until cluster is terminated
do {
    Start-Sleep 10
    $state = Get-EMRCluster -ClusterId $job_id
    $waitcnt = $waitcnt + 10
    Write-Output("Terminating cluster..." + $waitcnt)
}while($state.Status.State -eq "TERMINATING")


do{
Start-Sleep 10
    $ec2insances = Get-EMRInstances -ClusterId $job_id -InstanceState "RUNNING"
    $waitcount = $waitcount + 10
    Write-Output("Terminating ec2 instance..." + $waitcount)
}while($ec2instances.Count -gt 0)
Start-Sleep 20
Remove-EC2KeyPair -KeyName $random -Force
Remove-EC2SecurityGroup -GroupName $random -Force

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
  "m4.large" {$HeadNodeCost = (0.125 * $hours) }
  "m4.xlarge" {$HeadNodeCost = (0.25 * $hours) }
  "m4.2xlarge" {$HeadNodeCost = (0.5 * $hours) }
  }

switch($WorkerNodeType) {
  "m4.large" {$WorkerNodeCost = (( $WorkerCount * 0.125) * $hours) }
  "m4.xlarge" {$WorkerNodeCost = (( $WorkerCount * 0.25) * $hours) }
  "m4.2xlarge" {$WorkerNodeCost = (( $WorkerCount * 0.5) * $hours) }
}

$cost = [Math]::Round($HeadNodeCost + $WorkerNodeCost,3);

Invoke-RestMethod -Uri http://13.79.186.204/api/pricing/$random/$cost
Invoke-RestMethod -Uri http://13.79.186.204/api/overhead/$random/$startupMinutes


Write-Output "$(Get-Date)"

Write-Output ("Find your benchmark at: http://tpch.ga/detailed/" + $random)
Write-Host "Press any key to exit ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
