# Azure DevOps Agent Management Script
# Quick commands to manage your agent

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("logs", "start", "stop", "restart", "remove", "status")]
    [string]$Action
)

$ContainerName = "azdo-agent"

function Show-Help {
    Write-Host @"

 Azure DevOps Agent Management

 Usage: .\manage-agent.ps1 <action>

 Actions:
   logs     - View agent logs
   start    - Start the agent
   stop     - Stop the agent  
   restart  - Restart the agent
   remove   - Remove the agent completely
   status   - Check agent status

 Examples:
   .\manage-agent.ps1 logs
   .\manage-agent.ps1 restart

"@ -ForegroundColor Cyan
}

function Get-AgentStatus {
    $status = docker ps -a --filter "name=$ContainerName" --format "{{.Status}}" 2>$null
    return $status
}

if (-not $Action) {
    Show-Help
    $Action = Read-Host "Enter action (logs/start/stop/restart/remove/status)"
}

switch ($Action.ToLower()) {
    "logs" {
        Write-Host "Showing agent logs (press Ctrl+C to exit)..." -ForegroundColor Yellow
        docker logs -f $ContainerName
    }
    "start" {
        Write-Host "Starting agent..." -ForegroundColor Green
        docker start $ContainerName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Agent started successfully!" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to start agent!" -ForegroundColor Red
        }
    }
    "stop" {
        Write-Host "Stopping agent..." -ForegroundColor Yellow
        docker stop $ContainerName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Agent stopped successfully!" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to stop agent!" -ForegroundColor Red
        }
    }
    "restart" {
        Write-Host "Restarting agent..." -ForegroundColor Yellow
        docker restart $ContainerName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Agent restarted successfully!" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to restart agent!" -ForegroundColor Red
        }
    }
    "remove" {
        $confirm = Read-Host "Are you sure you want to remove the agent? This will unregister it from Azure DevOps. (y/N)"
        if ($confirm -eq "y" -or $confirm -eq "Y") {
            Write-Host "Stopping and removing agent..." -ForegroundColor Red
            docker stop $ContainerName 2>$null
            docker rm $ContainerName 2>$null
            Write-Host "✓ Agent removed!" -ForegroundColor Green
        } else {
            Write-Host "Cancelled." -ForegroundColor Yellow
        }
    }
    "status" {
        $status = Get-AgentStatus
        if ($status) {
            Write-Host "Agent Status: $status" -ForegroundColor Green
        } else {
            Write-Host "Agent not found or Docker not running" -ForegroundColor Red
        }
    }
    default {
        Write-Host "Invalid action: $Action" -ForegroundColor Red
        Show-Help
    }
}
