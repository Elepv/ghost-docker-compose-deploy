#!/bin/bash

# 检测操作系统发行版
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# 删除引号
OS="${OS%\"}"
OS="${OS#\"}"

# 根据不同的操作系统发行版安装 Docker 和 Docker Compose
case $OS in
  "Debian GNU/Linux")
    echo "Detected Debian GNU/Linux"
    # 安装 Docker
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg2 -y
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io -y
    # 安装 Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ;;

  "Ubuntu")
    echo "Detected Ubuntu"
    # 安装 Docker
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io -y
    # 安装 Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ;;

  *)
    echo "Unsupported operating system"
    ;;
esac

# 验证安装
echo "Docker version:"
sudo docker --version
echo "Docker Compose version:"
docker-compose --version
