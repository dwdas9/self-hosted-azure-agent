# Azure DevOps Self-Hosted Agent

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure%20DevOps-0078d7.svg?style=flat&logo=azure-devops&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=flat&logo=powershell&logoColor=white)
![Bash](https://img.shields.io/badge/bash-%23121011.svg?style=flat&logo=gnu-bash&logoColor=white)

The easiest way to create a Ubuntu-based, Docker Container which will be your self-hosted Azure DevOps agent. Just clone, run, and enter your PAT.

- [Azure DevOps Self-Hosted Agent](#azure-devops-self-hosted-agent)
  - [🚀 Quick Start](#-quick-start)
    - [What You Need](#what-you-need)
      - [How to Create a PAT](#how-to-create-a-pat)
    - [For Windows:](#for-windows)
    - [For Linux/Mac:](#for-linuxmac)
  - [Managing Your Agent](#managing-your-agent)
    - [Windows:](#windows)
    - [Linux/Mac:](#linuxmac)
  - [Features](#features)
  - [Manual Setup (if you prefer)](#manual-setup-if-you-prefer)
  - [Environment Variables](#environment-variables)
  - [Useful Commands](#useful-commands)
  - [Repository Structure](#repository-structure)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [License](#license)
  - [Support](#support)


## 🚀 Quick Start

### What You Need

- Docker installed on your machine **and started**
- An Azure DevOps Personal Access Token (PAT) with **Agent Pools (read, manage)** permissions

#### How to Create a PAT

1. From Azure DevOps organization → user settings → **Personal Access Tokens**
  ![](images/20250526150055.png)

2. Click **+ New Token**
  ![](images/20250526150710.png)

3. Give it a name (e.g., "Self-hosted Agent"), Select **Agent Pools (read, manage)** permissions, Click **Create**
  ![](images/20250526151425.png)

4. Copy the token (you won't see it again!)
  ![](images/20250526151622.png)

### For Windows:

**Option 1: PowerShell**
```powershell
git clone https://github.com/dwdas9/self-hosted-azure-agent.git
cd self-hosted-azure-agent
.\setup-agent.ps1
```

**Option 2: Double-click setup**
1. Clone or download this repository
2. Double-click `setup-agent.bat`
3. Follow the prompts

### For Linux/Mac:

1. Clone the repo and CD to it using terminal
2. Run the following commands
```bash
chmod +x install.sh
./install.sh
```
3. The command will create the docker image
![](images/20250526160311.png)
4. You should be able to see a container running in Docker Desktop Container section
![](images/20250526160357.png)
5. From Organizational settings, Agent Pools, Agents the agent should be running
![](images/20250526160612.png)

**That's it! 🎉**

## Managing Your Agent

After setup, use these scripts to manage your agent:

### Windows:
```powershell
.\manage-agent.ps1 status    # Check agent status
.\manage-agent.ps1 logs      # View logs
.\manage-agent.ps1 restart   # Restart agent
.\manage-agent.ps1 stop      # Stop agent
```

### Linux/Mac:
```bash
chmod +x manage-agent.sh
./manage-agent.sh status     # Check agent status
./manage-agent.sh logs       # View logs
./manage-agent.sh restart    # Restart agent
./manage-agent.sh stop       # Stop agent
```

## Features

- 🚀 **One-command setup** - Just run the script and enter your PAT
- 🐳 **Docker-based** - Clean, isolated environment
- 🔧 **Pre-installed tools**:
  - .NET SDK 8.0
  - Node.js & npm
  - Python 3
  - Azure CLI
  - Docker CLI
  - Git
- 🔄 **Auto-restart** - Agent automatically restarts if it fails
- 🧹 **Clean shutdown** - Properly removes agent when stopped
- 🛠️ **Management scripts** - Easy commands to control your agent

## Manual Setup (if you prefer)

1. Build the Docker image:
   ```bash
   docker build -t azdo-agent .
   ```

2. Run the container:
   ```bash
   docker run -d --name azdo-agent \
     -e AZP_URL=https://dev.azure.com/yourorganization \
     -e AZP_TOKEN=your_personal_access_token \
     -e AZP_AGENT_NAME=my-docker-agent \
     -e AZP_POOL=Default \
     --restart unless-stopped \
     azdo-agent
   ```

## Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `AZP_URL` | Yes | Your Azure DevOps organization URL | `https://dev.azure.com/myorg` |
| `AZP_TOKEN` | Yes | Personal Access Token | `abcd1234...` |
| `AZP_AGENT_NAME` | No | Custom agent name | `my-docker-agent` |
| `AZP_POOL` | No | Agent pool name | `Default` |

## Useful Commands

| Command | Description |
|---------|-------------|
| `docker logs azdo-agent` | View agent logs |
| `docker logs -f azdo-agent` | View live logs |
| `docker stop azdo-agent` | Stop the agent |
| `docker start azdo-agent` | Start the agent |
| `docker restart azdo-agent` | Restart the agent |
| `docker stop azdo-agent && docker rm azdo-agent` | Remove the agent completely |

## Repository Structure

```
📁 self-hosted-azure-agent/
├── 📄 Dockerfile              # Docker image configuration
├── 📄 entrypoint.sh           # Agent startup script
├── 📄 setup-agent.ps1         # Windows setup script
├── 📄 setup-agent.bat         # Windows double-click setup
├── 📄 install.sh              # Linux/Mac setup script
├── 📄 manage-agent.ps1        # Windows management script
├── 📄 manage-agent.sh         # Linux/Mac management script
├── 📄 README.md               # This file
└── 📄 LICENSE                 # MIT License
```

## Troubleshooting

**Agent not appearing in Azure DevOps?**
- Check your PAT has the correct permissions
- Verify your organization URL is correct
- Check container logs: `docker logs azdo-agent`

**Docker errors?**
- Make sure Docker Desktop is running
- Try restarting Docker Desktop
- Check if you have enough disk space

**Want to use a different agent pool?**
- Create the pool in Azure DevOps first
- Specify the pool name when prompted during setup

**Need to update the agent?**
```bash
# Stop current agent
docker stop azdo-agent && docker rm azdo-agent

# Update repository
git pull

# Run setup again
.\setup-agent.ps1    # Windows
./install.sh         # Linux/Mac
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues:
1. Check the [Troubleshooting](#troubleshooting) section
2. Look at existing [Issues](https://github.com/your-username/self-hosted-azure-agent/issues)
3. Create a new issue with detailed information

---

⭐ **Star this repository if it helped you!** ⭐
