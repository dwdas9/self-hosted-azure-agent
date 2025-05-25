# Azure DevOps Self-Hosted Agent on Ubuntu
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install essential packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    sudo \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install .NET SDK
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-8.0 \
    && rm -rf /var/lib/apt/lists/*

# Create a user for the agent
RUN useradd -m -s /bin/bash azureagent \
    && usermod -aG sudo azureagent \
    && echo "azureagent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to agent user
USER azureagent
WORKDIR /home/azureagent

# Download and extract Azure DevOps agent
ARG AGENT_VERSION="3.232.3"
RUN curl -o vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz -L https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
    && tar xzf vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
    && rm vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz

# Install agent dependencies
RUN sudo ./bin/installdependencies.sh

# Copy entrypoint script
COPY --chown=azureagent:azureagent entrypoint-azdo.sh /home/azureagent/entrypoint.sh
RUN chmod +x /home/azureagent/entrypoint.sh

# Set environment variables
ENV AZP_URL=""
ENV AZP_TOKEN=""
ENV AZP_AGENT_NAME=""
ENV AZP_POOL=""

ENTRYPOINT ["/home/azureagent/entrypoint.sh"]
