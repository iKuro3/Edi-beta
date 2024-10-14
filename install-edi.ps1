# PowerShell Script to Install Chocolatey, Git, Python, Clone GitHub Repo, and Install Required Libraries

# Step 1: Set up variables
$basePath = "C:\tools"
$repoUrl = "https://github.com/iKuro3/Edi-beta.git"
$pythonInstaller = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python-installer.exe"
$ediPs1Path = "$basePath\Edi-beta\edi.ps1"
$ediScriptPath = "$basePath\Edi-beta\edi.py"

# Step 2: Install Chocolatey (if not installed)
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey is already installed." -ForegroundColor Green
}

# Step 3: Install Git (if not installed)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git using Chocolatey..." -ForegroundColor Green
    choco install git -y
} else {
    Write-Host "Git is already installed." -ForegroundColor Green
}

# Step 4: Create tools directory
if (-not (Test-Path $basePath)) {
    Write-Host "Creating C:\tools directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $basePath
}

# Step 5: Download and Install Python if not installed
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

# Step 6: Clone the GitHub repository
if (-not (Test-Path "$basePath\Edi-beta")) {
    Write-Host "Cloning GitHub repository..." -ForegroundColor Green
    git clone $repoUrl $basePath\Edi-beta
    if (-not (Test-Path "$basePath\Edi-beta")) {
        Write-Host "Failed to clone the repository. Check your Git installation or repository access." -ForegroundColor Red
        Exit
    }
} else {
    Write-Host "Repository already exists." -ForegroundColor Yellow
}

# Step 7: Upgrade pip and install required Python libraries
Write-Host "Upgrading pip and installing necessary libraries..." -ForegroundColor Green
Start-Process -NoNewWindow -Wait -FilePath "python" -ArgumentList "-m pip install --upgrade pip"
Start-Process -NoNewWindow -Wait -FilePath "python" -ArgumentList "-m pip install windows-curses"

# Step 8: Add edi function to the PowerShell profile
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

# Step 9: Reload PowerShell profile to apply changes (handling script execution policy)
Write-Host "Reloading PowerShell profile..." -ForegroundColor Green
Set-ExecutionPolicy RemoteSigned -Scope Process -Force  # Temporarily allow scripts to run
. $PROFILE

# Step 10: Run the edi.ps1 script if available
if (Test-Path $ediPs1Path) {
    Write-Host "Running edi.ps1 script..." -ForegroundColor Green
    & "$ediPs1Path"
} else {
    Write-Host "edi.ps1 script not found!" -ForegroundColor Red
    Exit
}

Write-Host "Setup complete. You can now run edi <filename> from any directory!" -ForegroundColor Green
