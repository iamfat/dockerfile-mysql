FROM ubuntu:14.04
MAINTAINER maintain@geneegroup.com

# Use faster APT mirror
ADD sources.list /etc/apt/sources.list

# Install Basic Packages
RUN apt-get update && apt-get install -y language-pack-en

# Install Supervisor
RUN apt-get install -y supervisor && \
    sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# Install SSH Server
ENV GENEE_PASSWORD 83719730
RUN apt-get install -y openssh-server && \
    mkdir /var/run/sshd && groupadd -f admin && \
    useradd -g admin -m -s /bin/bash -p $(perl -e 'print crypt("'$GENEE_PASSWORD'", "GENEE")') genee
ADD supervisor.ssh.conf /etc/supervisor/conf.d/ssh.conf

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
VOLUME ["/data", "/etc/mysql", "/var/lib/mysql", "/var/log/mysql"]

EXPOSE 3306
EXPOSE 22

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
