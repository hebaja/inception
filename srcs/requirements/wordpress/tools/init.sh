#!/bin/sh

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

until /usr/bin/mariadb-admin ping -h "mariadb" -u "$DB_USER" --password="$DB_PASS" --silent; do
	sleep 2
done

if ! wp core is-installed --allow-root 2>/dev/null; then
	wp core download --allow-root

	wp config create \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASS" \
		--dbhost="mariadb" \
		--allow-root

	wp core install \
		--url="$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASS" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--allow-root

	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--role=subscriber \
		--user_pass="$WP_USER_PASS" \
		--allow-root
fi

exec "$@"
