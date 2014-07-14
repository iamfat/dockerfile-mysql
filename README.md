Docker Hub: iamfat/mysql
===========

## MySQL Environment (MySQL + SSH)
```bash
docker build -t iamfat/mysql mysql

#simple way
docker run --name mysql -v /dev/log:/dev/log -v /data:/data --privileged -d iamfat/mysql

# more advanced way
docker run --name mysql -v /dev/log:/dev/log -v /data:/data --privileged \
    -v /data/config/mysql:/etc/mysql \
    -v /data/mysql:/var/lib/mysql \
    -v /data/logs/mysql:/var/log/mysql \
    -d iamfat/mysql
```
