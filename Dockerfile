#From Aliyun instead of offical image, because we are in china (GFW)
FROM registry.aliyuncs.com/acs-sample/centos:7
#FROM centos:7
MAINTAINER Fer Uria <fauria@gmail.com>
LABEL Description="Linux + Apache 2.4 + PHP 5.4. CentOS 7 based. Includes .htaccess support and popular PHP5 features, including mail() function." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST PORT NUMBER]:80 -v [HOST WWW DOCUMENT ROOT]:/var/www/html fauria/lap" \
	Version="1.0"

ENV APACHE_USER=jenkins
ENV APACHE_GROUP=jenkins
ENV APACHE_UID=1002
ENV APACHE_GID=1002

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN groupadd -g ${APACHE_GID} ${APACHE_GROUP} \
    && useradd -u ${APACHE_UID} -g ${APACHE_GID} -m -s /bin/bash ${APACHE_USER}
    
RUN yum -y update && yum clean all
RUN yum -y install epel-release && yum clean all

## Add new repo
## RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum clean all
RUN yum install -y httpd postfix 
RUN yum install -y vim mariadb 

# Install php
RUN yum install -y \
	php \
	php-common \
	php-dba \
	php-gd \
	php-intl \
	php-ldap \
	php-mbstring \
	php-mysqlnd \
	php-odbc \
	php-pdo \
	php-pecl-memcache \
	php-pecl-zendopcache \
	php-pgsql \
	php-pspell \
	php-recode \
	php-snmp \
	php-soap \
        php-mcrypt \
	php-xml \
	php-xmlrpc

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC

COPY index.php /var/www/html/
COPY run-lap.sh /usr/sbin/
COPY run.sh /usr/sbin/

COPY ffmpeg /bin/

RUN chmod +x /usr/sbin/run-lap.sh
RUN /usr/sbin/run-lap.sh

RUN chown -R ${APACHE_USER}:${APACHE_GROUP} /var/www/html

VOLUME /var/www/html
VOLUME /var/log/httpd

EXPOSE 80

RUN chmod +x /usr/sbin/run.sh
CMD ["/usr/sbin/run.sh"]
