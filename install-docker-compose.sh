#!/bin/bash

# 检测操作系统类型
OS_TYPE=$(uname)

# 检测操作系统发行版
if [[ "$OS_TYPE" == "Linux" ]]; then
  OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  # 删除引号
  OS="${OS%\"}"
  OS="${OS#\"}"
fi

# 获取最新版本的 Docker Compose
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4)

# 根据不同的操作系统发行版安装 Docker 和 Docker Compose
case $OS in
  "Debian GNU/Linux"|"Ubuntu")
    echo "Detected $OS"
    # 安装 Docker
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(echo $OS | awk '{print tolower($1)}') $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    # 安装 Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ;;

  "CentOS Linux"|"Rocky Linux")
    echo "Detected $OS"
    # 安装 Docker
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
    # 安装 Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ;;

  *)
    if [[ "$OS_TYPE" == "Darwin" ]]; then
      echo "Detected macOS"
      # 安装 Docker Desktop（包括 Docker Compose）
      brew install --cask docker
      # 打开 Docker Desktop
      open /Applications/Docker.app
    else
      echo "Unsupported operating system"
    fi
    ;;
esac

# 验证安装
echo "Docker version:"
sudo docker --version
echo "Docker Compose version:"
docker-compose --version
