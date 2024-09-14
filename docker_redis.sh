#!/bin/bash

# required packages: curl

main(){
  install_docker
  install_docker_compose
  if [ -e "docker-compose.yml" ]; then
    echo "docker-compose.yml file exists, please delete it first"
    exit 1
  else
    echo "ok"
  fi
  #########################
  deploy_redis_docker
  #########################
  echo "Installation successful"

}

deploy_redis_docker(){
  mkdir redis
  write_redis_conf
  cat <<EOF > docker-compose.yml
version: '3.8'

services:
  redis:
    image: redis
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - ./redis/redis.conf:/etc/redis/redis.conf:ro
      - ./redis/data:/data

    command: redis-server /etc/redis/redis.conf --appendonly yes
    restart: always
    networks:
      - redis_network  # 将服务连接到定义的网络

networks:
  redis_network:  # 定义网络
    driver: bridge

EOF
  docker-compose up -d
  mv docker-compose.yml redis
}

write_redis_conf(){

  touch ./redis/redis.conf
  cat <<EOF > ./redis/redis.conf
# bind 127.0.0.1 -::1
protected-mode no
port 6379
# requirepass 123456 # 设置密码
appendonly yes

###############################################

tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
always-show-logo no
set-proc-title yes
proc-title-template "{title} {listen-addr} {server-mode}"
locale-collate ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
rdb-del-sync-files no
dir ./
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
repl-diskless-sync-delay 5
repl-diskless-sync-max-replicas 0
repl-diskless-load disabled
repl-disable-tcp-nodelay no
replica-priority 100
acllog-max-len 128
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
lazyfree-lazy-user-del no
lazyfree-lazy-user-flush no
oom-score-adj no
oom-score-adj-values 0 200 800
disable-thp yes
appendfilename "appendonly.aof"
appenddirname "appendonlydir"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
aof-timestamp-enabled no

slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-listpack-entries 512
hash-max-listpack-value 64
list-max-listpack-size -2
list-compress-depth 0
set-max-intset-entries 512
set-max-listpack-entries 128
set-max-listpack-value 64
zset-max-listpack-entries 128
zset-max-listpack-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
jemalloc-bg-thread yes
EOF

}


install_docker(){
#  check docker is installed
  if ! command -v docker &> /dev/null; then
    echo "docker could not be found"
  else
    echo "docker is installed"
    return
  fi
  # shellcheck disable=SC2162

  read -p "Do you want to download from Aliyun? (y/n) (default n): " choice

  case "$choice" in
    y|Y ) curl -fsSL https://github.com/tech-shrimp/docker_installer/releases/download/latest/linux.sh| bash -s docker --mirror Aliyun;;
    * ) curl -sSL https://get.docker.com/ | sh;;
  esac
}


install_docker_compose(){
  # Determine the Linux distribution and call the appropriate function
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      install_docker_compose_on_ubuntu
      ;;
    alpine)
      install_docker_compose_on_alpine
      ;;
    centos|rhel|fedora)
      install_docker_compose_on_centos
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

}


# Function to install packages on Ubuntu/Debian
install_docker_compose_on_ubuntu() {
  # check docker-compose is installed

  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    apt update
    apt install -y docker-compose
  else
    echo "docker-compose is installed"
  fi
}

# Function to install packages on Alpine
install_docker_compose_on_alpine() {
  # check docker-compose is installed
  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    apk update
    apk add docker-compose
  else
    echo "docker-compose is installed"
  fi
}

# Function to install packages on CentOS/RHEL
install_docker_compose_on_centos() {
  # check docker-compose is installed
  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    yum -y update
    yum install -y docker-compose
  else
    echo "docker-compose is installed"
  fi
}

main
