# install_all.ps1
# This script will clone the repository and run both install_python.ps1 and install-edi.ps1

# Step 1: Set up variables
$repoUrl = "https://github.com/iKuro3/Edi-beta.git"
$repoPath = "$env:TEMP\Edi-beta"
$pythonScript = "$repoPath\install_python.ps1"
$ediScript = "$repoPath\install-edi.ps1"

# Step 2: Clone the GitHub repository
if (-not (Test-Path $repoPath)) {
    Write-Host "Cloning the Edi-beta repository..." -ForegroundColor Green
    git clone $repoUrl $repoPath
} else {
    Write-Host "Repository already exists at $repoPath." -ForegroundColor Yellow
}

# Step 3: Run install_python.ps1 to install Python
if (Test-Path $pythonScript) {
    Write-Host "Running install_python.ps1..." -ForegroundColor Green
    & "$pythonScript"
} else {
    Write-Host "install_python.ps1 script not found in the repository!" -ForegroundColor Red
    Exit 1
}

# Step 4: Run install-edi.ps1 to complete the installation
if (Test-Path $ediScript) {
    Write-Host "Running install-edi.ps1..." -ForegroundColor Green
    & "$ediScript"
} else {
    Write-Host "install-edi.ps1 script not found in the repository!" -ForegroundColor Red
    Exit 1
}

Write-Host "Installation process completed successfully!" -ForegroundColor Green
