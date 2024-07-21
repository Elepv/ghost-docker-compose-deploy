#!/bin/bash

# 检查envsubst是否已安装
if ! command -v envsubst &> /dev/null
then
    echo "envsubst 未安装。根据您的操作系统，使用以下命令安装 envsubst:"
    
    # 检测操作系统并提供相应的安装命令
    case "$(uname -s)" in
       Darwin)
         echo "MacOS:"
         echo 
         echo "brew install gettext"
         ;;
       Linux)
         if [ -f /etc/debian_version ]; then
             echo "Debian/Ubuntu:" 
             echo
             echo "sudo apt-get install gettext"
         elif [ -f /etc/redhat-release ]; then
             echo "Red Hat/CentOS: "
             echo
             echo "sudo yum install gettext"
         else
             echo "其他Linux系统请根据您的包管理器安装 gettext"
         fi
         ;;
       *)
         echo "不支持的操作系统"
         ;;
    esac

    echo "请安装后重新运行此脚本。"
    exit 1
fi

# 定义函数处理模板文件
configure_files() {
    echo "正在配置文件..."
    # 使用envsubst替换模板文件中的变量
    envsubst < ./default.conf.template > ./blog/nginx/conf.d/default.conf
    envsubst < ./apply_cert.sh.template > ./blog/scripts/apply_cert.sh
    envsubst < ./config.production.json.template > ./blog/ghost/config.production.json

    echo
    echo "先进入项目目录"
    echo "运行  `sudo ./blog/scripts/apply_cert.sh`  获取证书文件"
    echo
    echo "运行 'docker-compose up -d' 来启动服务。"
    echo
}

# 定义一个函数来获取和确认用户输入
get_user_input() {

    echo "您是否准备好以下资料？"
    echo "----------------------"
    echo "域名、VPS的IP。"
    echo "Gmail账户 和 Gmail 的 App 密码（需要先去Gmail 上获取，不会自行搜索关键字）"
    echo "项目名和项目根目录[可选，有默认值]"
    echo
    read -p "您已准备好这些信息了吗？[y/n]" ready
    if [[ $ready != "y" ]]; then
        echo
        echo "请准备好所有信息后再运行此脚本。"
        echo
        exit 1
    fi

    echo "----------"
    echo "开始输入："
    echo

    read -p "请输入域名: " domain
    read -p "请输入VPS的IP地址: " ip
    read -p "请输入MySQL的root密码: " mysql_root
    read -p "请输入MySQL的用户密码: " mysql_user
    read -p "请输入Gmail账户: " gmail_acc
    read -p "请输入Gmail的App密码: " gmail_pass
    read -p "请输入项目名（默认为当前目录名）: " project_name
    read -p "请输入项目根目录（默认为当前用户的家目录）: " project_root_folder

    # 设置默认值
    project_name=${project_name:-$(basename "$(pwd)")}
    project_root_folder=${project_root_folder:-$HOME}

    echo
    echo
    echo "请确认您输入的信息："
    echo "--------------------"
    echo "域名: $domain"
    echo "VPS的IP地址: $ip"
    echo "MySQL的root密码: $mysql_root"
    echo "MySQL的用户密码: $mysql_user"
    echo "Gmail账户: $gmail_acc"
    echo "Gmail的App密码: $gmail_pass"
    echo "项目名: $project_name"
    echo "项目根目录: $project_root_folder"
    echo
    read -p "以上信息是否正确？(y/n): " confirm

    if [[ $confirm == "y" ]]; then

        # 导出变量供 envsubst 使用
        export DOMAIN_NAME=$domain
        export VPS_IP=$ip
        export MYSQL_ROOT_PASSWORD=$mysql_root
        export MYSQL_PASSWORD=$mysql_user
        export GMAIL_ACCOUNT=$gmail_acc
        export GMAIL_APP_PASSWORD=$gmail_pass
        export PROJECT_NAME=$project_name
        export PROJECT_ROOT_FOLDER=$project_root_folder

        envsubst < .env.template > .env
        configure_files

    else
        echo "输入错误，请重新输入。"
        get_user_input
    fi
}

if [ -f ".env" ]; then
    echo "检测到已存在的 .env 文件，文件内容如下："
    echo "----------------------------------------"
    cat .env  # 打印.env文件内容供用户查看
    echo
    echo "是否需要重新生成 .env 文件？[y/n]"
    read regenerate
    if [[ $regenerate == "y" ]]; then
        # 备份.env文件
        cp .env ".env.backup_$(date +%Y%m%d%H%M%S)"
        echo "以备份旧的 .env 文件"
        echo
        # 调用函数获取用户输入
        get_user_input
    else
        echo "继续使用旧的配置文件。"
        configure_files
    fi
else
    echo " 开始创建新的配置文件。"
    
    # 调用函数获取用户输入
    get_user_input
fi
