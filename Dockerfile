FROM: ubuntu

ENV PHP_USER_ID=33 \
    PHP_ENABLE_XDEBUG=0 \
    VERSION_COMPOSER_ASSET_PLUGIN=^1.4.3 \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.0 \
    PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    TERM=linux \
    COMPOSER_ALLOW_SUPERUSER=1 \
	  DEBIAN_FRONTEND=noninteractive \
	  LC_ALL=pl_PL.UTF-8

RUN apt-get update && \ 
echo "INSTALLING locales..........................:"; \
apt-get install -y locales && echo "pl_PL.UTF-8 UTF-8" | tee /etc/locale.gen && locale-gen && \
echo "INSTALLING STUFFs..........................:"; \
apt-get -y install software-properties-common lsb-release curl supervisor joe xtail git unzip gnupg2 && \ 
echo "ADDING ppa ondrej..........................:"; \
add-apt-repository -y ppa:ondrej/php && \
echo "INSTALLING NGINX..........................:"; \
echo "deb http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list && \
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list.d/nginx.list && \
curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - && \
apt update && \
apt-get -y install nginx; \
echo "INSTALLING wkhtmltopdf..........................:"; \
curl -L -o wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -sc)_amd64.deb && \
apt install -y ./wkhtmltox.deb && \
rm wkhtmltox.deb; \
echo "INSTALING PHP..........................:"; \
apt install php7.3-gd php7.3-intl php7.3-zip php7.3-soap php7.3-bcmath php7.3-calendar php7.3-exif php7.3-gettext php7.3-mysqli php7.3-pgsql php7.3-mysql php7.3-pgsql php7.3-mongodb && \
echo "INSTALLING FONTS..........................:"; \
apt-get -y install fonts-liberation; \
echo "INSTALLING COMPOSER..........................:"; \
curl -sS https://getcomposer.org/installer | php -- \
      --filename=composer \
      --install-dir=/usr/local/bin && \
  composer global require --optimize-autoloader \
      "fxp/composer-asset-plugin:${VERSION_COMPOSER_ASSET_PLUGIN}" \
      "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" && \
  composer global dumpautoload --optimize && \
echo "CLEARING INSTALLATION..........................:"; \
  composer clear-cache; \
apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update; apt-get -y install ssmtp mailutils && \
	sed -i -e"s/mailhub=mail/mailhub=smtp.i/g" /etc/ssmtp/ssmtp.conf 

ADD start.sh /

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
WORKDIR /app



