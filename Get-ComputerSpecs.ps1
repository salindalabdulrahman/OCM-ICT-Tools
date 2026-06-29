Clear-Host
$OutputText = [System.Collections.Generic.List[string]]::new()

# Function to handle dual output to screen and file collection
function Out-Both ($text, $color = "White") {
    Write-Host $text -ForegroundColor $color
    $global:OutputText.Add($text)
}

Out-Both "==========================================================" "Cyan"
Out-Both "     OCM ICT EQUIPMENT INSPECTION SYSTEM DATA EXTRACTOR  " "Cyan"
Out-Both "==========================================================" "Cyan"
Out-Both ""

# 1. Computer Name
Out-Both "• COMPUTER NAME: $(hostname)" "Yellow"

# 2. Processor
$cpu = (Get-CimInstance Win32_Processor).Name.Trim()
Out-Both "• PROCESSOR: $cpu" "Yellow"

# 3. Installed RAM
$ramBytes = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum
$ramGB = [Math]::Round($ramBytes / 1GB)
Out-Both "• INSTALLED RAM: $ramGB GB" "Yellow"

# 4. Graphics Card
$gpu = (Get-CimInstance Win32_VideoController).Name -join " / "
Out-Both "• GRAPHICS CARD: $gpu" "Yellow"

# 5. Storage Type
$drives = Get-PhysicalDisk | Select-Object DeviceId, MediaType, @{Name="SizeGB";Expression={[Math]::Round($_.Size / 1GB)}}
$driveTypes = foreach ($d in $drives) { "$($d.MediaType) ($($d.SizeGB)GB)" }
$storageCategory = $driveTypes -join " + "
Out-Both "• STORAGE CATEGORY: $storageCategory" "Yellow"

# 6. Connectivity & IP Address
$activeNet = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
$ipAddr = (Get-NetIPAddress -InterfaceIndex $activeNet.InterfaceIndex -AddressFamily IPv4 | Select-Object -First 1).IPAddress
Out-Both "• CONNECTIVITY TYPE: $($activeNet.InterfaceDescription)" "Yellow"
Out-Both "• IP ADDRESS: $ipAddr" "Yellow"

# 7. System Restore Point Status
$restorePoints = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
if ($restorePoints) { 
    Out-Both "• SYSTEM RESTORE POINT EXIST?: YES" "Green" 
} else { 
    Out-Both "• SYSTEM RESTORE POINT EXIST?: NO (Action Required)" "Red" 
}

# 8. WinSAT / Hardware Scores
Out-Both "" "White"
Out-Both "--- WINSAT HARDWARE SCORES ---" "Cyan"
$winsat = Get-CimInstance Win32_WinSAT -ErrorAction SilentlyContinue
if ($winsat) {
    Out-Both "• CPU Score:      $($winsat.CPUScore)" "Yellow"
    Out-Both "• D3D Score:      $($winsat.D3DScore)" "Yellow"
    Out-Both "• Disk Score:     $($winsat.DiskScore)" "Yellow"
    Out-Both "• Graphics Score: $($winsat.GraphicsScore)" "Yellow"
    Out-Both "• Memory Score:   $($winsat.MemoryScore)" "Yellow"
    Out-Both "• WinSPR Level:   $($winsat.WinSPRLevel)" "Green"
} else {
    Out-Both "⚠️ No WinSAT score found. Run 'winsat formal' first!" "Red"
}
Out-Both "==========================================================" "Cyan"

# Save the gathered output directly to the desktop environment
$DesktopPath = "$env:USERPROFILE\Desktop\Inspection_Data.txt"
$OutputText | Out-File -FilePath $DesktopPath -Force
Write-Host "`n✅ Success! Data saved directly to Desktop as: Inspection_Data.txt" -ForegroundColor Green
