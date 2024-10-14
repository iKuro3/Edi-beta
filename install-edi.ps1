# install-edi.ps1

# Step 1: Create the C:/tools directory if it doesn't exist
$toolsPath = "C:\tools"
if (-not (Test-Path $toolsPath)) {
    Write-Host "Creating C:\tools directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $toolsPath
} else {
    Write-Host "C:\tools directory already exists." -ForegroundColor Yellow
}

# Step 2: Install Git using Chocolatey
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git using Chocolatey..." -ForegroundColor Green
    choco install git -y
} else {
    Write-Host "Git is already installed." -ForegroundColor Green
}

# Step 3: Clone the Edi-beta repository using Git
$ediRepoUrl = "https://github.com/iKuro3/Edi-beta.git"
$ediRepoPath = "$toolsPath\Edi-beta"

if (-not (Test-Path $ediRepoPath)) {
    Write-Host "Cloning Edi-beta repository..." -ForegroundColor Green
    git clone $ediRepoUrl $ediRepoPath
} else {
    Write-Host "Repository already exists." -ForegroundColor Yellow
}

# Step 4: Copy edi.py to C:/tools
$ediPyFilePath = "$ediRepoPath\edi.py"
if (Test-Path $ediPyFilePath) {
    Copy-Item -Path $ediPyFilePath -Destination $toolsPath -Force
    Write-Host "Copied edi.py to C:/tools" -ForegroundColor Green
} else {
    Write-Host "edi.py not found in the repository!" -ForegroundColor Red
    Exit 1
}

# Step 5: Remove the Edi-beta repository folder
Remove-Item -Recurse -Force $ediRepoPath
Write-Host "Deleted the Edi-beta repository folder." -ForegroundColor Green

# Step 6: Test if edi.py can be run
Write-Host "Testing if edi.py works with Python from the PATH..." -ForegroundColor Green
$pythonTest = Get-Command python -ErrorAction SilentlyContinue
if ($pythonTest) {
    Write-Host "Running edi.py..." -ForegroundColor Green
    & python "$toolsPath\edi.py"
} else {
    Write-Host "Python is not in the PATH. Please ensure Python is installed using install_python.ps1." -ForegroundColor Red
    Exit 1
}

Write-Host "Installation and setup of edi.py is complete." -ForegroundColor Green
