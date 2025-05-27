#!/bin/bash

# Azure DevOps Self-Hosted Agent Installation Script (Linux/Mac)
# Run this script to automatically set up your Azure DevOps self-hosted agent

set -e

echo -e "\033[96m"
cat << "EOF"

 █████╗ ███████╗██╗   ██╗██████╗ ███████╗    ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗
██╔══██╗╚══███╔╝██║   ██║██╔══██╗██╔════╝    ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝
███████║  ███╔╝ ██║   ██║██████╔╝█████╗      ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗
██╔══██║ ███╔╝  ██║   ██║██╔══██╗██╔══╝      ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║
██║  ██║███████╗╚██████╔╝██║  ██║███████╗    ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝

                           Self-Hosted Agent Setup

EOF
echo -e "\033[0m"

echo -e "\033[93mThis script will help you set up an Azure DevOps self-hosted agent using Docker.\033[0m"
echo

# Check if Docker is installed and running
echo -e "\033[92mChecking Docker installation...\033[0m"
if ! command -v docker &> /dev/null; then
    echo -e "\033[91m✗ Docker is not installed!\033[0m"
    echo -e "\033[93mPlease install Docker and ensure it's running before continuing.\033[0m"
    echo -e "\033[93mInstall from: https://docs.docker.com/get-docker/\033[0m"
    exit 1
fi

# Test if Docker daemon is running
if ! docker ps &> /dev/null; then
    echo -e "\033[91m✗ Docker daemon is not running!\033[0m"
    echo -e "\033[93mPlease start Docker and try again.\033[0m"
    exit 1
fi

DOCKER_VERSION=$(docker --version)
echo -e "\033[92m✓ Docker found: $DOCKER_VERSION\033[0m"
echo -e "\033[92m✓ Docker daemon is running\033[0m"

# Get Azure DevOps organization URL
echo
echo -e "\033[96m--- Azure DevOps Configuration ---\033[0m"
while true; do
    read -p "Enter your Azure DevOps organization URL (e.g., https://dev.azure.com/yourorg): " AZP_URL
    if [[ $AZP_URL =~ ^https://dev\.azure\.com/.+ ]]; then
        break
    else
        echo -e "\033[91mPlease enter a valid Azure DevOps URL starting with https://dev.azure.com/\033[0m"
    fi
done

# Get Personal Access Token
while true; do
    read -s -p "Enter your Personal Access Token (PAT): " AZP_TOKEN
    echo
    if [[ ${#AZP_TOKEN} -ge 10 ]]; then
        break
    else
        echo -e "\033[91mPAT seems too short. Please enter a valid token.\033[0m"
    fi
done

# Get optional configuration
read -p "Enter agent name (or press Enter for auto-generated): " AZP_AGENT_NAME
if [[ -z "$AZP_AGENT_NAME" ]]; then
    AZP_AGENT_NAME="docker-agent-$(hostname | tr '[:upper:]' '[:lower:]')"
fi

read -p "Enter agent pool name (or press Enter for 'Default'): " AZP_POOL
if [[ -z "$AZP_POOL" ]]; then
    AZP_POOL="Default"
fi

# Build Docker image
echo
echo -e "\033[96m--- Building Docker Image ---\033[0m"
echo -e "\033[93mBuilding Azure DevOps agent Docker image...\033[0m"

# Check if we're in the right directory
if [[ ! -f "Dockerfile" ]]; then
    echo -e "\033[91m✗ Dockerfile not found in current directory!\033[0m"
    echo -e "\033[93mMake sure you're running this script from the repository root.\033[0m"
    exit 1
fi

# Build the Docker image
echo -e "\033[93mDetecting system architecture...\033[0m"
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo -e "\033[93mDetected Apple Silicon (ARM64). Building compatible image...\033[0m"
    PLATFORM_FLAG="--platform linux/arm64"
else
    echo -e "\033[93mDetected x86_64 architecture. Building standard image...\033[0m"
    PLATFORM_FLAG=""
fi

if ! docker build $PLATFORM_FLAG -t azdo-agent .; then
    echo -e "\033[91m✗ Failed to build Docker image!\033[0m"
    exit 1
fi

echo -e "\033[92m✓ Docker image built successfully!\033[0m"

# Stop and remove existing container if it exists
echo
echo -e "\033[96m--- Container Management ---\033[0m"
if docker ps -a --filter "name=azdo-agent" --format "{{.Names}}" | grep -q "azdo-agent"; then
    echo -e "\033[93mStopping and removing existing container...\033[0m"
    docker stop azdo-agent &> /dev/null || true
    docker rm azdo-agent &> /dev/null || true
    echo -e "\033[92m✓ Existing container removed\033[0m"
fi

# Run the container
echo -e "\033[93mStarting Azure DevOps agent container...\033[0m"
if ! docker run -d --name azdo-agent \
    -e AZP_URL="$AZP_URL" \
    -e AZP_TOKEN="$AZP_TOKEN" \
    -e AZP_AGENT_NAME="$AZP_AGENT_NAME" \
    -e AZP_POOL="$AZP_POOL" \
    --restart unless-stopped \
    $PLATFORM_FLAG \
    azdo-agent; then
    echo -e "\033[91m✗ Failed to start container!\033[0m"
    exit 1
fi

echo
echo -e "\033[92m🎉 Success! Your Azure DevOps agent is now running!\033[0m"

echo
echo -e "\033[96m--- Agent Details ---\033[0m"
echo -e "\033[97mOrganization: $AZP_URL\033[0m"
echo -e "\033[97mAgent Name: $AZP_AGENT_NAME\033[0m"
echo -e "\033[97mAgent Pool: $AZP_POOL\033[0m"
echo -e "\033[97mContainer Name: azdo-agent\033[0m"

echo
echo -e "\033[96m--- Useful Commands ---\033[0m"
echo -e "\033[97mView logs:           docker logs azdo-agent\033[0m"
echo -e "\033[97mView live logs:      docker logs -f azdo-agent\033[0m"
echo -e "\033[97mStop agent:          docker stop azdo-agent\033[0m"
echo -e "\033[97mStart agent:         docker start azdo-agent\033[0m"
echo -e "\033[97mRemove agent:        docker stop azdo-agent && docker rm azdo-agent\033[0m"

echo
echo -e "\033[93mThe agent should appear in your Azure DevOps organization within a few minutes.\033[0m"
echo -e "\033[93mGo to: $AZP_URL/_settings/agentpools to check the status.\033[0m"

echo
echo -e "\033[95mFor detailed instructions, see the README.md file\033[0m"
