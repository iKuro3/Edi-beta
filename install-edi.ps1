# PowerShell Script to Install Python, Clone GitHub Repo, and Install Required Libraries

# Step 1: Set up variables
$basePath = "C:\tools"
$repoUrl = "https://github.com/iKuro3/Edi-beta.git"
$pythonInstaller = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python-installer.exe"
$ediPs1Path = "$basePath\Edi-beta\edi.ps1"
$ediScriptPath = "$basePath\Edi-beta\edi.py"

# Step 2: Create tools directory
if (-not (Test-Path $basePath)) {
    Write-Host "Creating C:\tools directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $basePath
}

# Step 3: Download and Install Python if not installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Downloading Python installer..." -ForegroundColor Green
    Invoke-WebRequest -Uri $pythonInstaller -OutFile $pythonInstallerPath

    Write-Host "Installing Python..." -ForegroundColor Green
    Start-Process -Wait -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1"

    # Verify Python installation
    $pythonExe = (Get-Command python).Source
    if ($pythonExe) {
        Write-Host "Python Installed Successfully! Path: $pythonExe" -ForegroundColor Green
    } else {
        Write-Host "Python installation failed!" -ForegroundColor Red
        Exit
    }
} else {
    Write-Host "Python is already installed." -ForegroundColor Green
}

# Step 4: Clone the GitHub repository
if (-not (Test-Path "$basePath\Edi-beta")) {
    Write-Host "Cloning GitHub repository..." -ForegroundColor Green
    git clone $repoUrl $basePath\Edi-beta
} else {
    Write-Host "Repository already exists." -ForegroundColor Yellow
}

# Step 5: Upgrade pip and install required Python libraries
Write-Host "Upgrading pip and installing necessary libraries..." -ForegroundColor Green
Start-Process -NoNewWindow -Wait -FilePath "python" -ArgumentList "-m pip install --upgrade pip"
Start-Process -NoNewWindow -Wait -FilePath "python" -ArgumentList "-m pip install windows-curses"

# Step 6: Add edi function to the PowerShell profile
Write-Host "Updating PowerShell profile to add edi function..." -ForegroundColor Green
if (-not (Test-Path -Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force  # Create the profile if it doesn't exist
}

# Append the function to the PowerShell profile
$ediFunction = @"
function edi {
    param ([string]`$filePath)
    & "python" "$ediScriptPath" `$filePath
}
"@

Add-Content -Path $PROFILE -Value $ediFunction

# Step 7: Reload PowerShell profile to apply changes
Write-Host "Reloading PowerShell profile..." -ForegroundColor Green
. $PROFILE

# Step 8: Run the edi.ps1 script
if (Test-Path $ediPs1Path) {
    Write-Host "Running edi.ps1 script..." -ForegroundColor Green
    & "$ediPs1Path"
} else {
    Write-Host "edi.ps1 script not found!" -ForegroundColor Red
    Exit
}

Write-Host "Setup complete. You can now run edi <filename> from any directory!" -ForegroundColor Green
