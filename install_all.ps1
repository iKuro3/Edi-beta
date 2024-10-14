# install_all.ps1

# Helper function to disable Microsoft Store aliases for Python
function Disable-PythonStoreAlias {
    Write-Host "Disabling Microsoft Store Python alias..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        if (Get-Command python -ErrorAction SilentlyContinue) {
            Write-Host "Python store alias is still active. Please disable it manually." -ForegroundColor Red
        } else {
            Write-Host "Python Microsoft Store alias disabled or already not present." -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to disable Microsoft Store Python alias. You might need to do it manually." -ForegroundColor Red
    }
}

# Step 1: Install Git using Chocolatey if not installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Installing Git using Chocolatey..." -ForegroundColor Green
    choco install git -y

    # Refresh the PATH after Git installation
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Manually add Git to the PATH (if necessary)
    $gitPath = "C:\Program Files\Git\cmd"  # Adjust this path if necessary
    if (Test-Path $gitPath) {
        Write-Host "Adding Git to the PATH..." -ForegroundColor Green
        [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$gitPath", [EnvironmentVariableTarget]::Process)
    }
} else {
    Write-Host "Git is already installed." -ForegroundColor Green
}

# Step 2: Disable Microsoft Store Python Alias
Disable-PythonStoreAlias

# Step 3: Install Python if not installed
$pythonInstaller = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python-installer.exe"
$pythonInstallPath = "C:\Program Files\Python310\python.exe"

if (-not (Test-Path $pythonInstallPath)) {
    Write-Host "Python is not installed. Downloading and installing Python..." -ForegroundColor Green
    Invoke-WebRequest -Uri $pythonInstaller -OutFile $pythonInstallerPath

    # Install Python silently (without user intervention)
    Write-Host "Installing Python..." -ForegroundColor Green
    Start-Process -Wait -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1"

    # Verify Python installation
    if (Test-Path $pythonInstallPath) {
        Write-Host "Python installed successfully!" -ForegroundColor Green
        # Manually add Python to the PATH (if necessary)
        $pythonDirectory = [System.IO.Path]::GetDirectoryName($pythonInstallPath)
        [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$pythonDirectory", [EnvironmentVariableTarget]::Machine)

        # Refresh the PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Host "Python installation failed!" -ForegroundColor Red
        Exit 1
    }
} else {
    Write-Host "Python is already installed." -ForegroundColor Green
}

# Step 4: Clone the GitHub repository
$repoUrl = "https://github.com/iKuro3/Edi-beta.git"
$repoPath = "$env:TEMP\Edi-beta"

if (-not (Test-Path $repoPath)) {
    Write-Host "Cloning the Edi-beta repository..." -ForegroundColor Green
    git clone $repoUrl $repoPath
} else {
    Write-Host "Repository already exists at $repoPath." -ForegroundColor Yellow
}

# Step 5: Run install_python.ps1 (already handled Python installation)
$pythonScript = "$repoPath\install_python.ps1"
if (Test-Path $pythonScript) {
    Write-Host "Running install_python.ps1..." -ForegroundColor Green
    & "$pythonScript"
} else {
    Write-Host "install_python.ps1 script not found in the repository!" -ForegroundColor Red
}

# Step 6: Run install-edi.ps1 to complete the installation
$ediScript = "$repoPath\install-edi.ps1"
if (Test-Path $ediScript) {
    Write-Host "Running install-edi.ps1..." -ForegroundColor Green
    & "$ediScript"
} else {
    Write-Host "install-edi.ps1 script not found in the repository!" -ForegroundColor Red
    Exit 1
}

# Step 7: Test Python and edi.py functionality
$ediPyFile = "C:\tools\edi.py"
Write-Host "Testing if edi.py works with Python from the PATH..." -ForegroundColor Green
if (Test-Path $ediPyFile) {
    Write-Host "Running edi.py..." -ForegroundColor Green
    & python "$ediPyFile"
} else {
    Write-Host "edi.py not found in C:\tools directory. Something went wrong!" -ForegroundColor Red
}

Write-Host "Installation process completed successfully!" -ForegroundColor Green
