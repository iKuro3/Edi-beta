# install_python.ps1

# Step 1: Set up the Python installer URL and the download path
$pythonInstaller = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python-installer.exe"

# Step 2: Download Python installer
Write-Host "Downloading Python installer..." -ForegroundColor Green
Invoke-WebRequest -Uri $pythonInstaller -OutFile $pythonInstallerPath

# Step 3: Install Python silently (without user intervention)
Write-Host "Installing Python..." -ForegroundColor Green
Start-Process -Wait -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1"

# Step 4: Verify Python installation and check if it's available in the system PATH
$pythonExe = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonExe) {
    Write-Host "Python installation failed or not added to PATH." -ForegroundColor Red
    Exit 1
} else {
    Write-Host "Python installed successfully! Path: $($pythonExe.Source)" -ForegroundColor Green
}

# Step 5: Ensure Python is added to PATH for both SSH and normal terminals
$pythonInstallPath = "$($pythonExe.Source)"
$pythonInstallDirectory = [System.IO.Path]::GetDirectoryName($pythonInstallPath)

# Update system PATH for current session
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$pythonInstallDirectory", [EnvironmentVariableTarget]::Machine)

# Inform user about PATH update
Write-Host "Python has been added to the system PATH. Path: $pythonInstallDirectory" -ForegroundColor Green

# Reload PATH for current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Step 6: Test Python installation
Write-Host "Testing Python version..." -ForegroundColor Green
python --version

Write-Host "Python installation is complete." -ForegroundColor Green
