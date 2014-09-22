FROM debian:7.6
MAINTAINER maintain@geneegroup.com

ENV DEBIAN_FRONTEND noninteractive

ENV MYSQL_PASSWORD 83719730
RUN apt-get update && \
  echo "mysql-server mysql-server/root_password password $MYSQL_PASSWORD" | debconf-set-selections && \
	echo "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD" | debconf-set-selections && \
	apt-get install -y procps mysql-server && \
	sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf && \
	sed -i 's/^myisam-recover\s*=/myisam-recover-options =/' /etc/mysql/my.cnf && \
	sed -i 's/^log_error\s*=/#log_error =/' /etc/mysql/my.cnf && \
	sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
RUN /usr/sbin/mysqld --skip-networking & \
    sleep 3s && \
    echo "GRANT ALL ON *.* TO genee@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES" \
    | mysql -u root -p$MYSQL_PASSWORD
RUN mkdir -p /etc/mysql/conf.d
ADD 50-disable-name-resolving.cnf /etc/mysql/conf.d/50-disable-name-resolving.cnf

# We have to use separate volume for mysql data since it might be really big
# VOLUME ["/data", "/etc/mysql", "/var/lib/mysql", "/var/log/mysql"]
VOLUME ["/var/lib/mysql"]

EXPOSE 3306

ADD start /start
CMD ["/start"]
