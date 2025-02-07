#!/bin/bash

# Function to check and install AWS CLI
install_aws_cli() {
  if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    sudo apt-get update
    sudo apt-get install -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm awscliv2.zip
    echo "AWS CLI installed successfully."
  else
    echo "AWS CLI is already installed."
  fi
  aws --version
}

# Function to check and install eksctl
install_eksctl() {
  if ! command -v eksctl &> /dev/null; then
    echo "Installing eksctl..."
    curl -s --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    echo "eksctl installed successfully."
  else
    echo "eksctl is already installed."
  fi
  eksctl version
}

# Function to check and install kubectl
install_kubectl() {
  if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "kubectl installed successfully."
  else
    echo "kubectl is already installed."
  fi
  kubectl version --client
}

# Function to check and install Helm
install_helm() {
  if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "Helm installed successfully."
  else
    echo "Helm is already installed."
  fi
  helm version
}

# Main script execution
install_aws_cli
install_eksctl
install_kubectl
install_helm

echo "All tools checked and installed if needed!"

