#!/bin/bash

# Azure DevOps Self-Hosted Agent Entrypoint Script

set -e

# Validate required environment variables
if [[ -z "$AZP_URL" ]]; then
    echo "Error: AZP_URL environment variable is required"
    echo "Example: https://dev.azure.com/yourorganization"
    exit 1
fi

if [[ -z "$AZP_TOKEN" ]]; then
    echo "Error: AZP_TOKEN environment variable is required"
    echo "Create a Personal Access Token with Agent Pools (read, manage) permissions"
    exit 1
fi

# Set default values
AZP_AGENT_NAME=${AZP_AGENT_NAME:-"docker-agent-$(hostname)"}
AZP_POOL=${AZP_POOL:-"Default"}

echo "Configuring Azure DevOps agent..."
echo "Organization URL: $AZP_URL"
echo "Agent name: $AZP_AGENT_NAME"
echo "Agent pool: $AZP_POOL"

# Configure the agent
./config.sh \
    --unattended \
    --url "$AZP_URL" \
    --auth pat \
    --token "$AZP_TOKEN" \
    --pool "$AZP_POOL" \
    --agent "$AZP_AGENT_NAME" \
    --work "_work" \
    --replace \
    --acceptTeeEula

# Cleanup function
cleanup() {
    echo "Removing agent..."
    ./config.sh remove --unattended --auth pat --token "$AZP_TOKEN"
}

# Set up signal handlers
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the agent
echo "Starting Azure DevOps agent..."
./run.sh &

# Wait for the agent process
wait $!
