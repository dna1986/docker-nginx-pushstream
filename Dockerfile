FROM centos:centos7

MAINTAINER "Adrian Cristea" <adrian@softarea.ro>

# Install prerequisites for Nginx compile
RUN yum install -y \
        wget \
        tar \
        openssl-devel \
        gcc \
        gcc-c++ \
        make \
        zlib-devel \
        pcre-devel \
        gd-devel \
        krb5-devel \
        git

# Download Nginx and Nginx modules source
RUN wget http://nginx.org/download/nginx-1.9.7.tar.gz -O nginx.tar.gz && \
    mkdir /tmp/nginx && \
    tar -xzvf nginx.tar.gz -C /tmp/nginx --strip-components=1 &&\
    git clone https://github.com/wandenberg/nginx-push-stream-module.git /tmp/nginx/nginx-push-stream-module

WORKDIR /tmp/nginx

RUN ./configure \
        --user=nginx \
        --with-debug \
        --group=nginx \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/usr/share/nginx/nginx.pid \
        --lock-path=/run/lock/subsys/nginx \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --with-http_gzip_static_module \
        --with-http_ssl_module \
        --with-pcre \
        --with-file-aio \
        --with-http_gunzip_module \
        --add-module=/tmp/nginx/nginx-push-stream-module && \
    make && \
    make install

# Cleanup after Nginx build
RUN yum remove -y \
        wget \
        tar \
        gcc \
        gcc-c++ \
        make \
        git && \
    yum autoremove -y && \
    rm -rf /tmp/*

RUN adduser -c "Nginx user" nginx && \
    setcap cap_net_bind_service=ep /usr/sbin/nginx

RUN chown -R nginx:nginx /etc/nginx /var/log/nginx /usr/share/nginx

EXPOSE 80

USER nginx
ENTRYPOINT ["/usr/sbin/nginx"]

