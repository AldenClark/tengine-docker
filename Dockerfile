FROM alpine:latest as builder
ARG TENGINE_VERSION=3.0.0
ENV NGINX_HOME=/www/nginx

RUN apk update 
RUN apk add --no-cache bash
RUN apk add zlib-dev openssl openssl-dev pcre pcre-dev gcc g++ make wget
RUN cd /opt
RUN wget http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz --content-disposition 
RUN tar -zxvf tengine-${TENGINE_VERSION}.tar.gz \
    && cd tengine-${TENGINE_VERSION} \
    && /bin/bash -c './configure --prefix=/www/nginx \
    --http-client-body-temp-path=/www/nginx/temp/client_body_temp \ 
    --http-proxy-temp-path=/www/nginx/temp/proxy_temp \
    --with-http_stub_status_module \
    --with-stream \
    --with-http_realip_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --add-module=./modules/ngx_http_upstream_dyups_module \
    --add-module=./modules/ngx_http_upstream_check_module/ ' \
    && make \
    && make install \
    && /bin/bash -c 'mkdir -p /www/nginx/conf/conf.d' 
COPY nginx.conf ${NGINX_HOME}/conf/nginx.conf
COPY default-site.conf ${NGINX_HOME}/conf/conf.d/default-site.conf
COPY start.sh auto-reload.sh ${NGINX_HOME}/sbin/

#二次构建
FROM alpine:latest
RUN apk add --no-cache curl bash
ENV NGINX_HOME=/www/nginx
WORKDIR ${NGINX_HOME}
COPY --from=builder ${NGINX_HOME} ${NGINX_HOME}
RUN mkdir ${NGINX_HOME}/temp 
RUN   adduser -H -D nginx
RUN  chown -R nginx:nginx ${NGINX_HOME} \
	&& chmod -R +x ${NGINX_HOME}/sbin \
    && chmod -R u+rw- ${NGINX_HOME}/temp
ENV TZ=GMT+8
ENV PATH $PATH:${NGINX_HOME}/sbin
EXPOSE 80 443
RUN apk add --no-cache bash pcre inotify-tools
CMD ["/www/nginx/sbin/start.sh"]

LABEL description="阿里巴巴开源 Tengine web server 的 Docker 镜像，它在Nginx的基础上，针对大访问量网站的需求，添加了很多高级功能和特性"