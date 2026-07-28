FROM alpine:3.21

RUN apk add --no-cache php82 php82-fpm php82-phar php82-mysqli php82-xml php82-mbstring php82-curl mariadb-client wget curl

# Alpine exposes the PHP 8.2 CLI as `php82`, but WP-CLI invokes `php`.
# Create the conventional FPM account explicitly; it is not provided by
# every Alpine PHP package variant.
RUN ln -s /usr/bin/php82 /usr/local/bin/php && \
	adduser -S -D -H -s /sbin/nologin -G www-data www-data

RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
	mkdir -p /var/www/html && \
	tar -xzf /tmp/wordpress.tar.gz --strip-components=1 -C /var/www/html && \
	rm /tmp/wordpress.tar.gz

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
	chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["php-fpm82", "-F"]
