#!/bin/bash


install_novnc_ubuntu(){
  check_docker

  touch docker-compose.yml
  cat <<EOF > docker-compose.yml
version: '3.5'

services:
    ubuntu-xfce-vnc:
        container_name: xfce
        image: imlala/ubuntu-xfce-vnc-novnc:latest
        shm_size: "1gb"  # 防止高分辨率下Chromium崩溃,如果内存足够也可以加大一点点
        ports:
            - 5900:5900   # TigerVNC的服务端口（保证端口是没被占用的，冒号右边的端口不能改，左边的可以改）
            - 6080:6080   # noVNC的服务端口，注意事项同上
        environment:
            - VNC_PASSWD=password    # 改成你自己想要的密码
            - GEOMETRY=1400x800      # 屏幕分辨率，800×600/1024×768诸如此类的可自己调整
            - DEPTH=24               # 颜色位数16/24/32可用，越高画面越细腻，但网络不好的也会更卡
        volumes:
            - ~/Downloads:/root/Downloads  # Chromium/Deluge/qBittorrent/Transmission下载的文件默认保存位置都是root/Downloads下
            - ~/Documents:/root/Documents  # 映射一些其他目录
            - ~/Pictures:/root/Pictures
            - ~/Videos:/root/Videos
            - ~/Music:/root/Music
        restart: unless-stopped
EOF
  docker-compose up -d
}

install_docker(){
  # 询问用户是否继续
  # shellcheck disable=SC2162
  read -p "Do you want to download from a Chinese mirror address? (y/n) (default n): " choice

  # 根据用户输入执行不同的操作
  case "$choice" in
    y|Y ) bash <(curl -sSL https://linuxmirrors.cn/docker.sh);;
    * ) curl -sSL https://get.docker.com/ | sh;;
  esac
}

check_docker(){
  # 检查docker是否安装
  if ! command -v docker &> /dev/null; then
    echo "docker could not be found"
    install_docker
  else
    echo "docker is installed"
  fi
}


# Function to install packages on Ubuntu/Debian
install_ont_ubuntu() {
    # 检查docker-compose是否安装
  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    sudo apt update
    sudo apt install -y curl docker-compose
  else
    echo "docker-compose is installed"
  fi

  install_novnc_ubuntu
}

# Function to install packages on Alpine
install_ont_alpine() {
  # 检查docker-compose是否安装
  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    sudo apk update
    sudo apk add curl docker-compose
  else
    echo "docker-compose is installed"
  fi

  install_novnc_ubuntu
}

# Function to install packages on CentOS/RHEL
install_ont_centos() {
  # 检查docker-compose是否安装
  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    sudo yum -y update
    sudo yum install -y curl docker-compose
  else
    echo "docker-compose is installed"
  fi

  install_novnc_ubuntu
}

# Determine the Linux distribution and call the appropriate function
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      install_ont_ubuntu
      ;;
    alpine)
      install_ont_alpine
      ;;
    centos|rhel|fedora)
      install_ont_centos
      ;;
    *)
      echo "Unsupported Linux distribution: $ID"
      exit 1
      ;;
  esac
else
  echo "Cannot determine the Linux distribution."
  exit 1
fi

echo "Installation of packages complete."