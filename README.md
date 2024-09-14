# DockerScripts

这里是一些Docker的脚本，用于快速搭建一些常用的服务。

---
# 目录
- [脚本](#脚本)
- [Docker安装](#1-docker安装)
  - [Linux](#11-linux)
- [Pull镜像](#2-pull镜像)


# 脚本

- 快速启动一个图形化的ubuntu系统，通过浏览器访问

> 默认密码：password
```shell
sudo curl -fsSL https://raw.githubusercontent.com/Rain-kl/docker-script/main/novnc_ubuntu.sh | bash 
```

- 部署redis服务
```shell
sudo curl -fsSL https://raw.githubusercontent.com/Rain-kl/docker-script/main/docker_redis.sh | bash 
```


## Docker安装
> 一键安装命令（每天自动从官网定时同步）
```shell
sudo curl -fsSL https://github.com/tech-shrimp/docker_installer/releases/download/latest/linux.sh| bash -s docker --mirror Aliyun
```
> 备用（如果Github访问不了，可以使用Gitee的链接）
```shell
sudo curl -fsSL https://gitee.com/tech-shrimp/docker_installer/releases/download/latest/linux.sh| bash -s docker --mirror Aliyun
```
> 启动docker
```shell
sudo systemctl start docker
sudo systemctl enable docker
```

# Pull镜像

### 方案一  转存到阿里云
使用Github Action将国外的Docker镜像转存到阿里云私有仓库，供国内服务器使用，免费易用

- 支持DockerHub, gcr.io, k8s.io, ghcr.io等任意仓库
- 支持最大40GB的大型镜像
- 使用阿里云的官方线路，速度快

项目地址: 
https://github.com/tech-shrimp/docker_image_pusher

### 方案二 镜像站
现在只有很少的国内镜像站存活<br>
不保证镜像齐全,且用且珍惜<br>
以下三个镜像站背靠较大的开源项目，优先推荐<br>

|项目名称|项目地址| 加速地址|
| ----------- | ----------- |----------- |
|1Panel|[https://github.com/1Panel-dev/1Panel/](https://github.com/1Panel-dev/1Panel/)|https://docker.1panel.live|
|Daocloud|[https://github.com/DaoCloud/public-image-mirror](https://github.com/DaoCloud/public-image-mirror)|https://docker.m.daocloud.io|
|耗子面板|[https://github.com/TheTNB/panel](https://github.com/TheTNB/panel 	)|https://hub.rat.dev|


#### Linux配置镜像站
```
sudo vi /etc/docker/daemon.json
```
输入下列内容，最后按ESC，输入 :wq! 保存退出。
```
{
    "registry-mirrors": [
        "https://docker.m.daocloud.io",
        "https://docker.1panel.live",
        "https://hub.rat.dev"
    ]
}
```
重启docker
```
sudo service docker restart
```