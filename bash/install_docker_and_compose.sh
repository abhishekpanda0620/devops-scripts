#!/bin/bash

# Exit immediately if any command fails
set -e

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo or switch to root user."
    exit 1
fi

# Detect Linux distribution
source /etc/os-release

install_docker() {
    echo "Detected $ID $VERSION_ID"
    echo "Installing Docker..."
    
    case $ID in
        debian|ubuntu|pop|raspbian)
            # Debian-based installation
            apt-get update
            apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                software-properties-common
                
            curl -fsSL https://download.docker.com/linux/$ID/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$ID $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
            ;;
        centos|fedora|rhel|ol)
            # RHEL-based installation
            if command -v dnf &>/dev/null; then
                pkg_manager=dnf
            else
                pkg_manager=yum
            fi

            $pkg_manager install -y yum-utils
            if [[ $ID == "fedora" ]]; then
                repo_url="https://download.docker.com/linux/fedora/docker-ce.repo"
            else
                repo_url="https://download.docker.com/linux/centos/docker-ce.repo"
            fi
            $pkg_manager-config-manager --add-repo $repo_url
            $pkg_manager install -y docker-ce docker-ce-cli containerd.io
            ;;
        amzn)
            # Amazon Linux installation
            yum install -y docker
            ;;
        *)
            echo "Unsupported Linux distribution: $ID"
            exit 1
            ;;
    esac

    # Start and enable Docker service
    systemctl enable --now docker
    echo "Docker installed successfully"
}

install_docker_compose() {
    echo "Installing Docker Compose..."
    
    # Get latest Docker Compose version
    COMPOSE_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/docker/compose/releases/latest)
    COMPOSE_VERSION=${COMPOSE_URL##*/}
    
    # Download and install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Verify installation
    echo "Docker Compose version: $(docker-compose --version)"
}

main() {
    install_docker
    install_docker_compose
    
    echo "Installation completed successfully"
    echo "Docker version: $(docker --version)"
    echo "Docker Compose version: $(docker-compose --version)"
}

main
