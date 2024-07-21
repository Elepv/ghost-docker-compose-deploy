#!/bin/bash
# 根据不同的系统安装工具

# Identify the OS and install socat using the appropriate package manager.
# Get OS details
os="$(uname -s)"

# Check if macOS
if [ "$os" = "Darwin" ]; then
    echo "Detected macOS."
    if command -v brew &> /dev/null; then
        echo "Installing socat using Homebrew..."
        brew install socat
    else
        echo "Homebrew not installed. Please install Homebrew first."
    fi

# Check if Linux and determine the type
elif [ "$os" = "Linux" ]; then
    echo "Detected Linux."
    if [ -f /etc/debian_version ]; then
        echo "Using APT for Debian/Ubuntu based distributions."
        sudo apt-get update && sudo apt-get install socat -y
    elif [ -f /etc/redhat-release ]; then
        echo "Using YUM or DNF for Red Hat based distributions."
        if command -v dnf &> /dev/null; then
            sudo dnf install socat -y
        elif command -v yum &> /dev/null; then
            sudo yum install socat -y
        else
            echo "Neither YUM nor DNF is available."
        fi
    elif [ -f /etc/SuSE-release ] || grep -q 'SUSE' /etc/os-release; then
        echo "Using Zypper for openSUSE."
        sudo zypper install socat
    else
        echo "Distribution not supported by this script."
    fi
else
    echo "Unsupported operating system."
fi

curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# 申请证书
~/.acme.sh/acme.sh --issue -d efixai.com --standalone -k ec-256 --force --insecure

# 安装证书
~/.acme.sh/acme.sh --install-cert -d efixai.com \
    --key-file ~/certs/efixai.com.key \
    --fullchain-file ~/certs/fullchain.cer