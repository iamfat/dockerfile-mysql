Docker Hub: iamfat/mysql
===========

## MySQL Environment (MySQL + SSH)
```bash
docker build -t iamfat/mysql mysql

#simple way
docker run --name mysql -v /dev/log:/dev/log -v /data:/data --privileged -d iamfat/mysql

# more advanced way
export BASE_DIR=/mnt/sda1/data
docker run --name mysql -v /dev/log:/dev/log -v $BASE_DIR:/data --privileged \
    -v $BASE_DIR/etc/mysql:/etc/mysql \
    -v $BASE_DIR/var/log/mysql:/var/log/mysql \
    -d iamfat/mysql

# mount /var/lib/mysql if you want
# -v $BASE_DIR/var/lib/mysql:/var/lib/mysql \

```
