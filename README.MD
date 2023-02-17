### 编译细节
--add-module=./modules/ngx_http_upstream_dyups_module 
此模块可提供upstream热更新功能，并提供了rest api

--add-module=./modules/ngx_http_upstream_check_module 
此模块为主动健康检查功能

### 配置文件
Dockerfile 
基于alpine基础映像打包，特点是image体积小

Dockerfile.ubuntu 
基于ubuntu基础映像打包，体积大，适用于部份alpine打包环境无法兼容的时候