FROM alpine:3.23.5

RUN apk add --no-cache php83 php83-fpm php83-phar php83-mysqli php83-xml \
	php83-mbstring php83-curl php83-tokenizer mariadb-client wget curl

RUN ln -s /usr/bin/php83 /usr/local/bin/php && \
	adduser -S -D -H -s /sbin/nologin -G www-data www-data

RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
	mkdir -p /var/www/html && \
	tar -xzf /tmp/wordpress.tar.gz --strip-components=1 -C /var/www/html && \
	rm /tmp/wordpress.tar.gz && \
	chown -R www-data:www-data /var/www/html

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
	chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["php-fpm83", "-F"]
