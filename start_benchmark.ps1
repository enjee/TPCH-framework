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
   $newProcess.Arguments = $myInvocation.MyCommand.Path -replace ' ', '` ';

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
   }

##############################
# GUI                        #
##############################

Add-Type -AssemblyName System.Windows.Forms



$Form = New-Object system.Windows.Forms.Form
$Form.Text = "TPCH Benchmark"
$Form.TopMost = $true
$Form.Width = 350
$Form.Height = 300
$Form.StartPosition = "CenterScreen"

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "On which provider would you like to execute the benchmark: "
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(20,40)
$Form.controls.Add($header_lbl)

$azure_button = New-Object system.windows.Forms.Button
$azure_button.Text = "Azure"
$azure_button.Width = 150
$azure_button.Height = 29
$azure_button.location = new-object system.drawing.point(100,100)
$Form.controls.Add($azure_button)

$amazon_button = New-Object system.windows.Forms.Button
$amazon_button.Text = "Amazon"
$amazon_button.Width = 150
$amazon_button.Height = 29
$amazon_button.location = new-object system.drawing.point(100,150)
$Form.controls.Add($amazon_button)

$amazon_button.Add_Click({
    $global:provider = $amazon_button.Text
    $form.Close()
})
$azure_button.Add_Click({
    $global:provider = $azure_button.Text
    $form.Close()
})
[System.Windows.Forms.Application]::EnableVisualStyles();
[void]$Form.ShowDialog()
$Form.Dispose()

if($global:provider -eq "Azure")
  {
    $AcceptedNodeTypes = "Standard_A3", "Standard_A4", "Standard_A6", "Standard_D3", "Standard_D4", "Standard_D12"
    $PossibleNodes = "Standard_A3", "Standard_A4", "Standard_A6", "Standard_D3", "Standard_D4", "Standard_D12"
  }
else
  {
    $AcceptedNodeTypes = "m4.large", "m4.xlarge", "m4.2xlarge"
    $PossibleNodes = "m4.large", "m4.xlarge", "m4.2xlarge"
  }

# Test variables
$AllowedTestSizes = 1, 5, 10, 100
$MaxRepeatTest = 10
$Tag = "no-tag"

Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "TPCH Benchmark on " + $global:provider
$Form.TopMost = $true
$Form.Width = 500
$Form.Height = 600
$Form.StartPosition = "CenterScreen"

$start = New-Object system.windows.Forms.Button
$start.Text = "Start Benchmark"
$start.Width = 141
$start.Height = 29
$start.location = new-object system.drawing.point(156,520)
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
    $AddName = $PossibleNodes[$i]
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
    $AddName = $PossibleNodes[$i]
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

$tag_label = New-Object system.windows.Forms.Label
$tag_label.Text = "Add tag to benchmark:"
$tag_label.AutoSize = $true
$tag_label.Width = 25
$tag_label.Height = 10
$tag_label.location = new-object system.drawing.point(8,460)
$tag_label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($tag_label)

$tag_box = New-Object system.windows.Forms.TextBox
$tag_box.Width = 100
$tag_box.Height = 20
$tag_box.Text = "no-tag"
$tag_box.location = new-object system.drawing.point(150,460)
$tag_box.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($tag_box)



$start.Add_Click({
    $form.Close()
})
[System.Windows.Forms.Application]::EnableVisualStyles();
[void]$Form.ShowDialog()
$Form.Dispose()

$WorkerCount = $worker_count.Text
$WorkerNodeType = $worker_nodes.Text
$HeadNodeType = $head_nodes.Text
$Repeat = $repeat_test_count.Text
$Size = $test_size.Text
$Tag = $tag_box.Text  -replace '\s','-'



Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "TPCH Benchmark"
$Form.BackColor = "#34bce5"
$Form.TopMost = $true
$Form.Width = 800
$Form.Height = 340
$Form.StartPosition = "CenterScreen"
$Form.ForeColor = "#434343"
$Form.BackColor = "#FCFCFC"

$start = New-Object system.windows.Forms.Button
$start.Text = "Login, confirm and start"
$start.Width = 200
$start.Height = 29
$start.location = new-object system.drawing.point(300,260)
$start.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($start)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "You are starting the benchmark with these parameters"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(150,20)
$header_lbl.Font = "Microsoft Sans Serif,15"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Provider"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(30,75)
$header_lbl.Font = "Microsoft Sans Serif,14, style=italic"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = $global:provider
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(30,100)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Head type"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(210,75)
$header_lbl.Font = "Microsoft Sans Serif,14, style=italic"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = $HeadNodeType
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(210,100)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Worker type"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(370,75)
$header_lbl.Font = "Microsoft Sans Serif,14, style=italic"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = $WorkerNodeType
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(370,100)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Worker count"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(540,75)
$header_lbl.Font = "Microsoft Sans Serif,14, style=italic"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = $WorkerCount
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(540,100)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Repeat time(s)"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(30,150)
$header_lbl.Font = "Microsoft Sans Serif,14, style=italic"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = $repeat
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(30,175)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Testset size"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(210,150)
$header_lbl.Font = "Microsoft Sans Serif,14, style=italic"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = $Size + " GB"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(210,175)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "Benchmark tag"
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(370,150)
$header_lbl.Font = "Microsoft Sans Serif,14, style=italic"
$Form.controls.Add($header_lbl)

$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "#" + $Tag
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(370,175)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)


$header_lbl = New-Object system.windows.Forms.Label
$header_lbl.Text = "At the end of this script, the resources will be removed. Please check if this succeeded to prevent unexpected costs."
$header_lbl.AutoSize = $true
$header_lbl.Width = 25
$header_lbl.Height = 10
$header_lbl.location = new-object system.drawing.point(9,220)
$header_lbl.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($header_lbl)

$start.Add_Click({
    $form.Close()
})
[System.Windows.Forms.Application]::EnableVisualStyles();
[void]$Form.ShowDialog()
$Form.Dispose()


if($global:provider -eq "Azure")
  {
    $PSScriptRoot
    & "$PSScriptRoot\scripts\start_azure.ps1" $size $repeat $WorkerCount $WorkerNodeType $HeadNodeType $tag
  }
else
  {
    $PSScriptRoot
    & "$PSScriptRoot\scripts\start_aws.ps1" $size $repeat $WorkerCount $WorkerNodeType $HeadNodeType $tag
  }