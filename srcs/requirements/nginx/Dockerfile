FROM alpine:3.21

RUN apk update && apk add --no-cache nginx openssl

RUN mkdir -p /run/nginx /etc/nginx/ssl && \
	openssl req -x509 -nodes -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-days 365 \
		-subj "/CN=hebatist.42.fr" && \
	chmod 600 /etc/nginx/ssl/nginx.key

COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/init.sh"]
