# Azure DevOps Self-Hosted Agent Setup Script
# Run this script to automatically set up your Azure DevOps self-hosted agent

Write-Host @"

 █████╗ ███████╗██╗   ██╗██████╗ ███████╗    ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗
██╔══██╗╚══███╔╝██║   ██║██╔══██╗██╔════╝    ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝
███████║  ███╔╝ ██║   ██║██████╔╝█████╗      ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗
██╔══██║ ███╔╝  ██║   ██║██╔══██╗██╔══╝      ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║
██║  ██║███████╗╚██████╔╝██║  ██║███████╗    ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝

                           Self-Hosted Agent Setup
"@ -ForegroundColor Cyan

Write-Host "`nThis script will help you set up an Azure DevOps self-hosted agent using Docker.`n" -ForegroundColor Yellow

# Check if Docker is installed and running
Write-Host "Checking Docker installation..." -ForegroundColor Green
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not found"
    }
    Write-Host "✓ Docker found: $dockerVersion" -ForegroundColor Green
    
    # Test if Docker daemon is running
    docker ps >$null 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker daemon not running"
    }
    Write-Host "✓ Docker daemon is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not installed or not running!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop and ensure it's running before continuing." -ForegroundColor Yellow
    Write-Host "Download from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Get Azure DevOps organization URL
Write-Host "`n--- Azure DevOps Configuration ---" -ForegroundColor Cyan
do {
    $azpUrl = Read-Host "Enter your Azure DevOps organization URL (e.g., https://dev.azure.com/yourorg)"
    if ($azpUrl -notmatch "^https://dev\.azure\.com/.+") {
        Write-Host "Please enter a valid Azure DevOps URL starting with https://dev.azure.com/" -ForegroundColor Red
    }
} while ($azpUrl -notmatch "^https://dev\.azure\.com/.+")

# Get Personal Access Token
do {
    $azpToken = Read-Host "Enter your Personal Access Token (PAT)" -AsSecureString
    $azpTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($azpToken))
    if ($azpTokenPlain.Length -lt 10) {
        Write-Host "PAT seems too short. Please enter a valid token." -ForegroundColor Red
    }
} while ($azpTokenPlain.Length -lt 10)

# Get optional configuration
$agentName = Read-Host "Enter agent name (or press Enter for auto-generated)"
if ([string]::IsNullOrWhiteSpace($agentName)) {
    $agentName = "docker-agent-$([System.Environment]::MachineName.ToLower())"
}

$agentPool = Read-Host "Enter agent pool name (or press Enter for 'Default')"
if ([string]::IsNullOrWhiteSpace($agentPool)) {
    $agentPool = "Default"
}

Write-Host "`n--- Building Docker Image ---" -ForegroundColor Cyan
Write-Host "Building Azure DevOps agent Docker image..." -ForegroundColor Yellow

# Check if we're in the right directory
if (!(Test-Path "Dockerfile")) {
    Write-Host "✗ Dockerfile not found in current directory!" -ForegroundColor Red
    Write-Host "Make sure you're running this script from the repository root." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Build the Docker image
docker build -t azdo-agent .
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build Docker image!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Docker image built successfully!" -ForegroundColor Green

# Stop and remove existing container if it exists
Write-Host "`n--- Container Management ---" -ForegroundColor Cyan
$existingContainer = docker ps -a --filter "name=azdo-agent" --format "{{.Names}}" 2>$null
if ($existingContainer -eq "azdo-agent") {
    Write-Host "Stopping and removing existing container..." -ForegroundColor Yellow
    docker stop azdo-agent >$null 2>&1
    docker rm azdo-agent >$null 2>&1
    Write-Host "✓ Existing container removed" -ForegroundColor Green
}

# Run the container
Write-Host "Starting Azure DevOps agent container..." -ForegroundColor Yellow
docker run -d --name azdo-agent `
    -e AZP_URL="$azpUrl" `
    -e AZP_TOKEN="$azpTokenPlain" `
    -e AZP_AGENT_NAME="$agentName" `
    -e AZP_POOL="$agentPool" `
    --restart unless-stopped `
    azdo-agent

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to start container!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "`n🎉 Success! Your Azure DevOps agent is now running!" -ForegroundColor Green

Write-Host "`n--- Agent Details ---" -ForegroundColor Cyan
Write-Host "Organization: $azpUrl" -ForegroundColor White
Write-Host "Agent Name: $agentName" -ForegroundColor White
Write-Host "Agent Pool: $agentPool" -ForegroundColor White
Write-Host "Container Name: azdo-agent" -ForegroundColor White

Write-Host "`n--- Useful Commands ---" -ForegroundColor Cyan
Write-Host "View logs:           docker logs azdo-agent" -ForegroundColor White
Write-Host "View live logs:      docker logs -f azdo-agent" -ForegroundColor White
Write-Host "Stop agent:          docker stop azdo-agent" -ForegroundColor White
Write-Host "Start agent:         docker start azdo-agent" -ForegroundColor White
Write-Host "Remove agent:        docker stop azdo-agent && docker rm azdo-agent" -ForegroundColor White

Write-Host "`nThe agent should appear in your Azure DevOps organization within a few minutes." -ForegroundColor Yellow
Write-Host "Go to: $azpUrl/_settings/agentpools to check the status." -ForegroundColor Yellow

Read-Host "`nPress Enter to exit"

Write-Host "`nFor detailed instructions, see the README.md file" -ForegroundColor Magenta
