FROM alpine:latest as builder
ARG TENGINE_VERSION=2.4.0
ARG NGINX_HOME=/www/nginx

RUN apk update 
RUN apk add --no-cache bash
RUN apk add zlib-dev openssl openssl-dev pcre pcre-dev gcc g++ make wget
RUN cd /opt
RUN wget https://github.com/alibaba/tengine/archive/refs/tags/${TENGINE_VERSION}.tar.gz --content-disposition 
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
--without-http_fastcgi_module \
--without-http_uwsgi_module \ 
--without-http_scgi_module \
--without-http_memcached_module \ 
--add-module=./modules/ngx_http_upstream_dyups_module \
--add-module=./modules/ngx_http_upstream_check_module/ ' \
    && make \
    && make install \
    && /bin/bash -c 'mkdir -p /www/nginx/conf/conf.d' 
COPY nginx.conf ${NGINX_HOME}/conf/nginx.conf
COPY start.sh auto-reload.sh ${NGINX_HOME}/sbin/

#二次构建
FROM alpine:latest
ARG NGINX_HOME=/www/nginx
WORKDIR ${NGINX_HOME}
COPY --from=builder ${NGINX_HOME} ${NGINX_HOME}
RUN mkdir ${NGINX_HOME}/temp 
RUN   adduser -H -D nginx
RUN  chown -R nginx:nginx ${NGINX_HOME} \
	&& chmod -R +x ${NGINX_HOME}/sbin \
    && chmod -R u+rw- ${NGINX_HOME}/temp
ENV TZ=GMT+8
ENV PATH $PATH:${NGINX_HOME}/sbin
VOLUME ["/www/nginx/conf/conf.d"]
VOLUME ["/www/nginx/logs"]
EXPOSE 80 443 8081
RUN apk add --no-cache bash pcre inotify-tools
CMD ["/www/nginx/sbin/start.sh"]