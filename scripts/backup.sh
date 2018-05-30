#!/bin/bash
#mysql
user="root"
password="Ausias123@@"
host="localhost"
db_name="wordpress"
backup_path="/srv/mysql_backup"
date=$(date +"%d-%b-%Y")
# wordpress
WP="/home/ubuntu/docker/containers/wordpress/"
USUARIO_MAQUINA="ausias"
WORDPRESS_IP_CLIENTE=192.168.105.143
backup_path_wordpress="/srv/wordpress_backup"


umask 177

mysqldump --user=$user --password=$password --host=$host $db_name > $backup_path/$db_name-$date.sql

find $backup_path/* -mtime +30 -exec rm {} \;


#wordpress
sudo sshpass -p 'Ausias123@@' rsync --progress -avz -e ssh $USUARIO_MAQUINA@$WORDPRESS_IP_CLIENTE:$WP $backup_path_wordpress
tar -zcvf $backup_path_wordpress/wordpres_files_$date.tar.gz /srv/wordpress_backup/*
sudo find $backup_path_wordpress/ ! -name wordpres_files_*.tar.gz -type f -delete
