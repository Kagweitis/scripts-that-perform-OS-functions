[void][Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”)
[void][Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms.DataVisualization”)
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
$Chart.Width = 500
$Chart.Height = 500
$Chart.Left = 40
$Chart.Top = 30
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$Chart.ChartAreas.Add($ChartArea)
$labels = “CPU”, “Memory”,”Commited Bytes”, “Disk Time”
if (!$args) {
$p = Get-Counter -counter “\Processor(_total)\% Processor Time”
$CS = gwmi win32_computersystem
$TotMemory = $cs.totalphysicalmemory/(1024*1024)
$MemoryAvailable = get-counter -counter “\Memory\Available MBytes”
$freeMemory = $MemoryAvailable.countersamples.cookedvalue
$UsedMemory = $TotMemory – $freeMemory
$UsedMemory = $UsedMemory * 100/ $TotMemory
$DiskTime = (get-counter -counter “\physicaldisk(_total)\% disk time”).countersamples.cookedvalue
$CommitedBytes = (get-counter -counter “\memory\% committed bytes in use”).countersamples.cookedvalue
}
else
{
$p = Get-Counter -counter “\Processor(_total)\% Processor Time” -ComputerName $args
$CS = gwmi win32_computersystem -ComputerName $args
$TotMemory = $cs.totalphysicalmemory/(1024*1024)
$MemoryAvailable = get-counter -counter “\Memory\Available MBytes” -ComputerName $args
$freeMemory = $MemoryAvailable.countersamples.cookedvalue
$UsedMemory = $TotMemory – $freeMemory
$UsedMemory = $UsedMemory * 100/ $TotMemory
$DiskTime = (get-counter -counter “\physicaldisk(_total)\% disk time” -ComputerName $args ).countersamples.cookedvalue
$CommitedBytes = (get-counter -counter “\memory\% committed bytes in use” -ComputerName $args ).countersamples.cookedvalue
}
$SystemCounter = $p.countersamples.cookedvalue,$UsedMemory, $CommitedBytes, $DiskTime
[void] $Chart.Series.Add(“Data”)
$Chart.Series[“Data”].Points.DataBindXY($labels, $SystemCounter)
$Chart.Series[“Data”][“DrawingStyle”] = “Cylinder”
# Find point with max/min values and change their colour
$maxValuePoint = $Chart.Series[“Data”].Points.FindMaxByValue()
$maxValuePoint.Color = [System.Drawing.Color]::Red
$minValuePoint = $Chart.Series[“Data”].Points.FindMinByValue()
$minValuePoint.Color = [System.Drawing.Color]::Green
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
[System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$Form = New-Object Windows.Forms.Form
$Form.Text = “PowerShell Chart”
$Form.Width = 600
$Form.Height = 600
$Form.controls.add($Chart)
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()