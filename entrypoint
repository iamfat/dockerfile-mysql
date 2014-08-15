#!/bin/sh

chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
chmod 0700 /var/lib/mysql
chmod 2750 /var/log/mysql
exec "$@"
