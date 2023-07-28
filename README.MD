阿里巴巴开源 Tengine web server 的 Docker 镜像打包模板，默认编译 upstream 热更新功能

### 配置文件

Dockerfile
基于 alpine 基础映像打包，特点是 image 体积小

### 打包命令

```
docker build -t tengine .
```

目前默认打包的 Tengine 版本号是 3.0.0，如果需要打包其他版本，可以在打包时传入版本号参数，比如：

```
docker build -t tengine --build-arg TENGINE_VERSION=2.4.1 .
```

### 编译细节

```
--add-module=./modules/ngx_http_upstream_dyups_module
```

此模块可提供 upstream 热更新功能，并提供了 rest api , 默认配置中已使用 8081 端口开启 API，可以在运行容器时映射端口以便使用

```
--add-module=./modules/ngx_http_upstream_check_module
```

此模块为主动健康检查功能

### 运行容器

```
docker run -d -p 80:80 --name Tengine tengine
```

可以通过挂载如下目录，修改容器内配置文件，获取错误日志

```
/www/nginx/conf/conf.d/
/www/nginx/conf/nginx.conf
/www/nginx/logs
```
