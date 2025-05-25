#!/bin/bash

# Azure DevOps Agent Management Script
# Quick commands to manage your agent

CONTAINER_NAME="azdo-agent"

show_help() {
    echo -e "\033[96m"
    cat << 'EOF'

 Azure DevOps Agent Management

 Usage: ./manage-agent.sh <action>

 Actions:
   logs     - View agent logs
   start    - Start the agent
   stop     - Stop the agent  
   restart  - Restart the agent
   remove   - Remove the agent completely
   status   - Check agent status

 Examples:
   ./manage-agent.sh logs
   ./manage-agent.sh restart

EOF
    echo -e "\033[0m"
}

get_agent_status() {
    docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.Status}}" 2>/dev/null
}

if [[ $# -eq 0 ]]; then
    show_help
    read -p "Enter action (logs/start/stop/restart/remove/status): " ACTION
else
    ACTION=$1
fi

case "${ACTION,,}" in
    "logs")
        echo -e "\033[93mShowing agent logs (press Ctrl+C to exit)...\033[0m"
        docker logs -f $CONTAINER_NAME
        ;;
    "start")
        echo -e "\033[92mStarting agent...\033[0m"
        if docker start $CONTAINER_NAME; then
            echo -e "\033[92m✓ Agent started successfully!\033[0m"
        else
            echo -e "\033[91m✗ Failed to start agent!\033[0m"
        fi
        ;;
    "stop")
        echo -e "\033[93mStopping agent...\033[0m"
        if docker stop $CONTAINER_NAME; then
            echo -e "\033[92m✓ Agent stopped successfully!\033[0m"
        else
            echo -e "\033[91m✗ Failed to stop agent!\033[0m"
        fi
        ;;
    "restart")
        echo -e "\033[93mRestarting agent...\033[0m"
        if docker restart $CONTAINER_NAME; then
            echo -e "\033[92m✓ Agent restarted successfully!\033[0m"
        else
            echo -e "\033[91m✗ Failed to restart agent!\033[0m"
        fi
        ;;
    "remove")
        read -p "Are you sure you want to remove the agent? This will unregister it from Azure DevOps. (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo -e "\033[91mStopping and removing agent...\033[0m"
            docker stop $CONTAINER_NAME 2>/dev/null
            docker rm $CONTAINER_NAME 2>/dev/null
            echo -e "\033[92m✓ Agent removed!\033[0m"
        else
            echo -e "\033[93mCancelled.\033[0m"
        fi
        ;;
    "status")
        status=$(get_agent_status)
        if [[ -n "$status" ]]; then
            echo -e "\033[92mAgent Status: $status\033[0m"
        else
            echo -e "\033[91mAgent not found or Docker not running\033[0m"
        fi
        ;;
    *)
        echo -e "\033[91mInvalid action: $ACTION\033[0m"
        show_help
        ;;
esac
