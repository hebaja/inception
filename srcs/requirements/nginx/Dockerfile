FROM alpine:3.23.5

RUN apk update && apk add --no-cache nginx openssl

RUN adduser -S -D -H -s /sbin/nologin -G www-data www-data && \
	mkdir -p /run/nginx /etc/nginx/ssl /var/lib/nginx && \
	openssl req -x509 -nodes -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-days 365 \
		-subj "/CN=hebatist.42.fr" && \
	chmod 600 /etc/nginx/ssl/nginx.key && \
	chown www-data:www-data /var/lib/nginx && \
	sed -i 's/^user .*/user www-data;/' /etc/nginx/nginx.conf

COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/init.sh"]
