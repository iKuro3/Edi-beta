# PowerShell Script to Install Python, Add Python and edi.py to PATH, and Install Required Libraries

# Step 1: Download Python Installer (if not already installed)
$pythonInstaller = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python-installer.exe"

Write-Host "Downloading Python installer..." -ForegroundColor Green
Invoke-WebRequest -Uri $pythonInstaller -OutFile $pythonInstallerPath

# Step 2: Install Python silently (without manual intervention)
Write-Host "Installing Python..." -ForegroundColor Green
Start-Process -Wait -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1"

# Step 3: Verify Python Installation
$pythonVersion = python --version
if ($pythonVersion) {
    Write-Host "Python Installed Successfully! Version: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "Python installation failed!" -ForegroundColor Red
    Exit
}

# Step 4: Upgrade pip to ensure compatibility
Write-Host "Upgrading pip..." -ForegroundColor Green
Start-Process -NoNewWindow -Wait -FilePath "python" -ArgumentList "-m pip install --upgrade pip"

# Step 5: Install windows-curses library for terminal handling on Windows
Write-Host "Installing windows-curses library..." -ForegroundColor Green
Start-Process -NoNewWindow -Wait -FilePath "python" -ArgumentList "-m pip install windows-curses"

# Step 6: Ensure C:\tools directory exists, and place edi.py there
$toolsPath = "C:\tools"
$ediScriptPath = "$toolsPath\edi.py"

if (-not (Test-Path $toolsPath)) {
    Write-Host "Creating C:\tools directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $toolsPath
}

# Step 7: Download the edi.py script from Google Drive (placeholder for now)
if (-not (Test-Path $ediScriptPath)) {
    Write-Host "Downloading edi.py from Google Drive to C:\tools..." -ForegroundColor Green
    # Note: Direct Google Drive link download handling requires a manual step or third-party tools.
    # Example: The link may need manual download or using tools like wget with Drive-specific headers.
    Write-Host "Please manually download the edi.py file from the following link:" -ForegroundColor Yellow
    Write-Host "https://drive.google.com/file/d/1Cqocm8ZzUwiPsS5bQKZSGmUZK-k6IZJw/view?usp=drive_link"
    # Uncomment below if you manage the direct download via accessible URL:
    # Invoke-WebRequest -Uri "https://yourdomain.com/edi.py" -OutFile $ediScriptPath
}

# Step 8: Add edi function to the PowerShell profile
Write-Host "Updating PowerShell profile to add edi function..." -ForegroundColor Green

if (-not (Test-Path -Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force  # Create the profile if it doesn't exist
}

# Append the function to the PowerShell profile
Add-Content -Path $PROFILE -Value "`nfunction edi {`n param ([string]`$filePath)`n & `"C:\Program Files\Python310\python.exe`" `"$ediScriptPath`" `$filePath`n}`n"

# Step 9: Reload the profile to make the function available in the current session
Write-Host "Reloading PowerShell profile..." -ForegroundColor Green
. $PROFILE

Write-Host "Setup complete. You can now run edi <filename> from any directory!" -ForegroundColor Green
