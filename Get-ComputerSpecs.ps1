Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     OCM ICT EQUIPMENT INSPECTION SYSTEM DATA EXTRACTOR  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Computer Name
Write-Host "• COMPUTER NAME: " -NoNewline -ForegroundColor Yellow
Write-Host "$(hostname)"

# 2. Processor
$cpu = (Get-CimInstance Win32_Processor).Name.Trim()
Write-Host "• PROCESSOR: " -NoNewline -ForegroundColor Yellow
Write-Host "$cpu"

# 3. Installed RAM
$ramBytes = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum
$ramGB = [Math]::Round($ramBytes / 1GB)
Write-Host "• INSTALLED RAM: " -NoNewline -ForegroundColor Yellow
Write-Host "$ramGB GB"

# 4. Graphics Card
$gpu = (Get-CimInstance Win32_VideoController).Name -join " / "
Write-Host "• GRAPHICS CARD: " -NoNewline -ForegroundColor Yellow
Write-Host "$gpu"

# 5. Storage Type
$drives = Get-PhysicalDisk | Select-Object DeviceId, MediaType, @{Name="SizeGB";Expression={[Math]::Round($_.Size / 1GB)}}
Write-Host "• STORAGE CATEGORY: " -NoNewline -ForegroundColor Yellow
$driveTypes = foreach ($d in $drives) { "$($d.MediaType) ($($d.SizeGB)GB)" }
Write-Host ($driveTypes -join " + ")

# 6. Connectivity & IP Address
$activeNet = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
$ipAddr = (Get-NetIPAddress -InterfaceIndex $activeNet.InterfaceIndex -AddressFamily IPv4 | Select-Object -First 1).IPAddress
Write-Host "• CONNECTIVITY TYPE: " -NoNewline -ForegroundColor Yellow
Write-Host "$($activeNet.InterfaceDescription)"
Write-Host "• IP ADDRESS: " -NoNewline -ForegroundColor Yellow
Write-Host "$ipAddr"

# 7. System Restore Point Status
$restorePoints = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
Write-Host "• SYSTEM RESTORE POINT EXIST?: " -NoNewline -ForegroundColor Yellow
if ($restorePoints) { Write-Host "YES" -ForegroundColor Green } else { Write-Host "NO (Action Required)" -ForegroundColor Red }

# 8. WinSAT / Hardware Scores
Write-Host ""
Write-Host "--- WINSAT HARDWARE SCORES ---" -ForegroundColor Cyan
$winsat = Get-CimInstance Win32_WinSAT -ErrorAction SilentlyContinue
if ($winsat) {
    Write-Host "• CPU Score:      " -NoNewline -ForegroundColor Yellow; Write-Host $winsat.CPUScore
    Write-Host "• D3D Score:      " -NoNewline -ForegroundColor Yellow; Write-Host $winsat.D3DScore
    Write-Host "• Disk Score:     " -NoNewline -ForegroundColor Yellow; Write-Host $winsat.DiskScore
    Write-Host "• Graphics Score: " -NoNewline -ForegroundColor Yellow; Write-Host $winsat.GraphicsScore
    Write-Host "• Memory Score:   " -NoNewline -ForegroundColor Yellow; Write-Host $winsat.MemoryScore
    Write-Host "• WinSPR Level:   " -NoNewline -ForegroundColor Yellow; Write-Host $winsat.WinSPRLevel -Font-style Bold
} else {
    Write-Host "⚠️ No WinSAT score found. Run 'winsat formal' first!" -ForegroundColor Change
}
Write-Host "==========================================================" -ForegroundColor Cyan
