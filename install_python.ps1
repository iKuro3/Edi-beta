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

# Step 4: Check common installation locations for Python
$pythonInstallPath = "C:\Program Files\Python310\python.exe"

if (Test-Path $pythonInstallPath) {
    Write-Host "Python found at $pythonInstallPath. Adding to PATH..." -ForegroundColor Green
    $pythonDirectory = [System.IO.Path]::GetDirectoryName($pythonInstallPath)

    # Step 5: Update PATH permanently for all users
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$pythonDirectory", [EnvironmentVariableTarget]::Machine)

    # Step 6: Refresh the PATH in the current PowerShell session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Step 7: Verify Python installation
    $pythonExe = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonExe) {
        Write-Host "Python successfully added to PATH! Path: $($pythonExe.Source)" -ForegroundColor Green
    } else {
        Write-Host "Python installation failed or could not be added to PATH." -ForegroundColor Red
        Exit 1
    }
} else {
    Write-Host "Python installation failed or not installed in the default location." -ForegroundColor Red
    Exit 1
}
