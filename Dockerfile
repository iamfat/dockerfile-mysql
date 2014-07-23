FROM ubuntu:14.04
MAINTAINER maintain@geneegroup.com

# Install Basic Packages
RUN apt-get update && apt-get install -y supervisor && \
    sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# Install MySQL Server
ENV MYSQL_PASSWORD 83719730
RUN echo "mysql-server mysql-server/root_password password $MYSQL_PASSWORD" | debconf-set-selections && \
	echo "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD" | debconf-set-selections && \
	apt-get install -y mysql-server && \
	sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf && \
	sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
RUN /usr/sbin/mysqld --skip-networking & \
    sleep 3s && \
    echo "GRANT ALL ON *.* TO genee@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES" \
    | mysql -u root -p$MYSQL_PASSWORD
ADD supervisor.mysql.conf /etc/supervisor/conf.d/mysql.conf

# We have to use separate volume for mysql data since it might be really big
VOLUME ["/data", "/var/log/supervisor", "/etc/mysql", "/var/lib/mysql", "/var/log/mysql"]

EXPOSE 3306

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
