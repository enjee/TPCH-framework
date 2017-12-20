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

#$secret = New-Object Windows.Forms.MaskedTextBox
$secret = New-Object Windows.Forms.TextBox
$secret.Width = 150
$secret.Height = 20
#$secret.PasswordChar = '*'
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
    $form.Close()
})
[System.Windows.Forms.Application]::EnableVisualStyles();
[void]$Form.ShowDialog()
$Form.Dispose()

#$secstr = $secret_key.Text | ConvertTo-SecureString -AsPlainText -Force

##############################
# ALL CONSTANTS & VARIABLES  #
##############################

# Keys
$access_key = $access.Text
$secret_key = $secret.Text
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
$ip1.IpRanges.Add("0.0.0.0/0")


$ip2 = new-object Amazon.EC2.Model.IpPermission 
$ip2.IpProtocol = "tcp" 
$ip2.FromPort = 3389 
$ip2.ToPort = 3389 
$ip2.IpRanges.Add("0.0.0.0/0") 

Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermissions @( $ip1, $ip2 )	

##############################
# Create EMR cluster         #
##############################
Write-Output ("Creating the EMR cluster on your account")
$job_id = Start-EMRJobFlow -Name $random `
                  -Instances_MasterInstanceType $HeadNodeType `
                  -Instances_SlaveInstanceType $WorkerNodeType `
                  -Instances_KeepJobFlowAliveWhenNoStep $true `
                  -Instances_InstanceCount $WorkerCount `
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

Write-Output ("Installing Python modules")
Invoke-SSHCommand -SSHSession $ssh -Command 'yes | sudo yum install git'
Invoke-SSHCommand -SSHSession $ssh -Command 'pip install requests'
Invoke-SSHCommand -SSHSession $ssh -Command 'sudo pip install natsort'

Write-Output ("Cloning GIT repo")
Invoke-SSHCommand -SSHSession $ssh -Command 'git clone -b development https://github.com/enjee/TPCH-framework'

Write-Output ("Running the Python benchmark")
$PythonCommand = ($PythonCommand + ' ' + $Size + ' ' + $Repeat + ' ' + $WorkerCount + ' ' + $WorkerNodeType + ' ' + $HeadNodeType + ' ' + $Tag + " Amazon")
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCHmodCommand -timeout 999999
Invoke-SSHCommand -SSHSession $ssh -Command $PythonCommand -timeout 999999

Remove-SSHSession -SessionId 0


#Remove-EC2KeyPair -KeyName $random
#Stop-EMRJobFlow-JobFlowId $job_id

