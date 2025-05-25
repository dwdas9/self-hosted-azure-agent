# Quick Setup Script for Self-Hosted Agents
# Run this script in PowerShell to set up your self-hosted agent

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("github", "azuredevops")]
    [string]$AgentType,
    
    [Parameter(Mandatory=$false)]
    [string]$WorkingDirectory = "C:\temp"
)

Write-Host "Setting up $AgentType self-hosted agent..." -ForegroundColor Green

# Create working directory
$agentDir = "$WorkingDirectory\$AgentType-agent"
if (!(Test-Path $agentDir)) {
    New-Item -ItemType Directory -Path $agentDir -Force
    Write-Host "Created directory: $agentDir" -ForegroundColor Yellow
}

Set-Location $agentDir

if ($AgentType -eq "github") {
    Write-Host "`n=== GitHub Actions Runner Setup ===" -ForegroundColor Cyan
    
    # Create necessary files (these would be created by the previous file creation commands)
    Write-Host "Files needed in $agentDir:" -ForegroundColor Yellow
    Write-Host "- Dockerfile"
    Write-Host "- entrypoint.sh"
    Write-Host "- docker-compose.yml"
    Write-Host "- .env.example"
    Write-Host "- README.md"
    
    Write-Host "`nNext steps:" -ForegroundColor Green
    Write-Host "1. Copy .env.example to .env"
    Write-Host "2. Edit .env with your GitHub token and repository"
    Write-Host "3. Run: docker-compose up -d"
    
} elseif ($AgentType -eq "azuredevops") {
    Write-Host "`n=== Azure DevOps Agent Setup ===" -ForegroundColor Cyan
    
    Write-Host "Files needed in $agentDir:" -ForegroundColor Yellow
    Write-Host "- Dockerfile"
    Write-Host "- entrypoint-azdo.sh"
    
    Write-Host "`nNext steps:" -ForegroundColor Green
    Write-Host "1. Build: docker build -t azdo-agent ."
    Write-Host "2. Run: docker run -d --name azdo-agent -e AZP_URL=https://dev.azure.com/yourorg -e AZP_TOKEN=your_token azdo-agent"
}

Write-Host "`nFor detailed instructions, see the README.md file" -ForegroundColor Magenta
